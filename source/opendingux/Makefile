ifeq ($(CONFIG),)
CONFIGS:=gcw0,lepus,rg99,rs90,dingoo
$(error Please specify CONFIG, possible values: $(CONFIGS))
endif

ifeq ($(CONFIG),gcw0)
CROSS_COMPILE ?= /opt/gcw0-toolchain/usr/bin/mipsel-gcw0-linux-uclibc-
BOARD_DEFS := -DGCW_ZERO -DLOAD_ALL_ROM -DSCREEN_WIDTH=320 -DSCREEN_HEIGHT=240 -DMIPS_32R2
BOARD_LDFLAGS := -Wl,-zcommon-page-size=2097152 -Wl,-zmax-page-size=2097152 -lhugetlbfs
else ifeq ($(CONFIG),lepus)
CROSS_COMPILE ?= /opt/lepus-toolchain/usr/bin/mipsel-lepus-linux-musl-
BOARD_DEFS := -DGCW_ZERO -DLOAD_ALL_ROM -DSCREEN_WIDTH=320 -DSCREEN_HEIGHT=240
BOARD_LDFLAGS := -Wl,-zcommon-page-size=2097152 -Wl,-zmax-page-size=2097152 -lhugetlbfs
else ifeq ($(CONFIG),rs90)
CROSS_COMPILE ?= /opt/rs90-toolchain/usr/bin/mipsel-rs90-linux-musl-
BOARD_DEFS := -DRS90 -DUSE_MMAP -DSCREEN_WIDTH=240 -DSCREEN_HEIGHT=160
BOARD_LDFLAGS := -Wl,-zcommon-page-size=16384 -Wl,-zmax-page-size=16384
else ifeq ($(CONFIG),rg99)
CROSS_COMPILE ?= /opt/rs90-toolchain/usr/bin/mipsel-rs90-linux-musl-
BOARD_DEFS := -DRS90 -DUSE_MMAP -DSCREEN_WIDTH=320 -DSCREEN_HEIGHT=240
BOARD_LDFLAGS := -Wl,-zcommon-page-size=16384 -Wl,-zmax-page-size=16384
else ifeq ($(CONFIG),dingoo)
CROSS_COMPILE ?= /opt/opendingux-toolchain/usr/bin/mipsel-linux-
BOARD_DEFS := -DDINGOO_A320 -DUSE_MMAP -DSCREEN_WIDTH=320 -DSCREEN_HEIGHT=240
BOARD_LDFLAGS :=
else
$(error Invalid config: $(CONFIG))
endif

TARGET      := regba.$(CONFIG)

CC          := $(CROSS_COMPILE)gcc
STRIP       := $(CROSS_COMPILE)strip
HUGEEDIT    := $(dir $(CC))/hugeedit

ifneq ($(wildcard $(HUGEEDIT)),)
HUGEEDIT_CMD := $(HUGEEDIT) --text --data .opk_data/regba.$(CONFIG)
endif

SYSROOT     := $(shell $(CC) --print-sysroot)
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

OBJS        := main.o draw.o port.o port-asm.o od-input.o ../video.o          \
              ../input.o ../bios.o ../zip.o ../sound.o ../mips/stub.o         \
              ../stats.o ../memory.o ../cpu_common.o ../cpu_asm.o od-sound.o  \
              ../sha1.o imageio.o ../unifont.o gui.o od-memory.o settings.o
              
HEADERS     := cheats.h ../common.h ../cpu_common.h ../cpu.h draw.h main.h    \
               ../input.h ../memory.h message.h ../mips/emit.h ../sound.h     \
               ../stats.h ../video.h ../zip.h port.h od-sound.h ../sha1.h     \
               imageio.h ../unifont.h od-input.h settings.h

INCLUDE     := -I. -I.. -I../mips

DEFS        := $(BOARD_DEFS) -DMIPS_XBURST -DGIT_VERSION=$(shell git describe --always)

CFLAGS      := $(SDL_CFLAGS) -Wall -Wno-unused-variable -mno-shared -mplt \
               -fdata-sections -ffunction-sections -flto -O2 -fno-caller-saves \
               $(DEFS) $(INCLUDE)
ASFLAGS     := $(CFLAGS) -D__ASSEMBLY__
LDFLAGS     := $(CFLAGS) $(SDL_LIBS) -lpthread -lz -lm -lpng \
               -Wl,-gc-sections $(BOARD_LDFLAGS)

DATA_TO_CLEAN := .opk_data $(TARGET).opk

include ../Makefile.rules

.PHONY: all opk

all: $(TARGET)

opk: $(TARGET).opk

$(TARGET).opk: $(TARGET)
	$(SUM) "  OPK     $@"
	$(CMD)rm -rf .opk_data
	$(CMD)mkdir .opk_data
	$(CMD)cp -r data/default.$(CONFIG).desktop data/manual* data/regba-* .opk_data
	$(CMD)cp ../../game_config.txt .opk_data
	$(CMD)cp ../../bios/gba_bios.bin .opk_data
	$(CMD)cp $< .opk_data/regba.$(CONFIG)
	$(CMD)$(HUGEEDIT_CMD)
	$(CMD)$(STRIP) .opk_data/regba.$(CONFIG)
	$(CMD)mksquashfs .opk_data $@ -all-root -noappend -no-exports -no-xattrs -no-progress >/dev/null

# The two below declarations ensure that editing a .c file recompiles only that
# file, but editing a .h file recompiles everything.
# Courtesy of Maarten ter Huurne.

# Each object file depends on its corresponding source file.
$(C_OBJS): %.o: %.c

# Object files all depend on all the headers.
$(OBJS): $(HEADERS)
