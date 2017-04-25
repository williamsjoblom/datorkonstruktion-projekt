library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity soundgen is
  port(clk: in std_logic;
       ch0: in std_logic;
       ch1: in std_logic;
       wr: in std_logic;
       datain: in unsigned(7 downto 0);
       rst: in std_logic;
       notedata: in std_logic;
       BDIR: out std_logic;
       BC2: out std_logic;
       dataout: out unsigned(7 downto 0);
       rdy: out std_logic
       )
end soundgen;

architecture Behavioral of soundgen is

  -- Internal signals
  
begin
  
  process(clk)
  begin
    if rising_edge(clk) then
      
    end if;
  end process;

end Behavioral;
