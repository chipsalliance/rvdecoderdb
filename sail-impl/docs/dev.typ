= Development Notes

== Gloassary

#table(
  columns: 2,
  [*Name*], [*Notes*],
  [boat], [_boat_ is the emulator utilizing the user provided _sail_impl_ RISC-V models to drive a RISC-V Core],
  [Sail], [The #link("https://github.com/rems-project/sail")[rems-project/sail] project. This document will ofter use "Sail" to refer to the Sail Project, Sail Programming Language and Sail CLI tools],
  [sail_impl], [_sail_impl_ reference to this project, which should provide a Sail implemented RISC-V execution model, from instruction description to register status.],
  [sailcodegen], [A Scala implemented Sail code generator],
)

== Architecture

This project use _sail_ to write RISC-V ISA representation. And use the _sail_
toolchain to generate C codes that can be used to interact with the RISC-V ISA
model.
All the _sail_ implementation now stay in `csr/`, `inst/`, `rvcore/` folders.

For architecture states, there are `sailcodegen` CLI help generating all
required _sail_ code based on current _sail_impl_ `march` information.
This information is provided by `sail-impl-meta.json` at the root directory of
a _sail_impl_.

Currently Emulator are written using Rust programming language.

== Implementation Required at Emulator side

Each _sail_impl_ should deliver a `sail_impl.h` file.
This file has two main usage: help compiler found declaration so that we can
pre-compile Sail model as a static library, and act as a specification for
emulator side to know what functions are required by _Sail_ model but missing
implementation.

View details in `sail_impl.h`.

- memory interaction
- reset
- instruction fetch
- registers and CSR initialization
- de-init

== Sail FFI

To init a Sail model, drive the Sail model to consume each instruction, read model stats,
we will need to manually call the generated functions. These are function that
already has implementation on Sail side, so all we need to do is to write a
Rust FFI crate for it. Each model should provide a `sail_expose.h` C header file
consumed by _rust-bindgen_. This header file will act as a API level language
bridge across C and emulator side, specify and limit what functionality
emulator side can and should use.

== Current Issues

- Sail header contains 128bit integer which is not FFI-safe
- How to write memory? How to allocate and distribute memory address space?
- writemem argument should not be int64_t, it should be a bit array.
