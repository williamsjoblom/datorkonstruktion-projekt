library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- opVec interface
entity opVec is
  port(
    opAddr : in unsigned(4 downto 0);
    opVector : out unsigned(7 downto 0));
end opVec;

architecture Behavioral of opVec is

-- program Memory
type opVec_t is array (0 to 31) of unsigned(7 downto 0);
constant opVec_c : opVec_t :=
  (x"33",                               -- NOP
   x"34",                               -- LDA
   x"35",                               -- TAX
   x"36",                               -- TXA
   x"37",                               -- TAY
   x"38",                               -- TYA
   x"39",                               -- ADC
   x"3A",                               -- SBC
   x"3B",                               -- AND
   x"3C",                               -- ORA
   x"3D",                               -- EOR
   x"3E",                               -- ASL
   x"41",                               -- LSR
   x"44",                               -- INX
   x"45",                               -- DEX
   x"46",                               -- JMP
   x"47",                               -- STA
   x"48",                               -- PHA
   x"49",                               -- PLA
   x"4B",                               -- JSR
   x"4F",                               -- RTS
   x"51",                               -- CMP
   x"52",                               -- BCS
   x"54",                               -- BEQ
   x"56",                               -- BMI
   x"58",                               -- BNE
   x"5A",                               -- BPL
   x"5C",                               -- BIT
   x"5D",                               -- LDX
   x"5E",                               -- LDY
   x"5F",                               -- STX
   x"60"                                -- STY
   );

  signal opVec : opVec_t := opVec_c;


begin  -- opVec
  opVector <= opVec(to_integer(opAddr));

end Behavioral;
