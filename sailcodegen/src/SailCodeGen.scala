// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

import org.chipsalliance.rvdecoderdb.{Arg, Instruction}
import upickle.default.{macroRW, read, write, ReadWriter => RW}
import mainargs._

object Main {
  @main
  case class Params(
      @arg(short = 'i', name = "sail-impl-dir", doc = "Path to sail implementation")
      sailImplDir:      os.Path,
      @arg(short = 'o', name = "output-dir", doc = "Output directory path to generate sail sources")
      outputDir:        os.Path,
      @arg(short = 'r', name = "riscv-opcodes-path", doc = "Path to riscv-opcodes path")
      riscvOpCodesPath: os.Path
  ) {
    def convert: SailCodeGeneratorParams = SailCodeGeneratorParams(
      sailImplDir,
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
  def fromMarch(march: String): Option[Arch] = {
    if (march.length < 5) return None

    val xlen = if (march.startsWith("rv64")) 64 else if (march.startsWith("rv32")) 32 else 0

    val parsedMarch = march.replace("rv64g", "rv64imafd").replace("rv32g", "rv32imafd")

    if (xlen == 0 || !List("rv64i", "rv32i", "rv32e").exists(parsedMarch.startsWith)) {
      return None
    }

    val exts = parsedMarch.substring(4).split("_").toList match {
      case head :: tail => head.map(_.toString).toSet ++ tail.toSet
      case Nil          => Set.empty[String]
    }

    Some(Arch(xlen, exts))
  }
}

case class Bitfields(bfname: String, bfpos: String)

object Bitfields {
  implicit val rw: RW[Bitfields] = macroRW
}

case class Position(position: String)

object Position {
  implicit val rw: RW[Position] = macroRW
}

case class CSR(
    csrname:       String,
    number:        String,
    width:         String,
    subordinateTo: String,
    bitfields:     Either[Position, Seq[Bitfields]]
)

object CSR {
  implicit val rw: RW[CSR] = macroRW

  // Define implicit ReadWriter for Either[Position, Seq[Bitfields]]
  implicit val eitherRW: RW[Either[Position, Seq[Bitfields]]] = upickle.default
    .readwriter[ujson.Value]
    .bimap(
      {
        case Left(position)   => write(position)
        case Right(bitfields) => write(bitfields)
      },
      json => {
        val jsonObj = ujson.read(json)
        if (jsonObj.isInstanceOf[ujson.Obj] && jsonObj.obj.contains("position")) {
          Left(read[Position](json))
        } else if (jsonObj.isInstanceOf[ujson.Arr]) {
          Right(read[Seq[Bitfields]](json))
        } else {
          throw new ujson.Value.InvalidData(json, "Expected Position or Seq[Bitfields]")
        }
      }
    )
}

case class SailImplMeta(march: String)
object SailImplMeta {
  implicit val rw: RW[SailImplMeta] = macroRW
}

case class SailCodeGeneratorParams(sailImplDir: os.Path, outputDir: os.Path, riscvOpCodesPath: os.Path)
class SailCodeGenerator(params: SailCodeGeneratorParams) {
  import params.{outputDir, riscvOpCodesPath, sailImplDir}

  def gen() {
    val meta = read[SailImplMeta](os.read(sailImplDir / "sail-impl-meta.json"))

    val parsedArch = Arch.fromMarch(meta.march)
    if (parsedArch.isEmpty) {
      throw new IllegalArgumentException(s"Invalid march ${meta.march}")
    }
    val arch       = parsedArch.get

    val csrConfigFilename = arch.xlen match {
      case 32 => "csr32.json"
      case 64 => "csr64.json"
      case _  => throw new IllegalArgumentException("Invalid arch or xlen")
    }
    val csrs              = read[Seq[CSR]](os.read(sailImplDir / "csr" / csrConfigFilename))

    os.makeDir.all(outputDir / "arch")
    genExtEnable(arch)
    genArchStatesReset(arch, csrs)
    genArchStatesDef(arch, csrs)
    genArchStatesRW(arch, csrs)

    genRVXLENSail(arch)
    genRVSail(arch)
    genCSRBFDef(csrs)
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
    val path =
      sailImplDir / "inst" / arch.xlen.toString / inst.instructionSet.name / inst.name.replace(".", "_")

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
      ""
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
    val rvCorePath      = outputDir / "rv_core.sail"
    val illegalInstPath = sailImplDir / "inst" / arch.xlen.toString / "illegal"

    os.write.over(
      rvCorePath,
      org.chipsalliance.rvdecoderdb
        .instructions(riscvOpCodesPath)
        .filter(inst => !inst.name.endsWith(".N"))
        .filter(inst => arch.extensions.exists(ext => inst.instructionSet.name.endsWith(s"rv_$ext")))
        .map(inst =>
          inst.pseudoFrom match {
            case Some(_) => ""
            case None    => Seq(genSailAst(inst), genSailEnc(inst), genSailExcute(arch, inst), "\n").mkString("\n")
          }
        )
        .mkString
        + s"""mapping clause encdec = ILLEGAL(s) <-> s
             |function clause execute (ILLEGAL(s)) = {
             ${os.read(illegalInstPath).lines().map(l => "|\t" + l + "\n").toArray().mkString}
             |}
             |""".stripMargin
    )
  }

  def genCSRBitfields(csr: CSR): String = {
    (if (csr.width == "64") {
       "bitfield " + csr.csrname.toUpperCase + " : " + "bits(64) = "
     } else if (csr.width == "32") {
       "bitfield " + csr.csrname.toUpperCase + " : " + "bits(32) = "
     } else {
       "bitfield " + csr.csrname.toUpperCase + " : " + csr.width + "BITS = "
     }) + "{\n" + (csr.bitfields match {
      // not deal with the position for now
      case Left(pos)  => ""
      case Right(bfs) => bfs.map(bf => "\t" + bf.bfname + " : " + bf.bfpos).mkString(",\n")
    }) + "\n}"
  }

  def genCSRRead(csr: CSR): String = {
    val readLHS = "function clause read_CSR" + "(" + csr.number + ")"
    val readRHS = csr.csrname + ".bits"
    readLHS + " = " + readRHS
  }

  def genCSRBFBitSet(csr: CSR): String = {
    (csr.bitfields match {
      case Left(pos)  => "bitSets"
      case Right(bfs) =>
        bfs
          .map { bf =>
            val path = os.pwd / "sailcodegen" / "jvm" / "src" / "sail" / "csr" / "W" / csr.csrname / bf.bfname

            if (csr.width == "64") {
              s"function set_${csr.csrname}_${bf.bfname}(v : bits(64)) -> unit = ${if (os.exists(path)) {
                  "{" + "\n" +
                    os.read(path)
                      .map(line => line)
                      .mkString + "\n" +
                    "}"
                } else {
                  "{\n\t" + csr.csrname + " = Mk_" + csr.csrname.toUpperCase + "(v)\n}"
                }}"
            } else if (csr.width == "32") {
              s"function set_${csr.csrname}_${bf.bfname}(v : bits(32)) -> unit = ${if (os.exists(path)) {
                  "{" + "\n" +
                    os.read(path)
                      .map(line => line)
                      .mkString + "\n" +
                    "}"
                } else {
                  "{\n\t" + csr.csrname + " = Mk_" + csr.csrname.toUpperCase + "(v)\n}"
                }}"
            } else {
              s"function set_${csr.csrname}_${bf.bfname}(v : ${csr.width}BITS) -> unit = ${if (os.exists(path)) {
                  "{" + "\n" +
                    os.read(path)
                      .map(line => line)
                      .mkString + "\n" +
                    "}"
                } else {
                  "{\n\t" + csr.csrname + " = Mk_" + csr.csrname.toUpperCase + "(v)\n}"
                }}"
            }
          }
          .mkString("\n")
    }) + "\n"
  }

  def genCSRBFBitGet(csr: CSR): String = {
    (csr.bitfields match {
      case Left(pos)  => "bitSets"
      case Right(bfs) =>
        bfs
          .map { bf =>
            val path = os.pwd / "sailcodegen" / "jvm" / "src" / "sail" / "csr" / "R" / csr.csrname / bf.bfname

            if (csr.width == "64") {
              s"function get_${csr.csrname}_${bf.bfname}() -> bits(64) = ${if (os.exists(path)) {
                  "{" + "\n" +
                    os.read(path)
                      .map(line => line)
                      .mkString + "\n" +
                    "}"
                } else {
                  "{\n\t" + csr.csrname + ".bits\n}"
                }}"
            } else if (csr.width == "32") {
              s"function get_${csr.csrname}_${bf.bfname}() -> bits(32) = ${if (os.exists(path)) {
                  "{" + "\n" +
                    os.read(path)
                      .map(line => line)
                      .mkString + "\n" +
                    "}"
                } else {
                  "{\n\t" + csr.csrname + ".bits\n}"
                }}"
            } else {
              s"function get_${csr.csrname}_${bf.bfname}() -> ${csr.width}BITS = ${if (os.exists(path)) {
                  "{" + "\n" +
                    os.read(path)
                      .map(line => line)
                      .mkString + "\n" +
                    "}"
                } else {
                  "{\n\t" + csr.csrname + ".bits\n}"
                }}"
            }
          }
          .mkString("\n")
    }) + "\n"
  }

  def genCSRBFWriteFunc(csr: CSR): String = {
    (if (csr.width == "64") {
       "function write_" + csr.csrname + "(v : bits(64))" + " -> " + csr.csrname.toUpperCase
     } else if (csr.width == "32") {
       "function write_" + csr.csrname + "(v : bits(32))" + " -> " + csr.csrname.toUpperCase
     } else {
       "function write_" + csr.csrname + "(v : " + csr.width + "BITS)" + " -> " + csr.csrname.toUpperCase
     }) + " = {\n" + "\t" + csr.csrname + " = Mk_" + csr.csrname.toUpperCase + "(v);\n\t" + csr.csrname + "\n}"
  }

  def genCSRWrite(csr: CSR): String = {
    val writeLHS = "function clause write_CSR" + "(" + csr.number + ", value" + ")"
    val writeRHS =
      "{\n" + "\t" + csr.csrname + " = write_" + csr.csrname + "(value);" + "\n\t" + csr.csrname + ".bits" + "\n}"
    writeLHS + " = " + writeRHS
  }

  def genGPRDef(arch: Arch): String = {
    val range = if (arch.extensions.contains("e")) 0 to 15 else 0 to 31
    range.map(i => s"register x$i : XLENBITS").mkString("\n")
  }

  def genGPRRW(arch: Arch): String = {
    def toBinaryString5(i: Int): String = {
      String.format("%5s", i.toBinaryString).replace(' ', '0')
    }

    val range = if (arch.extensions.contains("e")) 0 to 15 else 0 to 31

    range.map { i =>
      s"""function clause read_GPR(0b${toBinaryString5(i)}) = x$i
         |function clause write_GPR(0b${toBinaryString5(i)}, v : XLENBITS) = {
         |\tx$i = v
         |}
         |""".stripMargin
    }.mkString
  }

  def genCSRRegDef(csrs: Seq[CSR]): String = {
    csrs.map(csr => s"register ${csr.csrname}\t\t\t\t: ${csr.csrname.toUpperCase}\n").mkString
  }

  def genArchStatesDef(arch: Arch, csrs: Seq[CSR]): Unit = {
    val archStatesPath = outputDir / "arch" / "ArchStates.sail"

    os.write.over(
      archStatesPath,
      "// GPRs\n" +
        genGPRDef(arch) + "\n" +
        "// CSRs\n" +
        genCSRRegDef(csrs) + "\n" +
        "// PC\n" +
        "register PC : XLENBITS\n" +
        "// Privilege\n" +
        "register cur_privilege : Privilege\n"
    )
  }

  def genCSRBFDef(csrs: Seq[CSR]): Unit = {
    val csrBFPath = outputDir / "arch" / "ArchStateCsrBF.sail"

    os.write.over(csrBFPath, csrs.map(csr => genCSRBitfields(csr) + "\n\n"))
  }

  def genArchStatesReset(arch: Arch, csrs: Seq[CSR]): Unit = {
    val archStatesPath = outputDir / "arch" / "ArchStatesReset.sail"

    val range = if (arch.extensions.contains("e")) 0 to 15 else 0 to 31

    // generate reset
    os.write.over(
      archStatesPath,
      "// GPRs\n" +
        (
          range
            .map(i =>
              s"""val get_resetval_x${i} = pure "get_resetval_x${i}" : unit -> """
                + (if (arch.xlen == 32) "bits(32)"
                   else "bits(64)")
            )
            .mkString("\n")
            + "\n"
            + range
              .map(i => s"function reset_x$i() : unit -> unit = { x$i = get_resetval_x$i(); }")
              .mkString("\n")
        ) +
        "\n" +
        "// CSRs\n" +
        csrs
          .map(csr =>
            s"""val get_resetval_${csr.csrname} = pure "get_resetval_${csr.csrname}" : unit -> """
              + (if (csr.width == "32") "bits(32)"
                 else "bits(64)")
          )
          .mkString("\n")
        + "\n"
        + csrs
          .map(csr => s"""function reset_${csr.csrname}() : unit -> unit = {
                         |\t${csr.csrname} = Mk_${csr.csrname.toUpperCase}(get_resetval_${csr.csrname}())
                         |}""".stripMargin)
          .mkString("\n")
    )

    // generate overall reset
    os.write.append(
      archStatesPath,
      "\n" +
        "function reset() : unit -> unit = {\n" +
        (
          range.map(i => s"\treset_x$i();").mkString("\n")
        ) +
        "\n" +
        csrs.map(csr => s"\treset_${csr.csrname}();").mkString("\n") +
        "\n}"
    )
  }

  def genArchStatesRW(arch: Arch, csrs: Seq[CSR]): Unit = {
    val archStatesPath = outputDir / "arch" / "ArchStatesRW.sail"

    os.write.over(
      archStatesPath,
      "// GPRs\n" +
        genGPRRW(arch) +
        "\n" +
        "// CSRs\n" +
        csrs
          .map(csr =>
            genCSRBFBitGet(csr) +
              "\n" +
              genCSRRead(csr) +
              "\n" +
              genCSRBFBitSet(csr) +
              "\n" +
              genCSRBFWriteFunc(csr) +
              "\n" +
              genCSRWrite(csr) +
              "\n"
          )
          .mkString
    )
  }

  def genExtEnable(arch: Arch): Unit = {
    val extPath = outputDir / "arch" / "ArchStatesPrivEnable.sail"
    os.makeDir.all(extPath / os.up)

    os.write.over(
      extPath,
      arch.extensions
        .map(ext => s"function clause extensionEnabled(Ext_${ext.toUpperCase}) = true\n")
        .mkString
    )
  }

  def genRVXLENSail(arch: Arch): Unit = {
    val xlenPath = outputDir / "rv_xlen.sail"

    os.write.over(
      xlenPath,
      s"""type XLEN : Int = ${arch.xlen}
         |type MXLEN : Int = ${arch.xlen}
         |type SXLEN : Int = ${arch.xlen}
         |let XLEN = sizeof(XLEN)
         |let MXLEN = sizeof(MXLEN)
         |let SXLEN = sizeof(SXLEN)
         |type XLENBITS = bits(XLEN)
         |type MXLENBITS = bits(MXLEN)
         |type SXLENBITS = bits(SXLEN)
         |""".stripMargin
    )
  }
}
