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

DIST_DIR:=avr-dummy

CC=	g++
SOURCE= avrdude-dummy.cpp

all: $(TARGET)

dist: $(TARGET) $(DIST_DIR)
	@echo Copying avrdude to dist folder: $@...
	cp $(TARGET)$(EXE_SUFFIX) $(DIST_DIR)/
	
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

.PHONY:	all clean dist
