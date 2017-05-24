library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Sound generator interface

entity soundinterface is
  port(clk: in std_logic;
       ch: in unsigned(1 downto 0);
       rst: in std_logic;               -- Reset
       datain: in unsigned(7 downto 0);  -- Bus
       wr: in std_logic;
       dataout: out std_logic_vector(7 downto 0);
       rdyout: out std_logic;
       
       -- Chip signals.
       BDIR: out std_logic;
       BC1: out std_logic;
       AY_RESET: out std_logic
       
       );
end soundinterface;

architecture Behavioral of soundinterface is
  
  component notetrans
    port(clk: in std_logic;               -- clock (duh!)
         chIn: in unsigned(1 downto 0);               -- channel bit
         rdy: in std_logic;              -- rdy
         rst: in std_logic;               -- reset
         nte: in std_logic;               -- note
         dataIn : in unsigned(7 downto 0);  -- in from data-reg
         wr: out std_logic;               -- write
         dataOut: out unsigned(7 downto 0);  -- out to write unit
         nteDone: out std_logic;
         triggerCh: out std_logic
         );
  end component;
  -- Internal signals
  signal latch : std_logic := '1';
  signal nte : std_logic := '0';

  signal dataReg: unsigned(7 downto 0) := (others => '0');
  signal chReg : unsigned(1 downto 0) := (others => '1');

  signal dataMux :unsigned(7 downto 0) := (others => '0');           -- translatednote or data_reg to write unit
  signal rdy : std_logic := '1';
  signal rdyIn : std_logic := '0';
  signal dataTransl : unsigned(7 downto 0) := (others => '0');

  signal wrWait : std_logic := '0';
  signal wrPulse : std_logic := '0';

  signal wrInt : std_logic := '0';
  signal nte_done : std_logic := '1';
  signal triggerCh : std_logic := '0';
  signal rstLong : std_logic := '1';    -- for chip reset
  
begin

  --latchmod = 11.
  --wrmode = 01.
  --inactive = 00.

  -- Mulitplexed signals
  dataMux <= dataTransl when nte = '1' else dataReg;
  rdyOut <= '1' when (nteDone = '1' and rdy = '1' and rstLong = '1') else '0';
  rdyIn <= '1' when (nteDone = '0' and rdy = '1') else '0';
  nte <= '0' when chReg = b"11"  else '1';
  
  -- Data register, Note register.
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        chReg <= b"11";
      elsif wr = '1'and wrWait = '0' then
        dataReg <= datain(7 downto 0);
        chReg <= ch;
      end if;

      if triggerCh = '1' then
        chReg <= b"11";
      end if;
    end if;
  end process;

  -- reset to chip.
  process(clk)
    variable rstTimer : integer := 0;
  begin
    
    if rising_edge(clk) then
      if rst = '1' then
        rstTimer := 60;
        rstLong <= '0';
      else
        if rstTimer /= 0 then
          rstTimer := rstTimer - 1;
        elsif rstTimer = 0 then
          rstLong <= '1';
        end if;
      end if;
    end if;
  end process;

  AY_RESET <= '1' when rstLong = '1' else '0';

  -- Write Unit
  process(clk)
   variable loopCount : integer := 0;           -- loop counter for delay.
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dataout <= x"00";
        loopCount := 0;
        BDIR <= '0';
        BC1 <= '0';
        rdy <= '1';
        latch <= '1';
      else
        if wrPulse = '1' or wrInt = '1' then
          loopCount := 1200;
          rdy <= '0';
        end if;
        
        if latch = '1' then
          if loopCount = 1199 then -- Inactive mode
            BDIR <= '0';
            BC1 <= '0';         
            dataout <= std_logic_vector(dataMux);
          elsif loopCount = 900 then -- Latch mode
            BDIR <= '1';
            BC1 <= '1';
          elsif loopCount = 700 then -- Inactive mode
            BDIR <= '0';
            BC1 <= '0';
          elsif loopCount = 1 then -- Prolonged inactive mode
            rdy <= '1';
            latch <= '0';
          end if;
        else
          if loopCount = 1199 then -- Inactive mode
            BDIR <= '0';
            BC1 <= '0';
            dataout <= std_logic_vector(dataMux);            
          elsif loopCount = 900 then -- Write mode
            BDIR <= '1';
            BC1 <= '0';
          elsif loopCount = 500 then -- Inactive mode
            BDIR <= '0';
            BC1 <= '0';
          elsif loopCount = 1 then -- Prolonged inactive mode
            rdy <= '1';
            latch <= '1';
          end if;
        end if;
        
        if loopCount /= 0 then -- if not zero, count down to zero.
          loopCount := loopCount - 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Signals to Notetrans.vhd

  U0 : notetrans port map (
    clk=>clk,
    rst=>rst,
    chIn=>chReg,
    rdy=>rdyIn,
    nte=>nte,
    dataIn=>dataReg,
    wr=>wrInt,
    dataOut=>dataTransl,
    nteDone=>nteDone,
    triggerCh => triggerCh
    );

process(clk)
begin  -- process   (Kan vara fel här..)
  if rising_edge(clk) then
    if rst = '1' then
      wrWait <= '0';
      wrPulse <= '0';
    end if;

    wrPulse <= '0';
    
    if wr = '1' and wrWait = '0' then 
     wrPulse <= '1';
     wrWait <= '1';
    elsif wr = '0' and wrWait = '1' then
      wrWait <= '0';
    end if;
  end if;
end process;

    
end Behavioral;
