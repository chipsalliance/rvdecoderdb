#import "./style.typ": *

#show: project.with(
  doc-category: "Manual",
  doc-title: "Sail RISC-V Coding Guidance",
  author: "Jiongjia Lu",
  affiliation: "Chipsalliance T1 Team",
)
#let projectName = "This project"

= Abstract

#projectName is a RISC-V ISA model implementation using Sail. We want the
flexibility to opt-in a new instruction set, and gain maintainability from
simple design, which is not available from `riscv/sail-riscv` and
`riscv/riscv-isa-sim` (spike) now.

This document aims to help developers understand the example Sail model
implementation and act as a guidance for how to fix bugs, add new instruction,
add new architecture, or create a new model based on this project. For
developers who don't understand Sail and Sail tool-chain, we also provide some
additional document upon official manual.

Currently the example project support `rv64gc`.

= Introduction

== How to build this document

Typst 0.13.1 is required.

```bash
typst compile ./docs/dev.typ ./docs/rendered.pdf
```

== Resources

- ISA Resources: https://five-embeddev.com/riscv-isa-manual/
- `riscv/riscv-opcodes`: https://github.com/riscv/riscv-opcodes
- Sail language manual: https://alasdair.github.io/manual.html

== Glossary

#table(
  columns: 2,
  [*Name*], [*Notes*],
  [boat], [_boat_ is the emulator utilizing the user provided _sail_impl_ RISC-V models to drive a RISC-V Core],
  [Sail], [The #link("https://github.com/rems-project/sail")[rems-project/sail] project. This document will ofter use "Sail" to refer to the Sail Project, Sail Programming Language and Sail CLI tools],
  [sail-impl], [_sail-impl_ reference to this project, which should provide a Sail implemented RISC-V execution model, from instruction description to register status.],
  [sailcodegen], [A Scala implemented Sail code generator],
)

== Designs

The #projectName project employs a distinct methodology compared to standard
Sail projects. To enhance maintainability, the Instruction Set Architecture
(ISA) model definition is segmented into multiple code snippets. A CLI tool for
code generation is then utilized to assemble the complete Sail code from these
snippets. This approach allows each instruction to be defined in an individual
file, thereby creating a singular, reviewable unit of code.

All architectural states are consolidated and managed within a separate,
dedicated file. We have a guiding principle that each Sail model should
exclusively define architectural states. Any interactions with hardware or the
underlying system are exposed through an external C Application Programming
Interface (API). For code readability, these hardware interactions, such as
memory read and write operations, must be declared in a designated Sail file,
accompanied by a corresponding C header file.

We advocate for minimizing the amount of C code. The C code should primarily
function as an intermediary layer, connecting the Sail ISA model with the
emulator. Consequently, developers should make every effort to avoid creating
and linking additional C libraries.

The explicitly defined C API enables the use of nearly any programming language
that supports a Foreign Function Interface (FFI) to implement hardware behaviors
not defined in the ISA specification. For #projectName, the Rust programming
language was selected to develop the emulator. This choice was driven by Rust's
design simplicity and the readability of its code. Furthermore, the Rust
community provides robust compiler tool-chains, which helps to reduce the time
spent on configuring and managing the build system.

= Codegen CLI



= Model
This section covers detail implementation and coding guidance for a Sail ISA model.

== Instruction behavior
All ISA behavior describe file are placed under `model` directory.

Instruction behavior definition files are separated by instruction name, and
grouped by their corresponding instruction sets. The instruction sets group
rule follows `riscv/riscv-opcodes`. For example, load word instruction `lw`
should be placed under `rv_i` directory, and load double word instruction `ld`
should be placed under `rv64_i` directory. Developers can check
https://github.com/riscv/riscv-opcodes/tree/master/extensions for details.

Each file is treated as function body. The Sail code-gen CLI will traverse the
`model/<extension>` directory and generate function signature for all the
files. So developers can consider writing instruction file is in a function
context, with arguments like global built-in value binding and some prelude
function imported. The Sail code-gen CLI generate the function argument using
encoding specified in riscv-opcodes.

For example, when developers try to add `addiw` instruction, their should check
#link("https://github.com/riscv/riscv-opcodes/blob/master/extensions/rv64_i")[
  rv64_i encoding file
] for the instruction encoding. And as we can see, `addiw` is a instruction in
rv64_i instruction sets, so developers should create a `addiw` file under `rv64_i`
directory. Then as riscv-opcodes shown, `addiw` has three variable fields: `rd`, `rs1`,
and `imm12`, these fields will be generated as Sail function arguments, and available
in each file context. At runtime, they will be the bits vector value extracted from
instruction decode result.

So developers can have following implementation for `addiw` behavior.

```sail
let result : XLENBITS = sign_extend(imm12) + read_GPR(rs1);
write_GPR(rd, sign_extend(result[63..0]));
tick_pc();
```

- `XLENBITS`: A prelude bits type with pre-defined length. In the context of rv64,
it is set as `bits(64)`.
- `sign_extend`: A prelude function that do a sign extend to the value.
- `imm12`: function arguments that will be generated at build time.
- `read_GPR`: A prelude function that read general purpose register file by id.
- `rs1`: function arguments that will be generated at build time.
- `write_GPR`: A prelude function that will write general purpose register file with given data.
- `tick_pc`: A prelude function that will increase the `PC`.

After code-gen phase, we will have following Sail function generated for executing
`addiw` when decoding match:

```sail
union clause ast = ADDIW : (bits(5), bits(5), bits(12))
mapping clause encdec = ADDIW(rd, rs1, imm12) <-> imm12 @ rs1 @ 0b000 @ rd @ 0b0011011
function clause execute (ADDIW(rd, rs1, imm12)) = {
	let result : XLENBITS = sign_extend(imm12) + read_GPR(rs1);
	write_GPR(rd, sign_extend(result[63..0]));
	tick_pc();
}
```

== CSR

CSR implementation is architecture specific and thus Sail code should be
categorized in another directory. Our codegen CLI will try to find CSR implementation
at "csr" directory under model directory.

Each CSR implementation should be a separated file with CSR name suffix with
".sail" extension as its filename. Each file should have a read and write
functions with following signature:

- `function clause read_CSR(<csr number>) : XLENBITS`
- `function clause write_CSR(<csr number>, value: XLENBITS): (bits(12), XLENBITS) -> XLENBITS`
- `function reset_<csr name>() : unit -> unit`

The `scattered function` definition is generated by codegen CLI, developers
doesn't need to declare it again.

Also for each CSR implementation, developers should define bit-fields as
separated register for saving register space. This Sail implementation means to
be a hardware implementation reference. Always using `XLEN` bits CSR register
is expensive at hardware side.

For example, when we writing `misa` implementation for `rv64i` M-mode only architecture,
we will have following Sail code:

- `MXL` field is read-only, so we don't need to allocate register for it
- `misa[MXLEN-3:26]` is read-only zero, so we don't need to allocate register for it
- we have only `rv64i` implementation, so what we need is only "I" and "E" bits
-  the "E" bit always reads as the complement of the "I" bit.

```sail
// model/csr/misa.sail

bitfield misa_state : bits(1) = {
  I : 0
}

// following Sail convention, we use upper case for bitfield register here
register MISA : misa_state

// search priviledge spec 2.2 Table7 for CSR Listing
function clause read_CSR(0x301) = {
  // MXL @ 9 x 4 zero bit @ extension
  let read_only : bits(36) = zero_extend(0b0);
  let z_to_i : bits(17) = zero_extend(0b0);
  let misa_e : bits(1) = ~(MISA[I]);
  0b10 @ read_only @ z_to_i @ MISA[I] @ 0b000 @ misa_e @ 0x0
}

function clause write_CSR(0x301, value: XLENBITS) = {
  MISA[I] = [value[8]];
  true
}

function reset_misa() = {
  MISA = [Mk_MISA(zeros()) with I = 1];
}
```

Additional notes:

- Function `zeros` is provided in prelude library, it can generate bit vector with expected length filled with zeros
- Function `Mk_MISA` is undocumented constructor that will be generated by Sail compiler for bit fields.
  It is actually a wrapper like `function Mk_MISA(v) = struct { bits = v }`.

== FFI Interface
The model implementation is required to provide a C header file
named "model_prelude.h". All external functions necessary for the model's
operation should be defined within this file. This serves as a clear reference
for emulator developers, informing them of the specific APIs that the Sail model
relies upon and that, consequently, need to be implemented on the emulator side.

== "Global" functions
Each instruction description file is a lonely individual file. Since these instruction description
file will finally be assembled into one Sail file, there all have corresponding context.

This section instruct you all the possible context when defining a instruction.

- All the library functions: TODO: jump to library section
- Registers defined at riscv-opcodes TODO: explain possible register name trim

== Provided library functions

=== Memory Read/Write API
Following are required memory operation that should be implemented at emulator side:
#table(
  columns: 3,
  [*Name*], [*Type*], [*Description*],
  [`phy_read_byte`],
  [`bits(64) -> bits(8)`],
  [`[phy_read_byte address]` is the value of the byte at physical `[address]`],

  [`phy_read_half_word`],
  [`bits(64) -> bits(16)`],
  [`[phy_read_half address]` is two bytes value starting at physical `[address]`],

  [`phy_read_word`],
  [`bits(64) -> bits(32)`],
  [`[phy_read_word address]` is word length value starting at physical `[address]`],

  [`phy_read_double_word`],
  [`bits(64) -> bits(64)`],
  [`[phy_read_double_word address]` is the 64-bit value starting at physical `[address]`],

  [`phy_write_byte`],
  [`bits(64) -> bits(8) -> unit`],
  [`[phy_write_byte address value]` write byte `[value]` to physical `[address]`],

  [`phy_write_half_word`],
  [`bits(64) -> bits(16) -> unit`],
  [`[phy_write_half address value]` write two bytes value to physical `[address]`],

  [`phy_write_word`],
  [`bits(64) -> bits(32) -> unit`],
  [`[phy_write_word address value]` write word length value to physical `[address]`],

  [`phy_write_double_word`],
  [`bits(64) -> bits(64) -> unit`],
  [`[phy_write_double_word address value]` write 64-bit value to physical `[address]`],
)

= Emulator
== Development notes
To have rust-analyzer and compiled Sail RISC-V model in environment, users can set the `$EDITOR` environment
and run `make dev` in sail-impl/boat directory.

== Test notes
In "sail-impl/boat" directory, run `make` with following targets:
- run a demo with boat emulator: `make boat_demo`
- run a demo with spike emulator: `make spike_demo`
- run a demo with difftest: `make difftest_demo`

== Logging usage
The `sail-ffi` crate is a library crate used for composing a emulator, thus
logging should always use `Level::DEBUG` and `Level::TRACE` only. `Level::INFO`
and error handling shoule be up lifting to emulator application side.

All architecture states change should be recorded with `TRACE` level event and
contains `event_type` and `action` field for other software to easily
de-serialize to corresponding data type.

Current implementation contains following event type:

=== physical_memory

For "physical_memory" event type, current implementation records following fields:

- `action`: a text value indicate current action to physical memory. Possible value: *"read"*, *"write"*.
- `bytes`: a integer value indicate the total bytes get operated on physical memory. Possible value: *1,2,4,8*.
- `address`: a 64-bit integer value indicate the start address of this action to the physical memory.
- `data`: a debug value in text indicating the value read from or write to the physical value.
- `message`: optional text value with human readable emulator status attached

=== arch_state

For "arch_state" event type, current implementation records following fields:

- `action`: a text value indicate current action to architecture states. Possible value: *"register_update"*.
- `pc`: a 64-bit integer value indicate the current PC of this action.
- `reg_idx`: if current action is "register_update", `reg_idx` is a integer number represent the index of the changed register.
- `data`: if current action is "register_update", `data` is a 64-bit integer showing the data ready to be written to register.
- `message`: optional text value with human readable emulator status attached

=== reset_vector

This event occurs when Sail model `PC` register get explicitly updated.
For *reset_vector* event type, current implementation records following fields:

- `new_addr`: a 64-bit integer value indicate the new PC.

All event unrelated but useful for knowing `sail-ffi` running status should be logging with `Level::DEBUG`.

== Sail FFI

To initialize a Sail model, drive it to process each instruction, and read model
statistics, it is necessary to call generated functions and access Sail values
at runtime from the emulator.

However, directly accessing C values from Rust can introduce multiple safety
issues and complicate side-effect management.

To establish clear referencing and limitations, each emulator implementation
must provide a sail_prelude.h C header file. This header file will function as
an API-level language bridge between C and the emulator, specifying and
restricting the functionalities the emulator side can and should utilize. All
exposed functions and values must be kept private within a Rust module.
Developers are required to manually write corresponding wrapper functions for
all these FFI values and functions, rather than exposing them directly outside
the Rust crate.

=== Required value from Sail

#table(
  columns: 3,
  [*Signature*], [*Type*], [*Notes*],
  [`unit`], [value type], [Unit type defined at Sail side],
  [`march_bits`], [value type], [Machine word length],
  [`zstep :: unit -> unit`], [function type], [Run one step for fetch-decode-execute loop],
  [`model_init :: void -> void`], [function type], [Initialize all registers],
)
