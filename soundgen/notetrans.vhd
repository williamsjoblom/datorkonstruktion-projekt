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
       dataOut: out unsigned(7 downto 0);  -- out to write unit
       nteDone : out std_logic;
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
  signal ntePulse : std_logic;
  signal nteWait : std_logic;

  signal rdyPulse : std_logic;
  signal rdyWait : std_logic;
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
      rdyWait <= '0';
      rdyPulse <= '0';
      nteWait <= '0';
      ntePulse <= '0';
    end if;

    rdyPulse <= '0';
    ntePulse <= '0';

    if nte = '1' and nteWait = '0' then 
     ntePulse <= '1';
     nteWait <= '1';
    elsif nte = '0' and nteWait = '1' then
      nteWait <= '0';
    end if;
    
    if rdy = '1' and rdyWait = '0' then 
     rdyPulse <= '1';
     rdyWait <= '1';
    elsif rdy = '0' and rdyWait = '1' then
      rdyWait <= '0';
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

    elsif ntePulse = '1' then
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
      dataOut <= x"00";
      nteDone <= '1';
      triggerCh <= '0';
      wr <= '0';
    else
      triggerCh <= '0';
      -- can directly determine the first register to rdy when note arrives.
      if ntePulse = '1' then
        nteDone <= '0';
        dataOut <= b"00000" & chReg & '0';  -- Channel Fine-register
      elsif rdyPulse = '1' then          
        if state = b"00" then
          state <= b"01";
          dataOut <= noteVector(7 downto 0);  -- Data Fine-tune
          wr <= '1';

        elsif state = b"01" then
          state <= b"10";
          dataOut <= b"00000" & chReg & '1'; -- Channel Coarse-register
          wr <= '1';

        elsif state = b"10" then
          state <= b"11";
          dataOut <= b"0000" & noteVector(11 downto 8); -- Data Coarse-tune
          wr <= '1';
        elsif state = b"11" then -- Reset State-machine and signal note done.
          state <= b"00";
          nteDone <= '1';
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
