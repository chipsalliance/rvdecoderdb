// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb

import os.Path
import org.chipsalliance.rvdecoderdb.{Instruction, InstructionSet}

package object parser {
  def parse(opcodeFiles: Iterable[(os.Path, Boolean, Boolean)]): Iterable[Instruction] = {
    val rawInstructionSets = opcodeFiles.map {
      case (f, ratified, custom) =>
        RawInstructionSet(
          f.baseName,
          ratified,
          custom,
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
            )
            .map(new RawInstruction(_))
        )
    }
    // for general instructions which doesn't collide.
    val instructionSetsMap = collection.mutable.HashMap.empty[String, Seq[String]]
    val ratifiedMap = collection.mutable.HashMap.empty[String, Boolean]
    val customMap = collection.mutable.HashMap.empty[String, Boolean]
    val encodingMap = collection.mutable.HashMap.empty[String, org.chipsalliance.rvdecoderdb.Encoding]
    // for pseudo instructions, they only exist in on instruction set, and pseudo from another general instruction
    // thus key should be (set:String, name: String)
    val pseudoFromMap = collection.mutable.HashMap.empty[(String, String), String]
    val pseudoCustomMap = collection.mutable.HashMap.empty[(String, String), Boolean]
    val pseudoRatifiedMap = collection.mutable.HashMap.empty[(String, String), Boolean]
    val pseudoEncodingMap = collection.mutable.HashMap.empty[(String, String), org.chipsalliance.rvdecoderdb.Encoding]

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
          customMap.update(rawInst.name, set.custom)
          encodingMap.update(rawInst.name, rawInst.encoding)
        case rawInst: RawInstruction if rawInst.pseudoInstruction.isDefined =>
          val k = (set.name, rawInst.name)
          pseudoFromMap.update(k, rawInst.pseudoInstruction.get._2)
          pseudoRatifiedMap.update(k, set.ratified)
          pseudoCustomMap.update(k, set.custom)
          pseudoEncodingMap.update(k, rawInst.encoding)
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

    val instructions = encodingMap.keys.map(instr =>
      Instruction(
        instr,
        encodingMap(instr),
        instructionSetsMap(instr).map(InstructionSet.apply),
        None,
        ratifiedMap(instr),
        customMap(instr)
      )
    )

    val pseudoInstructions = pseudoEncodingMap.keys.map(instr =>
      Instruction(
        instr._2,
        pseudoEncodingMap(instr),
        Seq(InstructionSet(instr._1)),
        Some(
          instructions
            .filter(_.name == pseudoFromMap(instr))
            .headOption
            .getOrElse(throw new Exception("pseudo not found"))
        ),
        pseudoRatifiedMap(instr),
        pseudoCustomMap(instr)
      )
    )

    instructions ++ pseudoInstructions
  }
}
