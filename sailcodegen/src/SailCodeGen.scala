// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

import org.chipsalliance.rvdecoderdb.{Arg, Instruction}
import upickle.default.{macroRW, read, write, ReadWriter => RW}
import mainargs._
import scala.collection.mutable.ArrayBuffer

object Main {
  @main
  case class Params(
      @arg(short = 'i', name = "model-dir", doc = "Path to Sail model implementation")
      sailModelDir:     os.Path,
      @arg(short = 'o', name = "output-dir", doc = "Output directory path to generate sail sources")
      outputDir:        os.Path,
      @arg(short = 'r', name = "riscv-opcodes-path", doc = "Path to riscv-opcodes path")
      riscvOpCodesPath: os.Path
  ) {
    def convert: SailCodeGeneratorParams = SailCodeGeneratorParams(
      sailModelDir,
      outputDir,
      riscvOpCodesPath
    )
  }

  implicit object PathRead extends TokensReader.Simple[os.Path] {
    def shortName               = "path"
    def read(strs: Seq[String]) = Right(os.Path(strs.head, os.pwd))
  }

  def main(args: Array[String]): Unit = {
    val params    = ParserForClass[Params].constructOrExit(args)
    val generator = new SailCodeGenerator(params.convert)
    generator.gen()
  }
}

case class Arch(xlen: Int, extensions: Set[String])

object Arch {
  def fromLiteral(march: String): Arch = {
    val xlen =
      if (march.startsWith("rv64")) 64
      else if (march.startsWith("rv32")) 32
      else throw new Exception(s"invalid march with invalid xlen: ${march}")

    val priv = 1

    val parsedMarch = march.replace("rv64g", "rv64imafd").replace("rv32g", "rv32imafd")

    val exts = parsedMarch.substring(4).split("_").toList match {
      case base :: ext =>
        base
          .flatMap(e =>
            if (e == 'g') { List("i", "m", "a", "f", "d") }
            else List(e.toString)
          )
          .toSet ++ ext.toSet
      case otherwise   => otherwise.toSet
    }

    if (exts.isEmpty) {
      throw new Exception(s"invalid march with not extension: ${march}")
    }

    Arch(xlen, exts)
  }
}

case class SailImplMeta(march: String)
object SailImplMeta {
  implicit val rw: RW[SailImplMeta] = macroRW
}

case class SailCodeGeneratorParams(sailModelDir: os.Path, outputDir: os.Path, riscvOpCodesPath: os.Path)
class SailCodeGenerator(params: SailCodeGeneratorParams) {
  // Group declare here to have forward compatibility to customize each path at runtime
  lazy private val archDir: os.Path = {
    os.makeDir.all(params.outputDir / "arch")
    params.outputDir / "arch"
  }

  private val sail_states_operation_path = archDir / "states_op.sail"
  private val sail_core_path             = params.outputDir / "rv_core.sail"

  lazy private val user_illegal_path = {
    if (!os.exists(params.sailModelDir / "arch" / "illegal.sail")) {
      throw new Exception("illegal.sail not found")
    }

    params.sailModelDir / "arch" / "illegal.sail"
  }

  private val user_csr_path    = params.sailModelDir / "csr"
  private val user_csr_db_path = user_csr_path / "csrs.csv"

  def gen() {
    val meta = read[SailImplMeta](os.read(params.sailModelDir / "meta.json"))

    val arch = Arch.fromLiteral(meta.march)

    genArchStatesOp(arch)

    genRVSail(arch)
  }

  def genSailAst(inst: Instruction): String = {
    val astLHS = "union clause ast"
    val astRHS = inst.name.toUpperCase.replace(".", "_") + " : " +
      (
        if (inst.args.length != 0)
          ("("
            +
              // The bimm and jimm are bit disordered,
              // need to deal with its order in encdec,
              // and combine the arg in ast and assembly.
              inst.args
                .filter(arg => !arg.toString.contains("hi"))
                .map(arg => {
                  if (arg.toString.contains("lo")) {
                    arg.name match {
                      case "bimm12lo"   => s"bits(12)"
                      case "jimm20lo"   => s"bits(20)"
                      case "imm20lo"    => s"bits(20)"
                      case "imm12lo"    => s"bits(12)"
                      case "c_nzimm6lo" => s"bits(7)"
                      case _            => s"bits(${arg.lsb - arg.msb + 1})"
                    }
                  } else {
                    s"bits(${arg.lsb - arg.msb + 1})"
                  }
                })
                .mkString(", ")
              +
              ")")
        else
          "unit"
      )
    astLHS + " = " + astRHS
  }

  def genSailEnc(inst: Instruction): String = {
    def encHelper(encStr: List[Char], args: Seq[Arg], acc: List[String]): List[String] = encStr match {
      case Nil                          => acc
      case '?' :: rest if args.nonEmpty =>
        val arg     = args.head
        val argBits = arg.lsb - arg.msb + 1
        val newAcc  = acc :+
          (arg.name match {
            case "bimm12hi" => "imm7_6 : bits(1) @ imm7_5_0 : bits(6)"
            case "bimm12lo" => "imm5_4_1 : bits(4) @ imm5_0 : bits(1)"
            case "jimm20"   =>
              "imm_19 : bits(1) @ imm_18_13 : bits(6) @ imm_12_9 : bits(4) @ imm_8 : bits(1) @ imm_7_0 : bits(8)"
            case "imm12lo"  => "imm12lo : bits(5)"
            case "imm12hi"  => "imm12hi : bits(7)"
            case _          => arg.name
          })

        encHelper(rest.drop(argBits - 1), args.tail, newAcc)
      case ch :: rest                   =>
        val chlist = encStr.takeWhile(_ != '?')
        val newAcc = acc :+ s"0b${chlist.mkString}"
        encHelper((ch :: rest).drop(chlist.mkString.length), args, newAcc)
    }

    val cExtendsSets = Set(
      "rv_c",
      "rv32_c",
      "rv64_c",
      "rv_c_d",
      "rv_c_f",
      "rv32_c_f",
      "rv_c_zihintntl",
      "rv_zcb",
      "rv64_zcb",
      "rv_zcmop",
      "rv_zcmp",
      "rv_zcmt",
      "rv_c_zicfiss"
    )

    if (cExtendsSets.contains(inst.instructionSet.name)) {
      "mapping clause encdec_compressed = " + inst.name.toUpperCase.replace(".", "_") + "(" +
        inst.args
          .filter(arg => !arg.toString.contains("hi"))
          .map(arg => {
            arg.name match {
              case "bimm12lo"   => "imm7_6 @ imm5_0 @ imm7_5_0 @ imm5_4_1"
              case "jimm20"     => "imm_19 @ imm_7_0 @ imm_8 @ imm_18_13 @ imm_12_9"
              case "imm12lo"    => "imm12hi @ imm12lo"
              case "c_nzimm6lo" => "nz96 @ nz54 @ nz3 @ nz2"
              case _            => arg.toString
            }
          })
          .mkString(", ") + ")" + " <-> " +
        encHelper(inst.encoding.toString.toList.drop(16), inst.args.sortBy(arg => -arg.msb), Nil).mkString(" @ ")
    } else {
      "mapping clause encdec = " + inst.name.toUpperCase.replace(".", "_") + "(" +
        inst.args
          .filter(arg => !arg.toString.contains("hi"))
          .map(arg => {
            arg.name match {
              case "bimm12lo"   => "imm7_6 @ imm5_0 @ imm7_5_0 @ imm5_4_1"
              case "jimm20"     => "imm_19 @ imm_7_0 @ imm_8 @ imm_18_13 @ imm_12_9"
              case "imm12lo"    => "imm12hi @ imm12lo"
              case "c_nzimm6lo" => "nz96 @ nz54 @ nz3 @ nz2"
              case _            => arg.toString
            }
          })
          .mkString(", ") + ")" + " <-> " +
        encHelper(inst.encoding.toString.toList, inst.args.sortBy(arg => -arg.msb), Nil).mkString(" @ ")
    }
  }

  def genSailExcute(arch: Arch, inst: Instruction): String = {
    val path = params.sailModelDir / inst.instructionSet.name / s"${inst.name.replace(".", "_")}.sail"

    if (os.exists(path)) {
      "function clause execute " + "(" +
        inst.name.toUpperCase.replace(".", "_") +
        "(" +
        inst.args
          .filter(arg => !arg.toString.contains("hi"))
          .map(arg => {
            arg.name match {
              case "bimm12lo" => arg.toString.stripSuffix("lo")
              case "jimm20lo" => arg.toString.stripSuffix("lo")
              case "imm12lo"  => arg.toString.stripSuffix("lo")
              case _          => arg.toString
            }
          })
          .mkString(", ") + ")) = {" + os.read(path).split('\n').map(line => "\n\t" + line).mkString + "\n" + "}"
    } else {
      throw new Exception(s"WARNING: instruction '${inst.name}' not found at path '${path}'")
    }
  }

  def genSailAssembly(inst: Instruction): String = {
    ("mapping clause assembly" + inst.name.toUpperCase.replace(".", "_") + "(" +
      inst.args
        .filter(arg => !arg.toString.contains("hi"))
        .map(arg => {
          if (arg.toString.contains("lo")) {
            arg.toString.head match {
              case 'b' => arg.toString.stripSuffix("lo")
              case 'j' => arg.toString.stripSuffix("lo")
              case 'i' => arg.toString.stripSuffix("lo")
              case _   => arg.toString
            }
          } else {
            arg.toString
          }
        })
        .mkString(", ") + ")") + ('"' + inst.name + '"' + " ^ spc()" +
      // Like ebreak has no arg
      (if (inst.args.nonEmpty) {
         " ^ " + inst.args
           .filter(arg => !arg.name.endsWith("hi"))
           .map { arg =>
             {
               arg.name match {
                 case "rs1"      => "reg_name(rs1)"
                 case "rs2"      => "reg_name(rs2)"
                 case "rd"       => "reg_name(rd)"
                 case "bimm12lo" => s"hex_bits_signed_12(bimm12)"
                 case "jimm20"   => s"hex_bits_signed_20(jimm20)"
                 case "imm12lo"  => s"hex_bits_signed_12(imm12)"
                 case arg
                     if arg.toString.startsWith("imm") && !arg.toString
                       .contains("hi") && !arg.toString.contains("lo") =>
                   val immNumber = arg.toString.stripPrefix("imm").toInt
                   s"hex_bits_signed_${immNumber}(${arg})"
                 case _          => s"hex_bits_signed_${arg.lsb - arg.msb + 1}(${arg})"
               }
             }
           }
           .mkString(" ^ sep() ^ ")
       } else "")).stripSuffix(" ^ ")
  }

  def genRVSail(arch: Arch): Unit = {
    os.write.over(
      sail_core_path,
      org.chipsalliance.rvdecoderdb
        .instructions(params.riscvOpCodesPath)
        .filter(inst => !inst.name.endsWith(".N"))
        .filter(inst =>
          arch.extensions.exists(ext => {
            val name = inst.instructionSet.name
            name.endsWith(s"rv_$ext") || name.endsWith(s"rv${arch.xlen}_${ext}")
          })
        )
        .map(inst =>
          inst.pseudoFrom match {
            case Some(_) => ""
            case None    => Seq(genSailAst(inst), genSailEnc(inst), genSailExcute(arch, inst), "\n").mkString("\n")
          }
        )
        .mkString
        + s"""mapping clause encdec = ILLEGAL(s) <-> s
             |function clause execute (ILLEGAL(s)) = {
             ${os.read(user_illegal_path).lines().map(l => "|\t" + l + "\n").toArray().mkString}
             |}
             |""".stripMargin
    )
  }

  def genGPROp(arch: Arch): String = {
    def to5BitStr(i: Int): String = {
      String.format("%5s", i.toBinaryString).replace(' ', '0')
    }

    val x0OpCode = s"""
       |// x0 is read-only zero
       |function clause read_GPR(0b00000) = zeros()
       |// write to x0 is a no-op
       |function clause write_GPR(0b00000, v : bits(64)) = ()
       |""".stripMargin

    val range = if (arch.extensions.contains("e")) 1 to 15 else 1 to 31

    val regOpCode = range
      .map { i =>
        val bit = to5BitStr(i)
        s"""function clause read_GPR(0b${bit}) = x$i
         |function clause write_GPR(0b${bit}, v : bits(64)) = {
         |\twrite_GPR_hook(0b${bit}, v);
         |\tx$i = v
         |}
         |""".stripMargin
      }
      .mkString("\n")

    x0OpCode + "\n" + regOpCode
  }

  def genCSRsOp(): String = {
    val csrs = os.read
      .lines(user_csr_path / "csrs.csv")
      .map(line =>
        line match {
          case s"${number},${csrname}" => (number, csrname)
          case _                       => throw new Exception(s"invalid csv line: ${line}")
        }
      )

    csrs
      .map { case (number, csrname) => {
        val read_op_path  = user_csr_path / "read" / s"${csrname}.sail"
        if (!os.exists(read_op_path)) {
          throw new Exception(s"missing read operation for ${csrname}")
        }
        val write_op_path = user_csr_path / "write" / s"${csrname}.sail"
        if (!os.exists(write_op_path)) {
          throw new Exception(s"missing write operation for ${csrname}")
        }

        val csrReadCode = s"""
        |function clause read_CSR(${number}) = {
        |${os.read(read_op_path)}
        |}""".stripMargin

        val csrWriteCode = s"""
        |function clause write_CSR(${number}, value) = {
        |${os.read(write_op_path)}
        |}""".stripMargin

        csrReadCode + "\n" + csrWriteCode
      }}
      .mkString("\n\n")
  }

  def genArchStatesOp(arch: Arch): Unit = {
    os.write.over(
      sail_states_operation_path,
      Seq("// GPRs", genGPROp(arch), "// CSRs", genCSRsOp()).mkString("\n")
    )
  }
}
