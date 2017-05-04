library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Sound generator interface

entity soundgen is
  port(clk: in std_logic;
       ch0: in std_logic;
       ch1: in std_logic;
       rst: in std_logic;               -- Reset
       datain: in unsigned(7 downto 0);  -- Bus
       translatednote: in unsigned(7 downto 0):
       
       wr: in std_logic;
       notedata: in std_logic;          -- Note = 1, Data = 0
       
       BDIR: out std_logic;
       BC1: out std_logic;
       untranslatednote: out unsigned(7 downto 0);
       dataout: out unsigned(7 downto 0);
       rdy: out std_logic;
       )
end soundgen;

architecture Behavioral of soundgen is

  -- Internal signals
  variable lc : integer := 0;           -- lc for delay
  signal wrote : std_logic;
  signal nte : std_logic;
  signal datareg : unsigned(7 downto 0);
  signal writemux : std_logic;          -- multiplexed signal (note write/ write) to Write unit
  signal datamux : std_logic;           -- translatednote or data_reg to write unit

  signal trigger : std_logic := '0';
  signal trigger_wait : std_logic := '0';
  signal trigger_pulse : std_logic := '0';

  -- Modes
  type wrmodes is (WR, LATCH, INACTIVE);
  
begin

  -- Write Unit modes
  case wrmode is
    when LATCH  =>
      BC1 <= '1';
      BDIR <= '1';
    when WR  =>
      BC1 <= '0';
      BDIR <= '1';
    when INACTIVE  =>
      BC1 <= '0';
      BDIR <= '0';
  end case;

  untranslatednote <= datareg;          -- får man göra så? osync?
  

  -- Mulitplexed signals
  datamux <= translatednote when nte = '1' else datareg;
  
  -- Data register
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        datareg <= x"00";
      elsif rdy = '1' then              -- kanske inte behövs
        if wr = '1' then                -- dubbelkolla
          datareg <= datain;
          nte <= notedata;
          rdy <= '0';
        end if;
      end if;
    end if;
  end process;

 

  -- Write unit
  process(clk)
  begin
    if rising_edge(clk) then
      if wrote = '0' then
        wrmode <= LATCH;
        wrote <= '1';
      elsif wrote = '1' then
        wrmode <= WR;
        wrote <= '0';
      end if;
      if lc < "60" then
        lc := lc + '1';
      elsif lc = "60" then  
        dataout <= datamux;               -- Note/Data Sent
        wrmode <= INACTIVE;
        lc := 0;
      elsif lc < "120" then
        lc := lc + '1';
      end if;
      rdy = '1';
        
    end if;  
  end process;


  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        lc := 0;
      else
        if lc /= 0 then
          lc := lc - 1
    end if;

  
  -- Signals to Notetrans.vhd

  U0 : notetrans port map (
    ch0=>ch0,
    ch1=>ch0,
    rdy=>rdy,
    nte=>nte,
    untranslatednote=>indata
    )                                   -- Notera att ready-signalen ska
                                        -- proj.vhd oxå?
                           


process(clk)
begin  -- process   (Kan vara fel här..)
  if rising_edge(clk) then
    if rst = '1' then
      trigger_wait <= '0';
      trigger_pulse <= '0';
    end if;

    trigger_pulse <= '0';
    
    if trigger = '1' and trigger_wait = '0' then 
     trigger_pulse <= '1';
     trigger_wait <= '1';
    elsif trigger = '0' and trigger_wait = '1' then
      trigger_wait <= '0';
    end if;
  end if;
end process;

    
end Behavioral;
