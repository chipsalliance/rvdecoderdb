// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb

import org.chipsalliance.rvdecoderdb.{Instruction, InstructionSet}

object fromFile {
  /** Parse instructions from riscv/riscv-opcodes */
  def apply(riscvOpcodes: os.Path, custom: Iterable[os.Path] = Seq.empty): Iterable[Instruction] = {
    require(os.isDir(riscvOpcodes), "riscvOpcodes should be a folder clone from git@github.com:riscv/riscv-opcodes")
    parser.parse(os
      .walk(riscvOpcodes)
      .filter(f =>
        f.baseName.startsWith("rv128_") ||
          f.baseName.startsWith("rv64_") ||
          f.baseName.startsWith("rv32_") ||
          f.baseName.startsWith("rv_")
      )
      .filter(os.isFile)
      .map(f => (f.baseName, os.read(f), !f.segments.contains("unratified"), false)) ++
      custom
        .map(f => (f.baseName, os.read(f), false, true)))
  }
}

