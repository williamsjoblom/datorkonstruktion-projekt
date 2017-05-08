library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity notetrans is
  port(clk: in std_logic;               -- clock (duh!)
       ch: in unsigned(1 downto 0);               -- channel bits
       rdy: in std_logic;              -- rdy
       rst: in std_logic;               -- reset
       nte: in std_logic;               -- note
       datareg: in unsigned(7 downto 0);  -- in from data-reg
       send: out std_logic;               -- write
       translatednote: out unsigned(7 downto 0);  -- out to write unit
       nte_done : out std_logic
       );
end notetrans;

architecture Behavioral of notetrans is

  -- Internal signals
  signal addr : unsigned(7 downto 0) := x"00";
  signal noteVector : unsigned(9 downto 0) := b"0000000000";
  
  signal nte_pulse : std_logic := '0';
  signal nte_wait : std_logic := '0';

  signal rdy_pulse : std_logic := '0';
  signal rdy_wait : std_logic := '0';
  
  signal int_count : unsigned(1 downto 0) := b"00";  -- keeps track of rdy order.
  signal int_data : unsigned(7 downto 0) := x"00";  -- read when wrt and nte is high.
  signal lookUp : unsigned(7 downto 0);


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

  -- Enpulsare rdy and note.
process(clk)
begin  -- process   (Kan vara fel här..)
  if rising_edge(clk) then
    if rst = '1' then
      rdy_wait <= '0';
      rdy_pulse <= '0';
      nte_wait <= '0';
      nte_pulse <= '0';
    end if;

    rdy_pulse <= '0';
    nte_pulse <= '0';

    if nte = '1' and nte_wait = '0' then 
     nte_pulse <= '1';
     nte_wait <= '1';
    elsif nte = '0' and nte_wait = '1' then
      nte_wait <= '0';
    end if;
    
    if rdy = '1' and rdy_wait = '0' then 
     rdy_pulse <= '1';
     rdy_wait <= '1';
    elsif rdy = '0' and rdy_wait = '1' then
      rdy_wait <= '0';
    end if;
  end if;
end process;

-- Reads data from in bus once, when note signals high.
process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      int_data <= x"00";

    elsif nte_pulse = '1' then
      int_data <= unsigned(datareg);
    end if;
  end if;
end process;

  
-- purpose: WSU
process (clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      int_count <= b"00";
      translatednote <= x"FF";
      nte_done <= '1';
    else
      -- can directly determine the first register to rdy when note arrives.
      if nte_pulse = '1' then
        nte_done <= '0';                    -- möjligt fel.
        translatednote <= b"00000" & ch & '0';
        send <= '1';      
      elsif rdy_pulse = '1' then
        send <= '1';
        if int_count = b"00" then
          int_count <= b"01";
          translatednote <= noteVector(7 downto 0);

        elsif int_count = b"01" then
          int_count <= b"10";
          translatednote <= b"00000" & ch & '1';

        elsif int_count = b"10" then
          int_count <= b"00";
          translatednote <= b"000000" & noteVector(9 downto 8);
          nte_done <= '1';
        else
          translatednote <= x"00";
          int_count <= b"00";
        end if;
      else
        send <= '0';
      end if;
    end if;
  end if;
end process;

  noteVector <= noteVec(to_integer(datareg(3 downto 0) & datareg(7 downto 4)));

end Behavioral;
