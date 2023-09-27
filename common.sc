// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2022 Jiuyang Liu <liu@jiuyang.me>

import mill._
import mill.scalalib._
import mill.scalajslib._

trait RVDecoderDBJVMModule extends ScalaModule {
  override def allSources: T[Seq[PathRef]] = T(super.allSources() ++ Some(PathRef(millSourcePath / "jvm")))
  def osLibIvy: Dep
  def upickleIvy: Dep
  override def ivyDeps = super.ivyDeps() ++ Some(osLibIvy) ++ Some(upickleIvy)
}

trait RVDecoderDBJVMTestModule extends ScalaModule {
  override def allSources: T[Seq[PathRef]] = T(super.allSources() ++ Some(PathRef(millSourcePath / "jvm")))
  def dut: RVDecoderDBJVMModule
  override def moduleDeps = super.moduleDeps ++ Some(dut)
}

trait RVDecoderDBJSModule extends ScalaJSModule {
  override def allSources: T[Seq[PathRef]] = T(super.allSources() ++ Some(PathRef(millSourcePath / "js")))
  def upickleIvy: Dep
  override def ivyDeps = super.ivyDeps() ++ Some(upickleIvy)
}

trait RVDecoderDBTestJSModule extends ScalaJSModule {
  override def allSources: T[Seq[PathRef]] = T(super.allSources() ++ Some(PathRef(millSourcePath / "js")))
  def dut: RVDecoderDBJSModule
  override def moduleDeps = super.moduleDeps ++ Some(dut)
}
