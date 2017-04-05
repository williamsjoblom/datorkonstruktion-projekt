library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity ramMem is
  port ( clk		: in std_logic;
         
         wr1		: in std_logic;
         data1In	: in unsigned(7 downto 0);
         data1Out	: out unsigned(15 downto 0);
         addr1	        : in unsigned(12 downto 0);
         
         wr2		: in std_logic;
         data2In	: in unsigned(7 downto 0);
         data2Out	: out unsigned(15 downto 0);
         addr2	        : in unsigned(12 downto 0));
end ramMem;

	
-- architecture
architecture Behavioral of ramMem is

  -- Ram memory type (8k)
  type ram_t is array (0 to 8191) of unsigned(7 downto 0);
  -- initiate ram memory to 0x42, 0x00, 0x00, 0x00...
  signal mem : ram_t := (0 => x"42", others => (others => '0'));


begin

  data1Out <= mem(to_integer(addr1 + 1)) & mem(to_integer(addr1));
  data2Out <= mem(to_integer(addr2 + 1)) & mem(to_integer(addr2));
  
  process(clk)
  begin
    if rising_edge(clk) then
      if (wr1 = '1') then
        mem(to_integer(addr1)) <= data1In;
      end if;

      if (wr2 = '1') then
        mem(to_integer(addr2)) <= data2In;
      end if;
    end if;
  end process;


end Behavioral;

