CURRENT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY: boat_demo
boat_demo:
	@nix build '.#sail-riscv.test-elf' --out-link nix-result-elf
	@nix build '.#sail-riscv.boat.emulator' --out-link nix-result-emulator
	@./nix-result-emulator/bin/boat --elf-path ./nix-result-elf/bin/test.elf -vvv

.PHONY: spike_demo
spike_demo:
	@nix build '.#sail-riscv.test-elf' --out-link nix-result-elf
	@nix shell '.#spike' '.#dtc' -c \
		spike -m0x80000000:0x20000000,0x40000000:0x20000000 \
		--isa=rv64i --priv=m --log-commits ./nix-result-elf/bin/test.elf

.PHONY: difftest_demo
difftest_demo:
	@nix build '.#sail-riscv.boat.difftest' --out-link nix-result-difftest
	@nix build '.#sail-riscv.test-elf' --out-link nix-result-elf
	@mkdir -p build
	@jq '.elf_path_glob="$(shell realpath ./nix-result-elf)/bin/*.elf"' \
		$(CURRENT_DIR)/difftest/assets/example.config.json \
		| tee build/sail_difftest_config.json
	@cd build && \
		nix shell '.#spike' '.#dtc' '.#sail-riscv.boat.emulator' -c \
		$(CURRENT_DIR)/nix-result-difftest/bin/difftest

.PHONY: clean
clean:
	rm -rf build
	rm -f boat_trace_event.jsonl
	rm -f nix-result-*

.PHONY: dev
dev:
	@nix develop '.#sail-riscv.boat.emulator.dev' -c ${EDITOR} .
