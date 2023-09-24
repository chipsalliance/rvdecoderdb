// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb.test

import org.chipsalliance.rvdecoderdb.Instruction

object Test extends App {
  Instruction.parse(os.pwd / "rvdecoderdbtest" / "riscv-opcodes").foreach(println)
}
