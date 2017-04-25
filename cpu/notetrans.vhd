library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity notetrans is
  port(clk: in std_logic;
       ch0: in std_logic;
       ch1: in std_logic;
       wr: in std_logic;
       note_data: in unsigned(7 downto 0)
       )
end notetrans;

architecture Behavioral of notetrans is

  -- Internal signals
  
begin
  
  process(clk)
  begin
    if rising_edge(clk) then
      
    end if;
  end process;

end Behavioral;
