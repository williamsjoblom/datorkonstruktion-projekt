library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity notetrans is
  port(clk: in std_logic;
       ch0: in std_logic;
       ch1: in std_logic;
       rdy: in std_logic;
       wr_enable: in std_logic;
       in_data: in unsigned(7 downto 0);
       out_data: out unsigned(7 downto 0)
       )
end notetrans;

architecture Behavioral of notetrans is

  -- Internal signals
  signal notep : std_logic_vector(3 downto 0);
  signal octavep : std_logic_vector(3 downto 0);
  signal ch0_int : std_logic := 0;
  signal ch1_int : std_logic := 0;
  signal FC : std_logic := 0;           -- Fine/Course


  notep <= in_data(7 downto 4);
  octavep <= in_data(3 downto 0);
  
  -- Channel Register.
process(clk) begin
   if rising_edge(clk) then
     if rst = '1' then
       ch0_int <= '0';
       ch1_int <= '0';
     else
       if wr_enable = '1' then
         ch0_int <= ch0;
         ch1_int <= ch1;
       end if;
     end if;
   end if;
end process;

end Behavioral;
