// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2022 Jiuyang Liu <liu@jiuyang.me>

import mill._
import mill.scalalib._

trait RVDecoderDBModule extends ScalaModule {
  def osLibIvy: Dep

  override def ivyDeps = super.ivyDeps() ++ Some(osLibIvy)
}

trait RVDecoderDBTestModule extends ScalaModule {
  def rvdecoderdbModule: RVDecoderDBModule
  def pprintIvy: Dep

  override def moduleDeps = super.moduleDeps ++ Some(rvdecoderdbModule)
  override def ivyDeps = super.ivyDeps() ++ Some(pprintIvy)
}
