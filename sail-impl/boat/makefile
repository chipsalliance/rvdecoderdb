SAMPLE_ELF := $(shell nix build --print-out-paths --no-link '.#sail-riscv.test-elf')/bin/test.elf

.PHONY: boat_sample
boat_sample:
	nix develop '.#sail-riscv.boat.emulator.dev' -c cargo build --bin boat
	./target/debug/boat --elf-path $(SAMPLE_ELF) -vvv
