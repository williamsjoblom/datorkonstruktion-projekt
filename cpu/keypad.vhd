library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Keypad Interface

entity keypad is
  port(clk: in std_logic;
       strobe: in std_logic;
       data_in: in unsigned(3 downto 0);
       chip_select: in std_logic;
       data_out: out unsigned(3 downto 0);
end keypad;

architecture Behavioral of keypad is

  -- Internal signals
  signal data_reg : unsigned(3 downto 0);

begin
  -- Read from keypad
  process(clk)
  begin
    if rising_edge(clk) then
      if strobe = '1' then
        data_reg <= data_in;
      end if;
    end if;
  end process;

  -- Write to buss
  process(clk)
  begin
    if rising_edge(clk) then
      if chip_select = '1' then
        data_out <= data_reg;
      end if;
    end if;
  end process;

end Behavioral;
