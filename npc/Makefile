include ../Makefile

TOP = CPU
BUILD_DIR = build
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc/src) -name "*.cpp")

LIBCAPSTONE = ./csrc/capstone/repo/libcapstone.so.5
CFLAGS = -I$(abspath ./csrc/include) -I$(abspath ./csrc/capstone/repo/include)
LDFLAGS = -lreadline -lcapstone -L$(abspath ./csrc/capstone/repo)
VERILATOR_FLAGS = --build --trace --cc --exe --Mdir $(BUILD_DIR) --top $(TOP) -I$(abspath ./vsrc)\
$(addprefix -CFLAGS ,$(CFLAGS)) $(addprefix -LDFLAGS ,$(LDFLAGS))
PREBUILD_FLAGS = --cc --Mdir $(BUILD_DIR) --trace --top $(TOP) -I$(abspath ./vsrc)\
$(addprefix -CFLAGS ,$(CFLAGS)) $(addprefix -LDFLAGS ,$(LDFLAGS))

./$(BUILD_DIR)/V$(TOP): $(VSRCS) $(CSRCS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS)

./csrc/src/disasm.cpp: $(LIBCAPSTONE)

$(LIBCAPSTONE):
	$(MAKE) -C ./csrc/capstone

prebuild: $(VSRCS)
	verilator $(PREBUILD_FLAGS) $(VSRCS)

run: ./$(BUILD_DIR)/V$(TOP)
	$^ $(IMG) $(ELF)

clean:
	rm -rf $(BUILD_DIR)


