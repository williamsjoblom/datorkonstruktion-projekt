TEMPLATE = template.vhd
SRC = main.asm ay.asm vga.asm

CHASM = ~/git/chasm/chasm.py
CHASMFLAGS = --vhdl $(TEMPLATE) --offset E000 --entry main
OUTPUT = ../cpu/pMem.vhd

all:
	$(CHASM) $(CHASMFLAGS) $(SRC) > $(OUTPUT)
