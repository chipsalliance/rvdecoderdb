// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>
package org.chipsalliance.rvdecoderdb

import os.Path
import org.chipsalliance.rvdecoderdb

object Test extends App {
  parser
    .parse(
      os
        .walk(os.pwd / "dependencies" / "riscv-opcodes")
        .filter(f =>
          f.baseName.startsWith("rv128_") ||
            f.baseName.startsWith("rv64_") ||
            f.baseName.startsWith("rv32_") ||
            f.baseName.startsWith("rv_")
        )
    )
    .foreach(pprint.pprintln(_))
}
