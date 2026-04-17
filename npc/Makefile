include ../Makefile

TOP = CPU
BUILD_DIR = build
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc/src) -name "*.cpp")


CFLAGS = -I$(abspath ./csrc/include)
LDFLAGS = -lreadline
VERILATOR_FLAGS = --build --trace --cc --exe --Mdir $(BUILD_DIR) --top $(TOP) -I$(abspath ./vsrc) -CFLAGS $(CFLAGS) -LDFLAGS $(LDFLAGS)
PREBUILD_FLAGS = --cc --Mdir $(BUILD_DIR) --trace --top $(TOP) -I$(abspath ./vsrc) -CFLAGS $(CFLAGS) -LDFLAGS $(LDFLAGS)

./$(BUILD_DIR)/V$(TOP): $(VSRCS) $(CSRCS)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	verilator $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS)

prebuild: $(VSRCS)
	verilator $(PREBUILD_FLAGS) $(VSRCS)

run: ./$(BUILD_DIR)/V$(TOP)
	echo $(IMG)
	$^ $(IMG)

clean:
	rm -rf $(BUILD_DIR)

