// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb.parser

import os.Path
import org.chipsalliance.rvdecoderdb.{Instruction, InstructionSet}

trait Token

class Parser(opcodeFiles: Seq[os.Path]) {
  val rawInstructionSets: Seq[RawInstructionSet] = opcodeFiles.map(f =>
    RawInstructionSet(
      f.baseName,
      !f.segments.contains("unratified"),
      os.read
        .lines(f)
        .filter(!_.startsWith("#"))
        .filter(_.nonEmpty)
        .map(
          _.split(" ")
            .filter(_.nonEmpty)
            .map {
              case "$import"          => Import
              case "$pseudo_op"       => PseudoOp
              case RefInst(i)         => i
              case FixedRangeValue(f) => f
              case BitValue(b)        => b
              case ArgLUT(a)          => a
              case BareStr(i)         => i
            }
            .toSeq
        )
        .map(new RawInstruction(_))
    )
  )
  val instructionSetsMap = collection.mutable.HashMap.empty[String, Seq[String]]
  val ratifiedMap = collection.mutable.HashMap.empty[String, Boolean]
  val encodingMap = collection.mutable.HashMap.empty[String, org.chipsalliance.rvdecoderdb.Encoding]
  val pseudoMap = collection.mutable.HashMap.empty[String, String]

  // create normal instructions
  rawInstructionSets.foreach { set: RawInstructionSet =>
    set.rawInstructions.foreach {
      case rawInst: RawInstruction if rawInst.isNormal =>
        require(
          instructionSetsMap.get(rawInst.name).isEmpty,
          s"redefined instruction: ${rawInst.name} in ${instructionSetsMap(rawInst.name).head} and ${set.name}"
        )
        instructionSetsMap.update(rawInst.name, Seq(set.name))
        ratifiedMap.update(rawInst.name, set.ratified)
        encodingMap.update(rawInst.name, rawInst.encoding)
      case _ =>
    }
  }

  // imported_instructions - these are instructions which are borrowed from an extension into a new/different extension/sub-extension. Only regular instructions can be imported. Pseudo-op or already imported instructions cannot be imported.
  rawInstructionSets.foreach { set: RawInstructionSet =>
    set.rawInstructions.foreach {
      case rawInst: RawInstruction if rawInst.importInstructionSet.isDefined =>
        instructionSetsMap.filter(_._2.head == rawInst.importInstructionSet.get).map {
          case (k, v) =>
            instructionSetsMap.update(k, v ++ Some(set.name))
        }
      case rawInst: RawInstruction if rawInst.importInstruction.isDefined =>
        val k = rawInst.importInstruction.get._2
        val v = instructionSetsMap(k)
        instructionSetsMap.update(k, v ++ Some(set.name))
      case _ =>
    }
  }

  // TODO: pseudo ops

  val instructions = encodingMap.keys.map(instr =>
    Instruction(
      instr,
      encodingMap(instr),
      instructionSetsMap(instr).map(InstructionSet.apply),
      None,
      ratifiedMap(instr)
    )
  )
}

object Test extends App {
  val opcodeFiles: IndexedSeq[Path] = os
    .walk(os.pwd / "dependencies" / "riscv-opcodes")
    .filter(f =>
      f.baseName.startsWith("rv128_") ||
        f.baseName.startsWith("rv64_") ||
        f.baseName.startsWith("rv32_") ||
        f.baseName.startsWith("rv_")
    )
  new Parser(opcodeFiles).instructions.foreach(pprint.pprintln(_))
}
