
# avoid implicit rules for clarity
.SUFFIXES: .asm .o .gb
.PHONY: bgb clean tests testroms debug

ASMS := $(wildcard *.asm)
OBJS := $(ASMS:.asm=.o)
DEBUGOBJS := $(addprefix build/debug/,$(OBJS))
RELEASEOBJS := $(addprefix build/release/,$(OBJS))
INCLUDES := $(wildcard include/*.asm)
TESTS := $(wildcard tests/*.py)

all: $(RELEASEOBJS) tests/.uptodate

tests/.uptodate: $(TESTS) tools/unit_test_gen.py $(DEBUGOBJS)
	python tools/unit_test_gen.py .
	touch "$@"

testroms: tests/.uptodate

tests: testroms
	./runtests

build/debug/%.o: %.asm $(INCLUDES) include/assets/.uptodate build/debug
	rgbasm -DDEBUG=1 -i include/ -v -o $@ $<

build/release/%.o: %.asm $(INCLUDES) include/assets/.uptodate build/release
	rgbasm -DDEBUG=0 -i include/ -v -o $@ $<

build/debug build/release:
	mkdir -p $@

clean:
	rm -f build/*/*.o tests/*/*.{asm,o,sym,gb} tests/.uptodate
