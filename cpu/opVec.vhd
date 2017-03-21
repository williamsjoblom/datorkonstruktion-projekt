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
  (x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00");

  signal opVec : opVec_t := opVec_c;


begin  -- opVec
  opVector <= opVec(to_integer(opAddr));

end Behavioral;
