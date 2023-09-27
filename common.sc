// SPDX-License-Identifier: Apache-2.0
// SPDX-FileCopyrightText: 2022 Jiuyang Liu <liu@jiuyang.me>

import mill._
import mill.scalalib._
import mill.scalajslib._

trait RVDecoderDBJVMModule extends ScalaModule {
  override def sources: T[Seq[PathRef]] = T.sources { super.sources() ++ Some(PathRef(millSourcePath / "jvm" / "src"))  }
  def osLibIvy: Dep
  def upickleIvy: Dep
  override def ivyDeps = super.ivyDeps() ++ Some(osLibIvy) ++ Some(upickleIvy)
}

trait RVDecoderDBJVMTestModule extends ScalaModule {
  override def sources: T[Seq[PathRef]] = T.sources { super.sources() ++ Some(PathRef(millSourcePath / "jvm" / "src"))  }
  def dut: RVDecoderDBJVMModule
  override def moduleDeps = super.moduleDeps ++ Some(dut)
}

trait RVDecoderDBJSModule extends ScalaJSModule {
  override def sources: T[Seq[PathRef]] = T.sources { super.sources() ++ Some(PathRef(millSourcePath / "js" / "src"))  }
  def upickleIvy: Dep
  override def ivyDeps = super.ivyDeps() ++ Some(upickleIvy)
}

trait RVDecoderDBTestJSModule extends ScalaJSModule {
  override def sources: T[Seq[PathRef]] = T.sources { super.sources() ++ Some(PathRef(millSourcePath / "js" / "src"))  }
  def dut: RVDecoderDBJSModule
  override def moduleDeps = super.moduleDeps ++ Some(dut)
}
