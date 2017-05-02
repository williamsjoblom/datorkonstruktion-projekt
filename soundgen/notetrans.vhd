library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity notetrans is
  port(clk: in std_logic;
       ch0: in std_logic;
       ch1: in std_logic;
       rdy: in std_logic;
       rst: in std_logic;
       wr_enable: in std_logic;
       in_data: in unsigned(7 downto 0);
       out_data: out unsigned(7 downto 0)
       );
end notetrans;

architecture Behavioral of notetrans is

  -- Internal signals
  signal addr : unsigned(7 downto 0) := x"00";
  signal noteVector : unsigned(9 downto 0) := b"0000000000";
  signal rdy_pulse : std_logic := '0';
  signal rdy_wait : std_logic := '0';
  signal int_count : unsigned(1 downto 0) := b"00";  -- keeps track of send order.


type noteVec_t is array (0 to 143) of unsigned(9 downto 0);
-- each line contains "00_00000000"
--                     coarse_fine
constant noteVec_c : noteVec_t :=
  (b"1011111100",	--C0
   b"1011010001",	-- C#0/Db0 
   b"1010101001",	--D0
   b"1010000010",	-- D#0/Eb0 
   b"1001011110",	--E0
   b"1000111100",	--F0
   b"1000011100",	-- F#0/Gb0 
   b"0111111110",	--G0
   b"0111100001",	-- G#0/Ab0 
   b"0111000110",	--A0
   b"0110101100",	-- A#0/Bb0 
   b"0110010100",	--B0
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0101111110",	--C1
   b"0101101000",	-- C#1/Db1 
   b"0101010100",	--D1
   b"0101000001",	-- D#1/Eb1 
   b"0100101111",	--E1
   b"0100011110",	--F1
   b"0100001110",	-- F#1/Gb1 
   b"0011111111",	--G1
   b"0011110000",	-- G#1/Ab1 
   b"0011100011",	--A1
   b"0011010110",	-- A#1/Bb1 
   b"0011001010",	--B1
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0010111111",	--C2
   b"0010110100",	-- C#2/Db2 
   b"0010101010",	--D2
   b"0010100000",	-- D#2/Eb2 
   b"0010010111",	--E2
   b"0010001111",	--F2
   b"0010000111",	-- F#2/Gb2 
   b"0001111111",	--G2
   b"0001111000",	-- G#2/Ab2 
   b"0001110001",	--A2
   b"0001101011",	-- A#2/Bb2 
   b"0001100101",	--B2
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0001011111",	--C3
   b"0001011010",	-- C#3/Db3 
   b"0001010101",	--D3
   b"0001010000",	-- D#3/Eb3 
   b"0001001011",	--E3
   b"0001000111",	--F3
   b"0001000011",	-- F#3/Gb3 
   b"0000111111",	--G3
   b"0000111100",	-- G#3/Ab3 
   b"0000111000",	--A3
   b"0000110101",	-- A#3/Bb3 
   b"0000110010",	--B3
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000101111",	--C4
   b"0000101101",	-- C#4/Db4 
   b"0000101010",	--D4
   b"0000101000",	-- D#4/Eb4 
   b"0000100101",	--E4
   b"0000100011",	--F4
   b"0000100001",	-- F#4/Gb4 
   b"0000011111",	--G4
   b"0000011110",	-- G#4/Ab4 
   b"0000011100",	--A4
   b"0000011010",	-- A#4/Bb4 
   b"0000011001",	--B4
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000101111",	--C5
   b"0000101101",	-- C#5/Db5 
   b"0000101010",	--D5
   b"0000101000",	-- D#5/Eb5 
   b"0000100101",	--E5
   b"0000100011",	--F5
   b"0000100001",	-- F#5/Gb5 
   b"0000011111",	--G5
   b"0000011110",	-- G#5/Ab5 
   b"0000011100",	--A5
   b"0000011010",	-- A#5/Bb5 
   b"0000011001",	--B5
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000001011",	--C6
   b"0000001011",	-- C#6/Db6 
   b"0000001010",	--D6
   b"0000001010",	-- D#6/Eb6 
   b"0000001001",	--E6
   b"0000001000",	--F6
   b"0000001000",	-- F#6/Gb6 
   b"0000000111",	--G6
   b"0000000111",	-- G#6/Ab6 
   b"0000000111",	--A6
   b"0000000110",	-- A#6/Bb6 
   b"0000000110",	--B6
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000101",	--C7
   b"0000000101",	-- C#7/Db7 
   b"0000000101",	--D7
   b"0000000101",	-- D#7/Eb7 
   b"0000000100",	--E7
   b"0000000100",	--F7
   b"0000000100",	-- F#7/Gb7 
   b"0000000011",	--G7
   b"0000000011",	-- G#7/Ab7 
   b"0000000011",	--A7
   b"0000000011",	-- A#7/Bb7 
   b"0000000011",	--B7
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000010",	--C8
   b"0000000010",	-- C#8/Db8 
   b"0000000010",	--D8
   b"0000000010",	-- D#8/Eb8 
   b"0000000010",	--E8
   b"0000000010",	--F8
   b"0000000010",	-- F#8/Gb8 
   b"0000000001",	--G8
   b"0000000001",	-- G#8/Ab8 
   b"0000000001",	--A8
   b"0000000001",	-- A#8/Bb8 
   b"0000000001",	--B8
   b"0000000000",
   b"0000000000",
   b"0000000000",
   b"0000000000"
   );

  signal noteVec : noteVec_t := noteVec_c;

BEGIN

process (clk)
begin  -- process   (Kan vara fel här..)
  if rising_edge(clk) then
    if rst = '1' then
      rdy_wait <= '0';
    end if;

    rdy_pulse <= '0';
    
    if rdy = '1' and rdy_wait = '0' then 
     rdy_pulse <= '1';
     rdy_wait <= '1';

    elsif rdy = '0' and rdy_wait = '1' then
      rdy_wait <= '0';
    end if;
     
  end if;
end process;

  
-- purpose: WSU
process (clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      int_count <= b"00";
      out_data <= x"FF";
    else

      
      
      if rdy_pulse = '1' then
        if int_count = b"00" then
          int_count <= b"01";
          out_data <= b"00000" & ch0 & ch1 & '0';
          
        elsif int_count = b"01" then
          int_count <= b"10";
          out_data <= noteVector(7 downto 0);

        elsif int_count = b"10" then
          int_count <= b"11";
          out_data <= b"00000" & ch0 & ch1 & '1';

        elsif int_count = b"11" then
          int_count <= b"00";
          out_data <= b"000000" & noteVector(9 downto 8);
        else
          out_data <= x"FF";
          
        end if;
      end if;
    end if;
  end if;
end process;


process (clk)
begin  -- process
  if rising_edge(clk) then
    if rst = '1' then
      addr <= x"00";
    else
      addr <= in_data;
      
    end if;
  end if;
end process;

  noteVector <= noteVec(to_integer(in_data(3 downto 0) & in_data(7 downto 4)));

end Behavioral;
