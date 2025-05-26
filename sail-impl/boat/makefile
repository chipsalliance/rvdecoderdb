SAMPLE_ELF := $(shell nix build --print-out-paths --no-link '.#sail-riscv.test-elf')/bin/test.elf

.PHONY: boat_sample
boat_sample:
	nix develop '.#sail-riscv.boat.emulator.dev' -c cargo build --bin boat
	./target/debug/boat --elf-path $(SAMPLE_ELF) -vvv

.PHONY: spike_sample
spike_sample:
	nix shell '.#spike' -c \
		spike -m0x80000000:0x20000000,0x40000000:0x20000000 \
		--isa=rv64i --priv=m --log-commits $(SAMPLE_ELF)
