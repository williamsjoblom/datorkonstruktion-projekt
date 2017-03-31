library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity ramMem is
  port ( clk		: in std_logic;
         we		: in std_logic;
         dataIn	        : in unsigned(7 downto 0);
         dataOut	: out unsigned(15 downto 0);
         addr	        : in unsigned(12 downto 0));
end ramMem;

	
-- architecture
architecture Behavioral of ramMem is

  -- Ram memory type (8k)
  type ram_t is array (0 to 8191) of unsigned(7 downto 0);
  -- initiate ram memory to 0x42, 0x00, 0x00, 0x00...
  signal mem : ram_t := (0 => x"42", others => (others => '0'));


begin

  process(clk)
  begin
    if rising_edge(clk) then
      if (we = '1') then
        mem(to_integer(addr)) <= dataIn;
      end if;
      dataOut <= mem(to_integer(addr + 1)) & mem(to_integer(addr));
    end if;
  end process;


end Behavioral;

