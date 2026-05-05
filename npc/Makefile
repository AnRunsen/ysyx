include ../Makefile

TOP = ysyxSoCFull
BUILD_DIR = build
ALL_V = $(shell find $(abspath ./vsrc) $(abspath ../ysyxSoC/perip) $(abspath ../ysyxSoC/build) -name "*.v")
VSRCS := $(filter-out $(abspath ./vsrc/unused/%), $(ALL_V))
CSRCS = $(shell find $(abspath ./csrc/src) -name "*.cpp")
CONFIG_H = $(abspath ./csrc/include/config.hpp)

LIBCAPSTONE = ./csrc/capstone/repo/libcapstone.so.5
CFLAGS = -I$(abspath ./csrc/include) -I$(abspath ./csrc/capstone/repo/include)
LDFLAGS = $(NEMU_HOME)/build/riscv32-nemu-interpreter-so -lreadline -lcapstone -L$(abspath ./csrc/capstone/repo)

VERILATOR_FLAGS = --build --trace --cc --exe --Mdir $(BUILD_DIR) --top $(TOP)\
--timescale "1ns/1ns"\
--no-timing\
-I$(abspath ./vsrc)\
-I$(abspath ../ysyxSoC/perip/uart16550/rtl)\
-I$(abspath ../ysyxSoC/perip/spi/rtl)\
$(addprefix -CFLAGS ,$(CFLAGS)) $(addprefix -LDFLAGS ,$(LDFLAGS))

PREBUILD_FLAGS = --cc --Mdir $(BUILD_DIR) --trace --top $(TOP)\
--timescale "1ns/1ns"\
--no-timing\
-I$(abspath ./vsrc)\
-I$(abspath ../ysyxSoC/perip/uart16550/rtl)\
-I$(abspath ../ysyxSoC/perip/spi/rtl)\
$(addprefix -CFLAGS ,$(CFLAGS)) $(addprefix -LDFLAGS ,$(LDFLAGS))

./$(BUILD_DIR)/V$(TOP): $(VSRCS) $(CSRCS) $(CONFIG_H) $(BIND_FILE)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS) $(BIND_FILE)

./csrc/src/disasm.cpp: $(LIBCAPSTONE)

$(LIBCAPSTONE):
	$(MAKE) -C ./csrc/capstone

prebuild: $(VSRCS)
	verilator $(PREBUILD_FLAGS) $(VSRCS)

run: ./$(BUILD_DIR)/V$(TOP)
	$^ $(IMG) $(ELF)

build: ./$(BUILD_DIR)/V$(TOP)

clean:
	rm -rf $(BUILD_DIR)

include ./board/board.mk


