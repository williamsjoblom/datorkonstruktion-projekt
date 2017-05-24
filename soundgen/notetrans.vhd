library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note Translator Interface

entity notetrans is
  port(clk: in std_logic;               -- clock (duh!)
       chIn: in unsigned(1 downto 0);               -- channel bits
       rdy: in std_logic;              -- rdy
       rst: in std_logic;               -- reset
       nte: in std_logic;               -- note
       dataIn: in unsigned(7 downto 0);  -- in from data-reg
       wr: out std_logic;               -- write
       translatednote: out unsigned(7 downto 0);  -- out to write unit
       nte_done : out std_logic;
       triggerCh : out std_logic
       );
end notetrans;

architecture Behavioral of notetrans is
  component noteVec
    port (
      nte        : in  std_logic;
      noteAddr   : in  unsigned(7 downto 0);
      noteVector : out unsigned(11 downto 0));
  end component;
  
  -- Internal signals
  signal noteVector : unsigned(11 downto 0);
  
  -------------------------------------------------
  signal nte_pulse : std_logic;
  signal nte_wait : std_logic;

  signal rdy_pulse : std_logic;
  signal rdy_wait : std_logic;
  -------------------------------------------------
  
  signal state : unsigned(1 downto 0);  -- keeps track of rdy order.
  signal dataReg : unsigned(7 downto 0);  -- read when wr and nte is high.
  signal chReg : unsigned(1 downto 0); -- read when wr and nte is high.


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
      dataReg <= x"00";
      chReg <= b"00";

    elsif nte_pulse = '1' then
      dataReg <= unsigned(dataIn);
      chReg <= chIn;
    end if;
  end if;
end process;

  
-- purpose: WSU
process (clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      state <= b"00";
      translatednote <= x"00";
      nte_done <= '1';
      triggerCh <= '0';
      wr <= '0';
    else
      triggerCh <= '0';
      -- can directly determine the first register to rdy when note arrives.
      if nte_pulse = '1' then
        nte_done <= '0';
        translatednote <= b"00000" & chReg & '0';  -- Channel Fine-register
      elsif rdy_pulse = '1' then          
        if state = b"00" then
          state <= b"01";
          translatednote <= noteVector(7 downto 0);  -- Data Fine-tune
          wr <= '1';

        elsif state = b"01" then
          state <= b"10";
          translatednote <= b"00000" & chReg & '1'; -- Channel Coarse-register
          wr <= '1';

        elsif state = b"10" then
          state <= b"11";
          translatednote <= b"0000" & noteVector(11 downto 8); -- Data Coarse-tune
          wr <= '1';
        elsif state = b"11" then -- Reset State-machine and signal note done.
          state <= b"00";
          nte_done <= '1';
          triggerCh <= '1';
        end if;
      else
        wr <= '0';
      end if;
    end if;
  end if;
end process;

  U0 : noteVec port map (
    nte => nte,
    noteAddr => dataReg,
    noteVector => noteVector
    );

end Behavioral;
