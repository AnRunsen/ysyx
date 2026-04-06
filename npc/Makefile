include ../Makefile
include $(NVBOARD_HOME)/scripts/nvboard.mk

BUILD_DIR = build
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
BIND_FILE = $(abspath ./auto_bind.cpp)
CXXFLAGS += -I$(abspath ../nvboard/usr/include)
LDFLAGS += $(NVBOARD_ARCHIVE) -lSDL2 -lSDL2_image -lSDL2_ttf

VERILATOR_CFLAGS = --build --cc --exe --Mdir $(BUILD_DIR)\
$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS))\

sim: $(VSRCS) $(CSRCS) $(BIND_FILE) $(NVBOARD_ARCHIVE)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	rm -rf $(BUILD_DIR)
	verilator $(VERILATOR_CFLAGS) $(VSRCS) $(CSRCS) $(BIND_FILE)

$(BIND_FILE): ./bind.nxdc
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

clean:
	rm -rf $(BUILD_DIR)
