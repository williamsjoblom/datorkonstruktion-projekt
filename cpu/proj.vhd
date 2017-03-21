library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity proj is
  port(clk: in std_logic;
	     rst: in std_logic);
end proj ;

architecture Behavioral of proj is


  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(7 downto 0);
         uData : out unsigned(26 downto 0));
  end component;

  -- program Memory component
  component pMem
    port(pAddr : in unsigned(15 downto 0);
         pData : out unsigned(15 downto 0));
  end component;

  component opVec
    port(opAddr : in unsigned(4 downto 0);
         opVector : out unsigned(7 downto 0));
  end component;

  component addrVec
    port(addrAddr : in unsigned(2 downto 0);
         addrVector : out unsigned(7 downto 0));
  end component;

  -- micro memory signals
  signal uM : unsigned(26 downto 0); -- micro Memory output
  signal uPC : unsigned(7 downto 0); -- micro Program Counter

  signal OPVECsig       : unsigned(7 downto 0);
  signal ADDRVECsig     : unsigned(7 downto 0);

  signal ALUsig         : unsigned(3 downto 0);
  signal TBsig          : unsigned(3 downto 0);
  signal FBsig          : unsigned(3 downto 0);
  signal PCsig          : std_logic;
  signal LCsig          : unsigned(1 downto 0);
  signal SEQsig         : unsigned(3 downto 0);
  signal UADDRsig       : unsigned(7 downto 0);
  
  -- program memory signals
  signal PM : unsigned(15 downto 0); -- Program Memory output
  signal PC : unsigned(15 downto 0); -- Program Counter
  signal ASR : unsigned(15 downto 0); -- Address Register
  signal IR : unsigned(15 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(15 downto 0); -- Data Bus

begin

  -- SEQ
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        uPC <= (others => '0');
      elsif SEQsig = b"0000" then
        uPC <= uPC + 1;
      elsif SEQsig = b"0001" then

      elsif SEQsig = b"0010" then
        
      elsif SEQsig = b"0011" then
        uPC <= (others => '0');
      end if;
    end if;
  end process;
	
  -- PC : Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        PC <= (others => '0');
      elsif FB = "0011" then
        PC <= DATA_BUS;
      elsif PCsig = '1' then
        PC <= PC + 1;
      end if;
    end if;
  end process;
	
  -- IR : Instruction Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FB = "0001") then
        IR <= DATA_BUS;
      end if;
    end if;
  end process;
	
  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FB = "1111") then
        ASR <= DATA_BUS;
      end if;
    end if;
  end process;
	
  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  -- U2 : opVec port map(opAddr=>ASR, opVector=>PM);
  
  -- U3 : addrVec port map(addrAddr=>ASR, addrVector=>PM);     
	
  -- micro memory signal assignments
  UADDRsig      <= uM(7 downto 0);
  SEQsig        <= uM(11 downto 8);
  LCsig         <= uM(13 downto 12);
  PCsig         <= uM(14);
  FBsig         <= uM(18 downto 15);
  TBsig         <= uM(22 downto 19);
  ALUsig        <= uM(26 downto 23);
  
  -- data bus assignment
  DATA_BUS <= IR when TB = "0001" else
    PM when TB = "0010" else
    PC when TB = "0011" else
    ASR when TB = "1111" else
    UADDRsig when TB = "1110" else
    (others => '0');
end Behavioral;
