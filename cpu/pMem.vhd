library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- pMem interface
entity pMem is
  port(
    pAddr : in unsigned(14 downto 0);
    pData : out unsigned(15 downto 0));
end pMem;

architecture Behavioral of pMem is

-- program Memory
type p_mem_t is array (0 to 63) of unsigned(7 downto 0);
constant p_mem_c : p_mem_t :=
(
x"08",
x"08",
x"81",
x"00",
x"40",

x"08",
x"f0",
x"81",
x"01",
x"40",

x"08",
x"05",
x"81",
x"02",
x"40",

x"08",
x"f0",
x"81",
x"03",
x"40",

x"08",
x"0c",
x"81",
x"04",
x"40",

x"08",
x"f0",
x"81",
x"05",
x"40",

x"08",
x"0c",
x"81",
x"06",
x"40",

x"08",
x"f0",
x"81",
x"07",
x"40",

x"08",
x"0f",
x"81",
x"08",
x"40",

x"08",
x"f0",
x"81",
x"09",
x"40",

x"78",
x"00",
x"e0",
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
x"E0"
);




  signal p_mem : p_mem_t := p_mem_c;


begin  -- pMem
  pData <= p_mem(to_integer(pAddr(5 downto 0) + 1)) & p_mem(to_integer(pAddr(5 downto 0)));

end Behavioral;
