library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- uMem interface
entity uMem is
  port (
    uAddr : in unsigned(5 downto 0);
    uData : out unsigned(15 downto 0));
end uMem;

architecture Behavioral of uMem is

-- micro Memory
type u_mem_t is array (0 to 255) of unsigned(26 downto 0);
constant u_mem_c : u_mem_t :=
   --ALU___TB____FB____PC_LC__SEQ___uAddr
  (b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   b"0000__0000__0000__0__00__0000__00000000",
   );

signal u_mem : u_mem_t := u_mem_c;

begin  -- Behavioral
  uData <= u_mem(to_integer(uAddr));

end Behavioral;