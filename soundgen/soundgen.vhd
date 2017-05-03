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
       rdy: out std_logic
       )
end soundgen;

architecture Behavioral of soundgen is

  -- Internal signals
  variable wrlc : integer := 1;
  signal note : std_logic;
  signal datareg : unsigned(7 downto 0);
  signal writemux : std_logic;          -- multiplexed signal (note write/ write) to Write unit
  signal datamux : std_logic;           -- translatednote or data_reg to write unit

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
  datamux <= translatednote when save = '1' else datareg;
  
  -- Data register
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        datareg <= x"00";
      elsif rdy = '1' then              -- kanske inte behövs
        datareg <= datain;
        save <= notedata;
        rdy <= '0';
      end if;
    end if;
  end process;

  -- Write unit
  process(clk)
  begin
    if rising_edge(clk) then
      if note = '1' then            -- Send Note // (tillfällig)
        if wrlc = '1' then              -- Latch Fine Tune Register
          wrmode <= LATCH;
        elsif wrlc = '2' then           -- Write Fine Tune
          wrmode <= WR;
        elsif wrlc = '3' then           -- Latch Coarse Tune Register
          wrmode <= LATCH;
        elsif wrlc = '4' then           -- Write Coarse Tune
          wrmode <= WR;
          wrlc <= '0';
          rdy <= '1';
        end if;
        wrlc <= wrlc + 1;
      else                              -- Send Data
        wrmode <= WR when wr = '1' else LATCH;
        rdy <= '1';
      end if;
      dataout <= datamux;               -- Note/Data Sent
      wrmode <= INACTIVE;
    end if;

  -- Write unit
  process(clk)
  begin
    if rising_edge(clk) then
      if wr = '1' then
        if wrlc = '1' then
          mrmode <= LATCH;
        
        end if;
        if save = '1' then
        
          dataout <= datamux;               -- Note/Data Sent
          wrmode <= INACTIVE;
        end if;
      end if;
    end if;  
  
  -- Signals to Notetrans.vhd

  U0 : notetrans port map (
    ch0=>ch0,
    ch1=>ch0,
    rdy=>rdy,
    note=>note,
    untranslatednote=>indata
    )                                   -- Notera att ready-signalen ska
                                        -- proj.vhd oxå?
                           

end Behavioral;
