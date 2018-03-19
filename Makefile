ifndef TARGET_OS
ifeq ($(shell uname), Linux)
	UNAME_M := $(shell uname -m)
	ifeq ($(UNAME_M),x86_64)
		TARGET_OS := linux64
	endif
	ifeq ($(UNAME_M),i686)
		TARGET_OS := linux32
	endif
	ifeq ($(UNAME_M), $(filter $(UNAME_M),armv6l armv7l))
		TARGET_OS := linux-armhf
	endif
else ifeq ($(shell uname), Darwin)
	TARGET_OS := osx
else
	TARGET_OS := win32
endif
endif	# TARGET_OS

ifeq ($(TARGET_OS), $(filter $(TARGET_OS),linux32 linux64 linux-armhf))
	EXE_SUFFIX =
	OSFLAG = -D LINUX
else ifeq ($(TARGET_OS), osx)
	EXE_SUFFIX =
	OSFLAG = -D MAC_OS
else
	EXE_SUFFIX = .exe
	OSFLAG = -D WIN -static-libstdc++ -static-libgcc
endif

VERSION ?= $(shell git describe --always)
TARGET= avrdude

# OS-specific settings and build flags
ifeq ($(TARGET_OS), win32)
	ARCHIVE ?= zip
else
	ARCHIVE ?= tar
endif

# Packaging into archive (for 'dist' target)
ifeq ($(ARCHIVE), zip)
	ARCHIVE_CMD := zip -r
	ARCHIVE_EXTENSION ?= zip
else ifeq ($(ARCHIVE), tar)
	ARCHIVE_CMD := tar czf
	ARCHIVE_EXTENSION ?= tar.gz
endif

DIST_NAME := avr-dummy-$(VERSION)-$(TARGET_OS)
DIST_DIR := $(DIST_NAME)
DIST_ARCHIVE := $(DIST_NAME).$(ARCHIVE_EXTENSION)

ifeq ($(TARGET_OS), osx)
CC=clang++
else
CC=g++
endif
SOURCE= avrdude-dummy.cpp

all: $(TARGET)

dist: $(TARGET) $(DIST_DIR)
	@echo Copying avrdude to dist folder: $@...
	cp $(TARGET)$(EXE_SUFFIX) $(DIST_DIR)/
	cp micronucleus-*/micronucleus* $(DIST_DIR)/ || :
	$(ARCHIVE_CMD) $(DIST_ARCHIVE) $(DIST_DIR)
	
$(TARGET): $(SOURCE)
	@echo Building avrdude: $@...
	$(CC) $(OSFLAG) -o $@$(EXE_SUFFIX) $^
	strip $@$(EXE_SUFFIX) 2>/dev/null \
	|| $(CROSS_TRIPLE)-strip $@$(EXE_SUFFIX)

$(DIST_DIR):
	@mkdir -p $@

clean:
	@rm -f *.o
	@rm -f $(TARGET)$(EXE_SUFFIX)
	@rm -rf $(DIST_DIR)
	@rm -f $(DIST_ARCHIVE)
	
.PHONY:	all clean dist
