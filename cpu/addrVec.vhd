library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- addrVec interface
entity addrVec is
  port(
    addrAddr : in unsigned(2 downto 0);
    addrVector : out unsigned(7 downto 0));
end addrVec;

architecture Behavioral of addrVec is

-- program Memory
type addrVec_t is array (0 to 7) of unsigned(7 downto 0);
constant addrVec_c : addrVec_t :=
  (x"03",                               -- Immediate
   x"04",                               -- Absolute
   x"00",
   x"00",
   x"00",
   x"00",
   x"00",
   x"00");

  signal addrVec : addrVec_t := addrVec_c;


begin  -- addrVec
  addrVector <= addrVec(to_integer(addrAddr));

end Behavioral;
