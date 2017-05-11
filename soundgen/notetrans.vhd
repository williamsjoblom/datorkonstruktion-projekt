library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity notetrans is
  port(clk: in std_logic;               -- clock (duh!)
       chreg: in unsigned(1 downto 0);               -- channel bits
       rdy: in std_logic;              -- rdy
       rst: in std_logic;               -- reset
       nte: in std_logic;               -- note
       datareg: in unsigned(7 downto 0);  -- in from data-reg
       send: out std_logic;               -- write
       translatednote: out unsigned(7 downto 0);  -- out to write unit
       nte_done : out std_logic;
       triggerCh : out std_logic
       );
end notetrans;

architecture Behavioral of notetrans is

  -- Internal signals
  signal noteVector : unsigned(11 downto 0) := x"000";
  
  signal nte_pulse : std_logic := '0';
  signal nte_wait : std_logic := '0';

  signal rdy_pulse : std_logic := '0';
  signal rdy_wait : std_logic := '0';
  
  signal int_count : unsigned(1 downto 0) := b"00";  -- keeps track of rdy order.
  signal int_data : unsigned(7 downto 0) := x"00";  -- read when wrt and nte is high.


type noteVec_t is array (0 to 255) of unsigned(11 downto 0);
-- each line contains "0000_00000000"
--                     coarse_fine
constant noteVec_c : noteVec_t :=
  (--  coarse_fine
x"EEE",	-- C0
x"E18",	--  C#0/Db0 
x"D4D",	-- D0
x"C8D",	--  D#0/Eb0 
x"BD9",	-- E0
x"B2F",	-- F0
x"A8F",	--  F#0/Gb0 
x"9F7",	-- G0
x"967",	--  G#0/Ab0 
x"8E0",	-- A0
x"860",	--  A#0/Bb0 
x"7E8",	-- B0
x"000",
x"000",
x"000",
x"000",
x"777",	-- C1
x"70B",	--  C#1/Db1 
x"6A6",	-- D1
x"647",	--  D#1/Eb1 
x"5EC",	-- E1
x"597",	-- F1
x"547",	--  F#1/Gb1 
x"4FB",	-- G1
x"4B4",	--  G#1/Ab1 
x"470",	-- A1
x"430",	--  A#1/Bb1 
x"3F4",	-- B1
x"000",
x"000",
x"000",
x"000",
x"3BB",	-- C2
x"385",	--  C#2/Db2 
x"353",	-- D2
x"323",	--  D#2/Eb2 
x"2F6",	-- E2
x"2CB",	-- F2
x"2A3",	--  F#2/Gb2 
x"27D",	-- G2
x"259",	--  G#2/Ab2 
x"238",	-- A2
x"218",	--  A#2/Bb2 
x"1FA",	-- B2
x"000",
x"000",
x"000",
x"000",
x"1DD",	-- C3
x"1C2",	--  C#3/Db3 
x"1A9",	-- D3
x"191",	--  D#3/Eb3 
x"17B",	-- E3
x"165",	-- F3
x"151",	--  F#3/Gb3 
x"13E",	-- G3
x"12C",	--  G#3/Ab3 
x"11C",	-- A3
x"10C",	--  A#3/Bb3 
x"0FD",	-- B3
x"000",
x"000",
x"000",
x"000",
x"0EE",	-- C4
x"0E1",	--  C#4/Db4 
x"0D4",	-- D4
x"0C8",	--  D#4/Eb4 
x"0BD",	-- E4
x"0B2",	-- F4
x"0A8",	--  F#4/Gb4 
x"09F",	-- G4
x"096",	--  G#4/Ab4 
x"08E",	-- A4
x"086",	--  A#4/Bb4 
x"07E",	-- B4
x"000",
x"000",
x"000",
x"000",
x"077",	-- C5
x"070",	--  C#5/Db5 
x"06A",	-- D5
x"064",	--  D#5/Eb5 
x"05E",	-- E5
x"059",	-- F5
x"054",	--  F#5/Gb5 
x"04F",	-- G5
x"04B",	--  G#5/Ab5 
x"047",	-- A5
x"043",	--  A#5/Bb5 
x"03F",	-- B5
x"000",
x"000",
x"000",
x"000",
x"03B",	-- C6
x"038",	--  C#6/Db6 
x"035",	-- D6
x"032",	--  D#6/Eb6 
x"02F",	-- E6
x"02C",	-- F6
x"02A",	--  F#6/Gb6 
x"027",	-- G6
x"025",	--  G#6/Ab6 
x"023",	-- A6
x"021",	--  A#6/Bb6 
x"01F",	-- B6
x"000",
x"000",
x"000",
x"000",
x"01D",	-- C7
x"01C",	--  C#7/Db7 
x"01A",	-- D7
x"019",	--  D#7/Eb7 
x"017",	-- E7
x"016",	-- F7
x"015",	--  F#7/Gb7 
x"013",	-- G7
x"012",	--  G#7/Ab7 
x"011",	-- A7
x"010",	--  A#7/Bb7 
x"00F",	-- B7
x"000",
x"000",
x"000",
x"000",
x"00E",	-- C8
x"00E",	--  C#8/Db8 
x"00D",	-- D8
x"00C",	--  D#8/Eb8 
x"00B",	-- E8
x"00B",	-- F8
x"00A",	--  F#8/Gb8 
x"009",	-- G8
x"009",	--  G#8/Ab8 
x"008",	-- A8
x"008",	--  A#8/Bb8 
x"007", -- B8
   others => x"000"
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
      translatednote <= x"00";
      nte_done <= '1';
      triggerCh <= '0';
    else
      triggerCh <= '0';
      -- can directly determine the first register to rdy when note arrives.
      if nte_pulse = '1' then
        nte_done <= '0';                    -- möjligt fel.
        translatednote <= b"00000" & chreg & '0';    
      elsif rdy_pulse = '1' then          
        if int_count = b"00" then
          int_count <= b"01";
          translatednote <= noteVector(7 downto 0);
          send <= '1';

        elsif int_count = b"01" then
          int_count <= b"10";
          translatednote <= b"00000" & chreg & '1';
          send <= '1';

        elsif int_count = b"10" then
          int_count <= b"11";
          translatednote <= b"0000" & noteVector(11 downto 8);
          send <= '1';
        elsif int_count = b"11" then
          int_count <= b"00";
          nte_done <= '1';
          triggerCh <= '1';
        end if;
      else
        send <= '0';
      end if;
    end if;
  end if;
end process;

  noteVector <= noteVec(to_integer(datareg(3 downto 0) & datareg(7 downto 4))) when nte = '1'  else x"000";

end Behavioral;
