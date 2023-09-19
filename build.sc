// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2022 Jiuyang Liu <liu@jiuyang.me>

import mill._
import mill.scalalib._
import mill.scalalib.scalafmt._

import $file.common

object v {
  val scala = "2.13.12"
  val pprint = ivy"com.lihaoyi::pprint:0.8.1"
}

object rvdecoderdb extends common.RVDecoderDBModule with ScalafmtModule { m =>
  def millSourcePath = os.pwd / "rvdecoderdb"
  def scalaVersion = T(v.scala)
  def pprintIvy = v.pprint
}
