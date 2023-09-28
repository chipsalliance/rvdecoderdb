// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

object printall extends App {
  org.chipsalliance.rvdecoderdb.fromFile.instructions(os.pwd / "rvdecoderdbtest" / "jvm"  / "riscv-opcodes").foreach(println)
}

object json extends App {
  org.chipsalliance.rvdecoderdb.fromFile.instructions(os.pwd / "rvdecoderdbtest" / "jvm"  / "riscv-opcodes").foreach(i => println(upickle.default.write(i)))
}
