// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb.test

object Test extends App {
  org.chipsalliance.rvdecoderdb.fromFile(os.pwd / "rvdecoderdbtest" / "jvm"  / "riscv-opcodes").foreach(println)
}
