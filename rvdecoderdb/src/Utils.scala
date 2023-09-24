// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb

object Utils {
  def isR(instruction: Instruction) = instruction.args.map(_.name) == Seq("rd", "rs1", "rs2")
  def isI(instruction: Instruction) = instruction.args.map(_.name) == Seq("rd", "rs1", "imm12")
  def isS(instruction: Instruction) = instruction.args.map(_.name) == Seq("imm12lo", "rs1", "rs2", "imm12hi")
  def isB(instruction: Instruction) = instruction.args.map(_.name) == Seq("bimm12lo", "rs1", "rs2", "bimm12hi")
  def isU(instruction: Instruction) = instruction.args.map(_.name) == Seq("rd", "imm20")
  def isJ(instruction: Instruction) = instruction.args.map(_.name) == Seq("rd", "jimm20")
  def isR4(instruction: Instruction) = instruction.args.map(_.name) == Seq("rd", "rs1", "rs2", "rs3")
}
