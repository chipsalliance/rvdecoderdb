// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2022 Jiuyang Liu <liu@jiuyang.me>

import mill._
import mill.scalalib._

trait RVDecoderDBModule extends ScalaModule {
  def pprintIvy: Dep
  def osLibIvy: Dep

  override def ivyDeps = super.ivyDeps() ++ Some(pprintIvy) ++ Some(osLibIvy)
}
