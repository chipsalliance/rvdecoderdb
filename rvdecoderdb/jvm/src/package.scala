// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance

/** Parse instructions from riscv/riscv-opcodes */
package object rvdecoderdb {
  def instructions(riscvOpcodes: os.Path, customOpCodes: Iterable[os.Path] = None): Iterable[Instruction] = {
    def isInstructionSetFile(p: os.Path) = {
      if (os.isFile(p)) {
        val base = p.baseName
        base.startsWith("rv128_") ||
          base.startsWith("rv64_") ||
          base.startsWith("rv32_") ||
          base.startsWith("rv_")
      } else {
        false
      }
    }

    val official = os
      .walk(riscvOpcodes)
      .filter(isInstructionSetFile)
      .map(f => (f.baseName, os.read(f), !f.segments.contains("unratified"), false))

    val custom = customOpCodes
      .flatMap(p => {
        if (isInstructionSetFile(p)) {
          Seq((p.baseName, os.read(p), false, true))
        } else {
          os.walk(p)
            .filter(isInstructionSetFile)
            .map(f => (f.baseName, os.read(f), false, true))
        }
      })

    parser.parse(
      official ++ custom,
      argLut(riscvOpcodes, customOpCodes).view.mapValues(a => (a.lsb, a.msb)).toMap
    )
  }

  def argLut(riscvOpcodes: os.Path, customOpCodes: Iterable[os.Path] = None): Map[String, Arg] = {
    def to_args(line: String) = line.replace(", ", ",").replace("\"", "") match {
      case s"$name,$pos0,$pos1" => name -> Arg(name, pos0.toInt, pos1.toInt)
      case lstr                 => throw new Exception(s"invalid arg lut line: ${lstr}")
    }

    val official = os.read
      .lines(riscvOpcodes / "arg_lut.csv")
      .map(to_args)

    val custom = customOpCodes
      .flatMap(p =>
        os.read
          .lines(p / "arg_lut.csv")
          .map(to_args)
      )

    (official ++ custom).toMap
  }

  def causes(riscvOpcodes: os.Path): Map[String, Int] = os
    .read(riscvOpcodes / "causes.csv")
    .split("\n")
    .map { str =>
      val l = str
        .replace(", ", ",")
        .replace("\"", "")
        .split(",")
      l(1) -> java.lang.Long.decode(l(0)).toInt
    }
    .toMap

  def csrs(riscvOpcodes: os.Path): Seq[(String, Int)] =
    Seq(os.read(riscvOpcodes / "csrs.csv"), os.read(riscvOpcodes / "csrs32.csv")).flatMap(
      _.split("\n")
        .map { str =>
          val l = str
            .replace(" ", "")
            .replace("\"", "")
            .replace("\'", "")
            .split(",")
          l(1) -> java.lang.Long.decode(l(0)).toInt
        }
        .toMap
    )

  @deprecated("extractResource is removed")
  def extractResource(cl: ClassLoader): os.Path = {
    val rvdecoderdbPath = os.temp.dir()
    val rvdecoderdbTar  = os.temp(os.read(os.resource(cl) / "riscv-opcodes.tar"))
    os.proc("tar", "xf", rvdecoderdbTar).call(rvdecoderdbPath)
    rvdecoderdbPath
  }

  @deprecated("extractCustomResource is removed")
  def extractCustomResource(cl: ClassLoader): os.Path = {
    val rvdecoderdbPath = os.temp.dir()
    val rvdecoderdbTar  = os.temp(os.read(os.resource(cl) / "riscv-custom-opcodes.tar"))
    os.proc("tar", "xf", rvdecoderdbTar).call(rvdecoderdbPath)
    rvdecoderdbPath
  }

  @deprecated("remove fromFile")
  object fromFile {
    def instructions(riscvOpcodes: os.Path, custom: Iterable[os.Path] = Seq.empty): Iterable[Instruction] =
      rvdecoderdb.instructions(riscvOpcodes, custom)
    def argLut(riscvOpcodes: os.Path):                                              Map[String, Arg]      = rvdecoderdb.argLut(riscvOpcodes)
    def causes(riscvOpcodes: os.Path):                                              Map[String, Int]      = rvdecoderdb.causes(riscvOpcodes)
    def csrs(riscvOpcodes:   os.Path):                                              Seq[(String, Int)]    = rvdecoderdb.csrs(riscvOpcodes)
  }
}
