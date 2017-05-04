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
       datareg: out unsigned(7 downto 0);
       dataout: out unsigned(7 downto 0);
       rdyout: out std_logic;
       )
end soundgen;

architecture Behavioral of soundgen is
  
  component notetrans
    port(clk: in std_logic;               -- clock (duh!)
         ch0: in std_logic;               -- channel bit 0
         ch1: in std_logic;               -- channel bit 1
         rdy: in std_logic;              -- rdy
         rst: in std_logic;               -- reset
         nte: in std_logic;               -- note
         datareg: in unsigned(7 downto 0);  -- in from data-reg
         send: out std_logic;               -- write
         translatednote: out unsigned(7 downto 0)  -- out to write unit
         nte_done: out std_logic;
         );
  end component;

  
  -- Internal signals
  variable lc : integer := '0';           -- lc for delay
  variable nteprgs : integer := '0';
  signal latch : std_logic := '1';
  signal nte : std_logic;
  signal writemux : std_logic;          -- multiplexed signal (note write/ write) to Write unit
  signal datamux : std_logic;           -- translatednote or data_reg to write unit
  signal rdy : std_logic := '1';
  signal rdyin : std_logic := '0';

  signal trigger : std_logic := '0';
  signal trigger_wait : std_logic := '0';
  signal trigger_pulse : std_logic := '0';
  signal count : std_logic := '0';
  signal wr_state : unsigned(1 downto 0) := b"00";

  signal send : std_logic := '0';
  signal nte_done : std_logic := '0';

  -- Modes
  type wrmodes is (INACTIVE, WR, LATCH);
  
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

 --  untranslatednote <= datareg;          -- får man göra så? osync?
  

  -- Mulitplexed signals
  datamux <= translatednote when nte = '1' else datareg;
  rdyout <= '1' when (nte = '0' and rdy = '1') else '0';
  rdyin <= '1' when (nte = '1' and rdy = '1') else '0';
  
  
  
  -- Data register
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        datareg <= x"00";
      elsif rdy = '1' then              -- kanske inte behövs
        if wr = '1' and trigger_wait = '0' then                -- DUBBELKOLLA
          datareg <= datain;
          nte <= notedata;
          rdy <= '0';
        elsif nte_done = '1' then
          nte <= '0';
        end if;
      end if;
    end if;
  end process;
  

  -- Write Unit
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        lc = 0;
      else
        if trigger_pulse = '1' or send = '1' then
          lc <= "240";
          rdy <= '0';
        end if;
        
        if latch = '1' then
          if lc = "240" then
            wrmode <= INACTIVE;
          elsif lc = "180" then
            wrmode <= LATCH;
          elsif lc = "120" then
            dataout <= datamux;
          elsif lc = "60" then
            rdy = '1';
            wrmode = <= INACTIVE;
            latch <= '0';
          end if;
        else
          if lc = "240" then
            wrmode <= INACTIVE;
          elsif lc = "180" then
            wrmode = <= WR;
          elsif lc = "120" then
            dataout <= datamux;
            if nte = '1' then           -- note cycle tracker
              nteprgs := nteprgs + '1';
            end if;
            if nteprgs = '2' then       -- reset and rdy should go high
              nte <= '0';
              nteprgs := '0';
            end if;
          elsif lc = "60" then
            rdy = '1';
            wrmode <= INACTIVE;
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
    ch0=>ch0,
    ch1=>ch0,
    rdy=>rdyin,
    nte=>nte,
    datareg=>datareg,
    send=>send,
    translatednote=>translatednote,
    nte_done=>nte_done
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
    
    if wr = '1' and trigger_wait = '0' then 
     trigger_pulse <= '1';
     trigger_wait <= '1';
    elsif wr = '0' and trigger_wait = '1' then
      trigger_wait <= '0';
    end if;
  end if;
end process;

    
end Behavioral;
