// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2023 Jiuyang Liu <liu@jiuyang.me>

package org.chipsalliance.rvdecoderdb.parser

object FixedRangeValue {
  def unapply(str: String): Option[FixedRangeValue] = str match {
    case s"${msb}..${lsb}=${value}" =>
      Some(
        new FixedRangeValue(
          msb.toInt,
          lsb.toInt,
          value match {
            case s"0b$bstr" => BigInt(bstr, 2).toInt
            case s"0x$xstr" => BigInt(xstr, 16).toInt
            case dstr       => dstr.toInt
          }
        )
      )
    case _ => None
  }
}

class FixedRangeValue(val msb: Int, val lsb: Int, val value: Int) extends Token {
  override def toString: String = s"$msb..$lsb=$value"
}
