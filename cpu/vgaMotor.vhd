--------------------------------------------------------------------------------
-- VGA MOTOR
-- Anders Nilsson
-- 16-feb-2016
-- Version 1.1


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type


-- entity
entity vgaMotor is
  port ( clk			: in std_logic;
	 data			: in std_logic_vector(7 downto 0);
	 addr			: out unsigned(13 downto 0);
	 rst			: in std_logic;
	 vgaRed		        : out std_logic_vector(2 downto 0);
	 vgaGreen	        : out std_logic_vector(2 downto 0);
	 vgaBlue		: out std_logic_vector(2 downto 1);
	 Hsync		        : out std_logic;
	 Vsync		        : out std_logic);
end vgaMotor;


-- architecture
architecture Behavioral of vgaMotor is

  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25		: std_logic;			-- One pulse width 25 MHz signal
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
  signal	tileAddr	: unsigned(10 downto 0);	-- Tile address

  signal        pixelLit        : std_logic;

  signal        colorchar       : std_logic;
  signal        fgColor         : unsigned(3 downto 0) := x"F";
  signal        bgColor         : unsigned(3 downto 0) := x"0";
  signal        fgPixel         : std_logic_vector(7 downto 0);
  signal        bgPixel         : std_logic_vector(7 downto 0);
  
  signal        blank           : std_logic;                    -- blanking signal

  type palette_t is array (0 to 15) of std_logic_vector(7 downto 0);
  
  -- ANSI 4-bit terminal palette
  signal palette : palette_t :=
                ( x"00",                   -- Black
                  x"02",                   -- Blue
                  x"14",                   -- Green
                  x"16",                   -- Cyan
                  x"A0",                   -- Red
                  x"A2",                   -- Magenta
                  x"B0",                   -- Brown
                  x"B6",                   -- Light Gray
                  
                  x"92",                   -- Dark Gray
                  x"93",                   -- Light Blue
                  x"9E",                   -- Light Green
                  x"9F",                   -- Light Cyan
                  x"F2",                   -- Light Red
                  x"F3",                   -- Light Magenta
                  x"FC",                   -- Yellow
                  x"FF"                    -- White
                );
  
  -- Tile memory type
  type bitram_t is array (0 to 2047) of std_logic;

  -- Tile memory
  signal tileMem1 : bitram_t := 
		( '0','0','0','0','0','0','0','0',      -- space
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',

                  '0','0','1','1','0','0','0','0',      -- A	
                  '0','1','1','1','1','0','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','1','1','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','0','0',      -- B	
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','1','1','1','0','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '1','1','1','1','1','1','0','0',
                  '0','0','0','0','0','0','0','0',


                  '0','0','1','1','1','1','0','0',      -- C	
                  '0','1','1','0','0','1','1','0',
                  '1','1','0','0','0','0','0','0',
                  '1','1','0','0','0','0','0','0',
                  '1','1','0','0','0','0','0','0',
                  '0','1','1','0','0','1','1','0',
                  '0','0','1','1','1','1','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','0','0','0',      -- D	
                  '0','1','1','0','1','1','0','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','1','1','0','0',
                  '1','1','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','1','0',      -- E	
                  '0','1','1','0','0','0','1','0',
                  '0','1','1','0','1','0','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','1','1','0','1','0','0','0',
                  '0','1','1','0','0','0','1','0',
                  '1','1','1','1','1','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','1','0',      -- F	
                  '0','1','1','0','0','0','1','0',
                  '0','1','1','0','1','0','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','1','1','0','1','0','0','0',
                  '0','1','1','0','0','0','0','0',
                  '1','1','1','1','0','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '0','0','1','1','1','1','0','0',      -- G	
                  '0','1','1','0','0','1','1','0',
                  '1','1','0','0','0','0','0','0',
                  '1','1','0','0','0','0','0','0',
                  '1','1','0','0','1','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '0','0','1','1','1','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','1','1','0','0',      -- H	
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','1','1','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '0','0','0','0','0','0','0','0',


                  '0','1','1','1','1','0','0','0',      -- I	
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '0','0','0','1','1','1','1','0',      -- J	
                  '0','0','0','0','1','1','0','0',
                  '0','0','0','0','1','1','0','0',
                  '0','0','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','0','0','1','1','0',      -- K	
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','1','1','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','1','1','0','1','1','0','0',
                  '0','1','1','0','0','1','1','0',
                  '1','1','1','0','0','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','0','0','0','0',      -- L	
                  '0','1','1','0','0','0','0','0',
                  '0','1','1','0','0','0','0','0',
                  '0','1','1','0','0','0','0','0',
                  '0','1','1','0','0','0','1','0',
                  '0','1','1','0','0','1','1','0',
                  '1','1','1','1','1','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','0','1','1','0',      -- M	
                  '1','1','1','0','1','1','1','0',
                  '1','1','1','1','1','1','1','0',
                  '1','1','1','1','1','1','1','0',
                  '1','1','0','1','0','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','0','1','1','0',      -- N	
                  '1','1','1','0','0','1','1','0',
                  '1','1','1','1','0','1','1','0',
                  '1','1','0','1','1','1','1','0',
                  '1','1','0','0','1','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '0','0','1','1','1','0','0','0',      -- O	
                  '0','1','1','0','1','1','0','0',
                  '1','1','0','0','0','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '0','1','1','0','1','1','0','0',
                  '0','0','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','0','0',      -- P	
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','1','1','1','0','0',
                  '0','1','1','0','0','0','0','0',
                  '0','1','1','0','0','0','0','0',
                  '1','1','1','1','0','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '0','1','1','1','1','0','0','0',      -- Q	
                  '1','1','0','0','1','1','0','0',      
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','1','1','1','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','0','1','1','1','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','0','0',      -- R	
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','0','0','1','1','0',
                  '0','1','1','1','1','1','0','0',
                  '0','1','1','0','1','1','0','0',
                  '0','1','1','0','0','1','1','0',
                  '1','1','1','0','0','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '0','1','1','1','1','0','0','0',      -- S	
                  '1','1','0','0','1','1','0','0',
                  '1','1','1','0','0','0','0','0',
                  '0','1','1','1','0','0','0','0',
                  '0','0','0','1','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','0','0',      -- T	
                  '1','0','1','1','0','1','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','1','1','0','0',      -- U	
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','1','1','1','1','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','1','1','0','0',      -- V	
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','0','1','1','0',      -- W	
                  '1','1','0','0','0','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '1','1','0','1','0','1','1','0',
                  '1','1','1','1','1','1','1','0',
                  '1','1','1','0','1','1','1','0',
                  '1','1','0','0','0','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','0','1','1','0',      -- X	
                  '1','1','0','0','0','1','1','0',
                  '0','1','1','0','1','1','0','0',
                  '0','0','1','1','1','0','0','0',
                  '0','0','1','1','1','0','0','0',
                  '0','1','1','0','1','1','0','0',
                  '1','1','0','0','0','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','0','0','1','1','0','0',      -- Y	
                  '1','1','0','0','1','1','0','0',
                  '1','1','0','0','1','1','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','0','1','1','0','0','0','0',
                  '0','1','1','1','1','0','0','0',
                  '0','0','0','0','0','0','0','0',


                  '1','1','1','1','1','1','1','0',      -- Z	
                  '1','1','0','0','0','1','1','0',
                  '1','0','0','0','1','1','0','0',
                  '0','0','0','1','1','0','0','0',
                  '0','0','1','1','0','0','1','0',
                  '0','1','1','0','0','1','1','0',
                  '1','1','1','1','1','1','1','0',
                  '0','0','0','0','0','0','0','0',


                  '0','0','0','1','0','0','0','0',      -- �
		  '0','0','0','0','0','0','0','0',
		  '0','1','1','1','1','1','0','0',
		  '1','1','0','0','0','1','1','0',
		  '1','1','1','1','1','1','1','0',
		  '1','1','0','0','0','1','1','0',
		  '1','1','0','0','0','1','1','0',
		  '0','0','0','0','0','0','0','0',

		  '0','0','1','0','1','0','0','0',      -- �
		  '0','0','0','0','0','0','0','0',
		  '0','1','1','1','1','1','0','0',
		  '1','1','0','0','0','1','1','0',
		  '1','1','1','1','1','1','1','0',
		  '1','1','0','0','0','1','1','0',
		  '1','1','0','0','0','1','1','0',
		  '0','0','0','0','0','0','0','0',

		  '0','0','1','0','1','0','0','0',      -- �
		  '0','0','0','0','0','0','0','0',
		  '0','1','1','1','1','1','0','0',
		  '1','1','0','0','0','1','1','0',
		  '1','1','0','0','0','1','1','0',
		  '1','1','0','0','0','1','1','0',
		  '0','1','1','1','1','1','0','0',
		  '0','0','0','0','0','0','0','0',
                  
		 
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',
		  '0','0','0','0','0','0','0','0',

		  '0','0','1','1','1','1','0','0',      -- PACMAN CURSOR
		  '0','1','1','1','1','1','1','0',
		  '1','1','1','1','1','1','0','0',
		  '1','1','1','1','1','0','0','0',
		  '1','1','1','1','1','0','0','0',
		  '1','1','1','1','1','1','0','0',
		  '0','1','1','1','1','1','1','0',
		  '0','0','1','1','1','1','0','0'
                  );
		  
begin

  -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else        
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        Xpixel <= "0000000000";
      elsif Clk25='1' then
        if Xpixel=793 then
          Xpixel <= "0000000000";
        else
          Xpixel <= Xpixel + 1;
        end if;
      end if;
    end if;
  end process;

  
  -- Horizontal sync
  
  --Hsync <= '0' when Xpixel >= 655 and Xpixel <= 751 else '1';
  Hsync <= '0' when Xpixel >= 655 and Xpixel <= 747 else '1';
  
  -- Vertical pixel counter

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        Ypixel <= "0000000000";
      elsif Clk25='1' then
        if Ypixel=521 then
          Ypixel <= "0000000000";
        elsif Xpixel=793 then
          Ypixel <= Ypixel + 1;
        end if;
      end if;
    end if;
  end process;
	

  -- Vertical sync

  Vsync <= '0' when Ypixel >= 489 and Ypixel <= 491 else '1';
  
  -- Video blanking signal

  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
        blank <= '0';
      elsif Clk25='1' then
        if Xpixel >= 640 or Ypixel >= 480 then
          blank <= '1';
        else
          blank <= '0';
        end if;
      end if;
    end if;
  end process;


  process(clk)
  begin
    if rising_edge(clk) then
      if colorChar='1' then
        tileAddr <= unsigned(data(4 downto 0)) & Ypixel(2 downto 0) & Xpixel(2 downto 0);
        colorChar <= '0';
      else
        fgColor <= unsigned(data(7 downto 4));
        bgColor <= unsigned(data(3 downto 0));
        colorChar <= '1';
      end if;
    end if;
  end process;

  -- Tile memory address composite
  -- tileAddr <= unsigned(data(4 downto 0)) & Ypixel(2 downto 0) & Xpixel(2 downto 0);

  pixelLit <= tileMem1(to_integer(tileAddr)) when blank='0' else '0';

  -- Picture memory address composite
  addr(13 downto 1) <= to_unsigned(80, 7)*Ypixel(8 downto 3) + Xpixel(9 downto 3);
  addr(0) <= colorChar;
  
  fgPixel <= palette(to_integer(unsigned(fgColor)));
  bgPixel <= palette(to_integer(unsigned(bgColor)));

  -- VGA generation
  vgaRed(2) 	<= fgPixel(7) when pixelLit='1' else bgPixel(7);
  vgaRed(1) 	<= fgPixel(6) when pixelLit='1' else bgPixel(6);
  vgaRed(0) 	<= fgPixel(5) when pixelLit='1' else bgPixel(5);
  vgaGreen(2)   <= fgPixel(4) when pixelLit='1' else bgPixel(4);
  vgaGreen(1)   <= fgPixel(3) when pixelLit='1' else bgPixel(3);
  vgaGreen(0)   <= fgPixel(2) when pixelLit='1' else bgPixel(2);
  vgaBlue(2) 	<= fgPixel(1) when pixelLit='1' else bgPixel(1);
  vgaBlue(1) 	<= fgPixel(0) when pixelLit='1' else bgPixel(0);
  
  -- VGA generation
  --vgaRed(2) 	<= tilePixel(7);
  --vgaRed(1) 	<= tilePixel(6);
  --vgaRed(0) 	<= tilePixel(5);
  --vgaGreen(2)   <= tilePixel(4);
  --vgaGreen(1)   <= tilePixel(3);
  --vgaGreen(0)   <= tilePixel(2);
  --vgaBlue(2) 	<= tilePixel(1);
  --vgaBlue(1) 	<= tilePixel(0);


end Behavioral;

