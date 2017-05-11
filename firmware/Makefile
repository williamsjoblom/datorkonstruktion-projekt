TEMPLATE = template.vhd
SRC = main.asm ay.asm vga.asm tracker.asm keypad.asm delay.asm notes.asm

CHASM = ~/chasm/chasm.py
CHASMFLAGS = --vhdl $(TEMPLATE) --offset E000 --entry main
OUTPUT = ../cpu/pMem.vhd

all:
	$(CHASM) $(CHASMFLAGS) $(SRC) > $(OUTPUT)