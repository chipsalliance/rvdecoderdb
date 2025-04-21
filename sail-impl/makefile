SAIL ?= sail
SAIL_FLAGS ?= --require-version 0.19 --strict-var -dno_cast -O -Oconstant_fold -memo_z3 --c-no-main
SAIL_SRC_DIR :=
ifndef SAIL_SRC_DIR
$(error SAIL_SRC_DIR not set, do you forgot to add -DSAIL_SRC_DIR=... when executing makefile)
endif

SED ?= sed
CC ?= gcc
AR ?= ar

CURRENT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

GENERATED_SAIL_SRC_DIR := $(CURRENT_DIR)

BUILD ?= build
prefix ?= $(BUILD)/install

SAIL_CFLAGS_COMPILE ?= -O3 -I$(CURRENT_DIR) -I$(SAIL_SRC_DIR)

all: prepare install

.PHONY: prepare
prepare:
	mkdir -p $(BUILD)/src $(BUILD)/lib

.PHONY: clean
clean:
	rm -rf $(BUILD)

.PHONY: install
install: $(BUILD)/lib/librv_model.a
	install -d $(prefix)/lib
	install $^ $(prefix)/lib
	install -Dm644 $(BUILD)/src/rv_model.c $(prefix)/lib/src/rv_model.c

$(BUILD)/src/rv_model.c:
	$(SAIL) $(SAIL_FLAGS) -c \
		--c-include sail_impl.h \
		--c-include sail_failure.h \
		$(GENERATED_SAIL_SRC_DIR)/rvcore/lib/prelude.sail \
		$(GENERATED_SAIL_SRC_DIR)/rv_xlen.sail \
		$(GENERATED_SAIL_SRC_DIR)/rvcore/capi.sail \
		$(GENERATED_SAIL_SRC_DIR)/rvcore/lib/scattered.sail \
		$(GENERATED_SAIL_SRC_DIR)/rvcore/arch/ArchPrelude.sail \
		$(GENERATED_SAIL_SRC_DIR)/arch/ArchStatesPrivEnable.sail \
		$(GENERATED_SAIL_SRC_DIR)/arch/ArchStateCsrBF.sail \
		$(GENERATED_SAIL_SRC_DIR)/arch/ArchStates.sail \
		$(GENERATED_SAIL_SRC_DIR)/arch/ArchStatesRW.sail \
		$(GENERATED_SAIL_SRC_DIR)/arch/ArchStatesReset.sail \
		$(GENERATED_SAIL_SRC_DIR)/rv_core.sail \
		$(GENERATED_SAIL_SRC_DIR)/rvcore/sailexpose.sail \
		-o build/src/rv_model
	$(SED) -i -i -e 's/^#include "sail_config.h"$$//' $@

$(BUILD)/rv_model.o: $(BUILD)/src/rv_model.c
	$(CC) $(SAIL_CFLAGS_COMPILE) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.o: $(SAIL_SRC_DIR)/%.c
	$(CC) $(SAIL_CFLAGS_COMPILE) $(CFLAGS) -c -o $@ $<

obj_files = rv_model.o sail_failure.o sail.o rts.o elf.o
$(BUILD)/lib/librv_model.a: $(addprefix $(BUILD)/, $(obj_files))
	$(AR) rcs $@ $^
