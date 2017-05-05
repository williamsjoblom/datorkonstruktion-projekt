library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- Text mode Interface
entity textMode is
  port(
    clk : in std_logic;
    rst : in std_logic;
    curIn : in unsigned(7 downto 0);

    curXOut : out unsigned(7 downto 0);
    curYOut : out unsigned(7 downto 0);
    
    curXWr : in std_logic;
    curYWr : in std_logic;
    
    charAddr : out unsigned(13 downto 0);
    colorAddr : out unsigned(13 downto 0)
    
  );
end textMode;

architecture Behavioral of textMode is

  signal curX : unsigned(7 downto 0) := (others => '0');
  signal curY : unsigned(7 downto 0) := (others => '0');

  signal addr16 : unsigned(15 downto 0);

begin  -- Text mode
  
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        curX <= (others => '0');
        curY <= (others => '0');
      elsif curXWr = '1' then
        curX <= curIn;
      elsif curYWr = '1' then
        curY <= curIn;
      end if;
    end if;
  end process;

  
  addr16 <= (2 * curX) + (2 * 80 * curY);
  charAddr <= addr16(13 downto 0);
  colorAddr <= addr16(13 downto 0) + 1;
  
  curXOut <= curX;
  curYOut <= curY;
  
end Behavioral;
