SAMPLE_ELF_DIR := $(shell nix build --print-out-paths --no-link '.#sail-riscv.test-elf')
SAMPLE_ELF := $(SAMPLE_ELF_DIR)/bin/test.elf

CURRENT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: boat_sample
boat_sample:
	nix develop '.#sail-riscv.boat.emulator.dev' -c cargo build --bin boat
	$(CURRENT_DIR)/target/debug/boat --elf-path $(SAMPLE_ELF) -vvv

.PHONY: spike_sample
spike_sample:
	nix shell '.#spike' -c \
		spike -m0x80000000:0x20000000,0x40000000:0x20000000 \
		--isa=rv64i --priv=m --log-commits $(SAMPLE_ELF)

.PHONY: difftest_sample
difftest_sample:
	nix develop '.#sail-riscv.boat.emulator.dev' -c cargo build --bin difftest
	$(eval TMP := $(shell mktemp -d))
	@jq '.elf_path_glob="$(SAMPLE_ELF_DIR)/bin/*.elf"' \
		$(CURRENT_DIR)/difftest/assets/example.config.json \
		| tee $(TMP)/sail_difftest_config.json
	cd "$(TMP)" && $(CURRENT_DIR)/target/debug/difftest
	rm -rf "$(TMP)"
