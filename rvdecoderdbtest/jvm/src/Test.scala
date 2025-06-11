// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

object printall extends App {
  org.chipsalliance.rvdecoderdb.instructions(os.Path(sys.env("RISCV_OPCODES_PATH"))).foreach(println)
}

object json extends App {
  org.chipsalliance.rvdecoderdb
    .instructions(os.pwd / "rvdecoderdbtest" / "jvm" / "riscv-opcodes")
    .foreach(i => println(upickle.default.write(i)))
}
