// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>
package org.chipsalliance.rvdecoderdb

/** Like chisel3.BitPat, this is a 32-bits field stores the Instruction encoding. */
case class Encoding(value: Int, mask: Int) {
  def merge(that: Encoding) = new Encoding(value + that.value, mask + that.mask)
  override def toString =
    Seq.tabulate(32)(i => if (!BigInt(mask).testBit(i)) "?" else if (BigInt(value).testBit(i)) "1" else "0").mkString
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
  ratified:        Boolean)
