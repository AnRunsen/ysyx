include $(NVBOARD_HOME)/scripts/nvboard.mk
BIND_FILE = $(abspath ./auto_bind.cpp)
LDFLAGS += $(NVBOARD_ARCHIVE) -lSDL2 -lSDL2_image -lSDL2_ttf
CFLAGS += -I$(abspath $(NVBOARD_HOME)/usr/include)
XDC_FILE = ./myxdc.nxdc

$(BIND_FILE): $(XDC_FILE)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@