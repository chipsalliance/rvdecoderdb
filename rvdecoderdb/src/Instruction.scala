// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb

/** Like chisel3.BitPat, this is a 32-bits field stores the Instruction encoding. */
case class Encoding(value: BigInt, mask: BigInt) {
  def merge(that: Encoding) = new Encoding(value + that.value, mask + that.mask)
  override def toString =
    Seq.tabulate(32)(i => if (!mask.testBit(i)) "?" else if (value.testBit(i)) "1" else "0").mkString
}

/** represent an riscv sub instruction set, aka a file in riscv-opcodes. */
case class InstructionSet(name: String)

/** All information can be parsed from riscv/riscv-opcode.
  * @param name name of this instruction
  * @param encoding encoding of this instruction
  * @param instructionSets base instruction set that this instruction lives in
  * @param pseudoFrom if this is defined, means this instruction is an Pseudo Instruction from another instruction
  * @param ratified true if this instruction is ratified
  */
case class Instruction(
  name:            String,
  encoding:        Encoding,
  instructionSets: Seq[InstructionSet],
  pseudoFrom:      Option[Instruction],
  ratified:        Boolean,
  custom:          Boolean) {
  require(!custom || (custom && !ratified), "All custom instructions are unratified.")
  override def toString: String =
    Option.when(custom)("[CUSTOM]").getOrElse(Option.when(!ratified)("[UNRATIFIED]").getOrElse("")).padTo(16, ' ') +
      pseudoFrom.map(p => s"[pseudo ${p.name}]").getOrElse("").padTo(32, ' ') +
      name.padTo(24, ' ') +
      encoding.toString.padTo(48, ' ') +
      s"in {${instructionSets.map(_.name).mkString(", ")}}"
}

object Instruction {
  /** Parse instructions from riscv/riscv-opcodes */
  def parse(riscvOpcodes: os.Path, custom: Iterable[os.Path] = Seq.empty): Iterable[Instruction] = {
    require(os.isDir(riscvOpcodes), "riscvOpcodes should be a folder clone from git@github.com:riscv/riscv-opcodes")
    parser.parse(
      os
        .walk(riscvOpcodes)
        .filter(f =>
          f.baseName.startsWith("rv128_") ||
            f.baseName.startsWith("rv64_") ||
            f.baseName.startsWith("rv32_") ||
            f.baseName.startsWith("rv_")
        )
        .filter(os.isFile)
        .map(f => (f, !f.segments.contains("unratified"), false)) ++
        custom.map(f => (f, false, true))
    )
  }
}
