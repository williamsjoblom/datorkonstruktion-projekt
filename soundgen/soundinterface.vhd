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
       
       BDIR: out std_logic;
       BC1: out std_logic;
       dataout: out std_logic_vector(7 downto 0);
       rdyout: out std_logic
       );
end soundinterface;

architecture Behavioral of soundinterface is
  
  component notetrans
    port(clk: in std_logic;               -- clock (duh!)
         chreg: in unsigned(1 downto 0);               -- channel bit
         rdy: in std_logic;              -- rdy
         rst: in std_logic;               -- reset
         nte: in std_logic;               -- note
         datareg: in unsigned(7 downto 0);  -- in from data-reg
         send: out std_logic;               -- write
         translatednote: out unsigned(7 downto 0);  -- out to write unit
         nte_done: out std_logic;
         triggerCh: out std_logic
         );
  end component;

  
  -- Internal signals

  
  signal latch : std_logic := '1';
  signal nte : std_logic := '0';

  signal datareg: unsigned(7 downto 0) := (others => '0');
  signal chreg : unsigned(1 downto 0) := (others => '1');

  signal datamux :unsigned(7 downto 0) := (others => '0');           -- translatednote or data_reg to write unit
  signal rdy : std_logic := '1';
  signal rdyin : std_logic := '0';
  signal translatednote : unsigned(7 downto 0) := (others => '0');

  signal trigger_wait : std_logic := '0';
  signal trigger_pulse : std_logic := '0';

  signal send : std_logic := '0';
  signal nte_done : std_logic := '1';
  signal triggerCh : std_logic := '0';



  -- Write Unit Modes
  type wrmodes is (INACTIVE, WRMOD, LATCHMOD);
  signal wrmode : wrmodes := INACTIVE;
  
begin

  --latchmod = 11.
  --wrmode = 01.
  --inactive = 00.

  -- BC1 & BDIR in different modes 
  --BC1 <= '1' when wrmode = LATCHMOD else '0';
  --BDIR <= '0' when wrmode = INACTIVE else '1';

  -- Mulitplexed signals
  datamux <= translatednote when nte = '1' else datareg;

  --dataout <= std_logic_vector(datamux);
  
  rdyout <= '1' when (nte_done = '1' and rdy = '1') else '0';
  rdyin <= '1' when (nte_done = '0' and rdy = '1') else '0';
  nte <= '0' when chreg = b"11"  else '1';
  
  -- Data register, Note register.
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        datareg <= x"00";
        chreg <= b"11";
      elsif wr = '1'and trigger_wait = '0' then                -- rdy = '1'?
        datareg <= datain(7 downto 0);
        chreg <= ch;
      end if;

      if triggerCh = '1' then
        chreg <= b"11";
      end if;
    end if;
  end process; 

  -- Write Unit
  process(clk)
   variable lc : integer := 0;           -- lc for delay
  begin
    if rising_edge(clk) then
      --dataout <= x"00";
      if rst = '1' then
        dataout <= x"00";
        lc := 0;
        BDIR <= '0';
        BC1 <= '0';
        rdy <= '1';
      else
        --dataout <= std_logic_vector(datamux);
        if trigger_pulse = '1' or send = '1' then  -- feflefelfelf
          lc := 240;
          rdy <= '0';
        end if;
        
        if latch = '1' then
          if lc = 240 then
            
            --wrmode <= INACTIVE;
            BDIR <= '0';
            BC1 <= '0';
          elsif lc = 180 then
            --wrmode <= LATCHMOD;
            BDIR <= '1';
            BC1 <= '1';
          elsif lc = 120 then
            dataout <= std_logic_vector(datamux);
          elsif lc = 60 then
            rdy <= '1';
            --wrmode <= INACTIVE;
            BDIR <= '0';
            BC1 <= '0';
            latch <= '0';
          end if;
        else
          if lc = 240 then
            --wrmode <= INACTIVE;
            BDIR <= '0';
            BC1 <= '0';
          elsif lc = 180 then
            --wrmode <= WRMOD;
            BDIR <= '1';
            BC1 <= '0';
          elsif lc = 120 then
            dataout <= std_logic_vector(datamux);
          elsif lc = 60 then
            rdy <= '1';
            --wrmode <= INACTIVE;
            BDIR <= '0';
            BC1 <= '0';
            latch <= '1';
            
          end if;
        end if;
        
        if lc /= 0 then
          lc := lc - 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Signals to Notetrans.vhd

  U0 : notetrans port map (
    clk=>clk,
    rst=>rst,
    chreg=>chreg,
    rdy=>rdyin,
    nte=>nte,
    datareg=>datareg,
    send=>send,
    translatednote=>translatednote,
    nte_done=>nte_done,
    triggerCh => triggerCh
    );                                  -- Notera att ready-signalen ska
                                        -- proj.vhd oxå?

process(clk)
begin  -- process   (Kan vara fel här..)
  if rising_edge(clk) then
    if rst = '1' then
      trigger_wait <= '0';
      trigger_pulse <= '0';
    end if;

    trigger_pulse <= '0';
    
    if wr = '1' and trigger_wait = '0' then 
     trigger_pulse <= '1';
     trigger_wait <= '1';
    elsif wr = '0' and trigger_wait = '1' then
      trigger_wait <= '0';
    end if;
  end if;
end process;

    
end Behavioral;
