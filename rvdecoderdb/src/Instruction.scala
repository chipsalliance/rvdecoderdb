// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb

/** Like chisel3.BitPat, this is a 32-bits field stores the Instruction encoding. */
case class Encoding(value: BigInt, mask: BigInt) {
  def merge(that: Encoding) = new Encoding(value + that.value, mask + that.mask)
  override def toString =
    Seq.tabulate(32)(i => if (!mask.testBit(i)) "?" else if (value.testBit(i)) "1" else "0").mkString
}

case class Arg(name: String) {
  val (msb: Int, lsb: Int) = name match {
    case "rd" => (11, 7)
    case "rt" => (19, 15)
    case "rs1" => (19, 15)
    case "rs2" => (24, 20)
    case "rs3" => (31, 27)
    case "aqrl" => (26, 25)
    case "aq" => (26, 26)
    case "rl" => (25, 25)
    case "fm" => (31, 28)
    case "pred" => (27, 24)
    case "succ" => (23, 20)
    case "rm" => (14, 12)
    case "funct3" => (14, 12)
    case "funct2" => (26, 25)
    case "imm20" => (31, 12)
    case "jimm20" => (31, 12)
    case "imm12" => (31, 20)
    case "csr" => (31, 20)
    case "imm12hi" => (31, 25)
    case "bimm12hi" => (31, 25)
    case "imm12lo" => (11, 7)
    case "bimm12lo" => (11, 7)
    case "zimm" => (19, 15)
    case "shamtq" => (26, 20)
    case "shamtw" => (24, 20)
    case "shamtw4" => (23, 20)
    case "shamtd" => (25, 20)
    case "bs" => (31, 30)
    case "rnum" => (23, 20)
    case "rc" => (29, 25)
    case "imm2" => (21, 20)
    case "imm3" => (22, 20)
    case "imm4" => (23, 20)
    case "imm5" => (24, 20)
    case "imm6" => (25, 20)
    case "opcode" => (6, 0)
    case "funct7" => (31, 25)
    case "vd" => (11, 7)
    case "vs3" => (11, 7)
    case "vs1" => (19, 15)
    case "vs2" => (24, 20)
    case "vm" => (25, 25)
    case "wd" => (26, 26)
    case "amoop" => (31, 27)
    case "nf" => (31, 29)
    case "simm5" => (19, 15)
    case "zimm5" => (19, 15)
    case "zimm10" => (29, 20)
    case "zimm11" => (30, 20)
    case "zimm6hi" => (26, 26)
    case "zimm6lo" => (19, 15)
    case "c_nzuimm10" => (12, 5)
    case "c_uimm7lo" => (6, 5)
    case "c_uimm7hi" => (12, 10)
    case "c_uimm8lo" => (6, 5)
    case "c_uimm8hi" => (12, 10)
    case "c_uimm9lo" => (6, 5)
    case "c_uimm9hi" => (12, 10)
    case "c_nzimm6lo" => (6, 2)
    case "c_nzimm6hi" => (12, 12)
    case "c_imm6lo" => (6, 2)
    case "c_imm6hi" => (12, 12)
    case "c_nzimm10hi" => (12, 12)
    case "c_nzimm10lo" => (6, 2)
    case "c_nzimm18hi" => (12, 12)
    case "c_nzimm18lo" => (6, 2)
    case "c_imm12" => (12, 2)
    case "c_bimm9lo" => (6, 2)
    case "c_bimm9hi" => (12, 10)
    case "c_nzuimm5" => (6, 2)
    case "c_nzuimm6lo" => (6, 2)
    case "c_nzuimm6hi" => (12, 12)
    case "c_uimm8splo" => (6, 2)
    case "c_uimm8sphi" => (12, 12)
    case "c_uimm8sp_s" => (12, 7)
    case "c_uimm10splo" => (6, 2)
    case "c_uimm10sphi" => (12, 12)
    case "c_uimm9splo" => (6, 2)
    case "c_uimm9sphi" => (12, 12)
    case "c_uimm10sp_s" => (12, 7)
    case "c_uimm9sp_s" => (12, 7)
    case "c_uimm2" => (6, 5)
    case "c_uimm1" => (5, 5)
    case "c_rlist" => (7, 4)
    case "c_spimm" => (3, 2)
    case "c_index" => (9, 2)
    case "rs1_p" => (9, 7)
    case "rs2_p" => (4, 2)
    case "rd_p" => (4, 2)
    case "rd_rs1_n0" => (11, 7)
    case "rd_rs1_p" => (9, 7)
    case "rd_rs1" => (11, 7)
    case "rd_n2" => (11, 7)
    case "rd_n0" => (11, 7)
    case "rs1_n0" => (11, 7)
    case "c_rs2_n0" => (6, 2)
    case "c_rs1_n0" => (11, 7)
    case "c_rs2" => (6, 2)
    case "c_sreg1" => (9, 7)
    case "c_sreg2" => (4, 2)
  }

  override def toString: String = name
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
  args:            Seq[Arg],
  instructionSets: Seq[InstructionSet],
  pseudoFrom:      Option[Instruction],
  ratified:        Boolean,
  custom:          Boolean) {
  require(!custom || (custom && !ratified), "All custom instructions are unratified.")
  override def toString: String =
    Option.when(custom)("[CUSTOM]").getOrElse(Option.when(!ratified)("[UNRATIFIED]").getOrElse("")).padTo(16, ' ') +
      pseudoFrom.map(p => s"[pseudo ${p.name}]").getOrElse("").padTo(24, ' ') +
      name.padTo(24, ' ') +
      s"[${
        Seq(
          Option.when(Utils.isR(this))("R "),
          Option.when(Utils.isR4(this))("R4"),
          Option.when(Utils.isI(this))("I "),
          Option.when(Utils.isS(this))("S "),
          Option.when(Utils.isB(this))("B "),
          Option.when(Utils.isU(this))("U "),
          Option.when(Utils.isJ(this))("J ")
        ).flatten.headOption.getOrElse("  ")
      }]".padTo(4, ' ') +
      args.mkString(",").padTo(40, ' ') +
      encoding.toString.padTo(48, ' ') +
      s"in {${instructionSets.map(_.name).mkString(", ")}}"
}
