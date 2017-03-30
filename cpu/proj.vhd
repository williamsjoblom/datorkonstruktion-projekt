library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--CPU interface
entity proj is
  port(clk: in std_logic;
       rst: in std_logic;
       foobar: out std_logic);          -- To be removed, placeholder output.
end proj ;

architecture Behavioral of proj is


  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(7 downto 0);
         uData : out unsigned(28 downto 0));
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
  signal uM : unsigned(28 downto 0); -- micro Memory output
  signal uPC : unsigned(7 downto 0); -- micro Program Counter
  signal SuPC : unsigned(7 downto 0);
  signal LC : unsigned(7 downto 0);

  signal OPADDRsig      : unsigned(4 downto 0);       
  signal OPVECsig       : unsigned(7 downto 0);
  signal ADDRADDRsig    : unsigned(2 downto 0);
  signal ADDRVECsig     : unsigned(7 downto 0);

  signal ALUsig         : unsigned(3 downto 0);
  signal TBsig          : unsigned(3 downto 0);
  signal FBsig          : unsigned(3 downto 0);
  signal PCsig          : std_logic;
  signal LCsig          : unsigned(1 downto 0);
  signal STACKsig       : unsigned(1 downto 0);
  signal SEQsig         : unsigned(3 downto 0);
  signal UADDRsig       : unsigned(7 downto 0);
  
  -- program memory signals
  signal PM : unsigned(15 downto 0); -- Program Memory output
  signal PC : unsigned(15 downto 0); -- Program Counter
  signal ASR : unsigned(15 downto 0); -- Address Register
  signal IR : unsigned(7 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(15 downto 0); -- Data Bus

  -- Registers
  signal A : unsigned(8 downto 0);      -- Accumulator
  signal X : unsigned(7 downto 0);      -- X
  signal Y : unsigned(7 downto 0);      -- Y

  signal CARRY : std_logic;
  signal ZERO : std_logic;
  signal OVERFLOW : std_logic;
  signal SIGN : std_logic;
  
  signal S : unsigned(7 downto 0);      -- Status

  signal SP : unsigned(15 downto 0);    -- Stack Pointer
  

begin

    -- Accumulator register
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        A <= (others => '0');
      elsif ALUsig = "0001" then        -- A := buss
        A(7 downto 0) <= DATA_BUS(7 downto 0);
      elsif ALUsig = "0010" then        -- A := buss'
        A(7 downto 0) <= not DATA_BUS(7 downto 0);
      elsif ALUsig = "0011" then        -- Set Z if bit indexed by DATA_BUS in A is 0
        -- Z <= A(DATA_BUS(2 downto 0));
      elsif ALUsig = "0100" then        -- A := A + buss
        A <= A + DATA_BUS(7 downto 0);
      elsif ALUsig = "0101" then        -- A := A - buss
        A <= A - DATA_BUS(7 downto 0);
      elsif ALUsig = "0110" then        -- A := A AND buss
        A(7 downto 0) <= A(7 downto 0) and DATA_BUS(7 downto 0);
      elsif ALUsig = "0111" then        -- A := A OR buss
        A(7 downto 0) <= A(7 downto 0) or DATA_BUS(7 downto 0);
      elsif ALUsig = "1000" then        -- A := A XOR buss
        A(7 downto 0) <= A(7 downto 0) xor DATA_BUS(7 downto 0);
      elsif ALUsig = "1001" then        -- A := A + buss
        A(7 downto 0) <= A(7 downto 0) + DATA_BUS(7 downto 0);
      elsif ALUsig = "1010" then        -- Shift A left
        A(7 downto 0) <= A(6 downto 0) & '0';
      elsif ALUsig = "1011" then        -- Shift A aritm right
        A(7 downto 0) <= A(7) & A(7 downto 1);
      elsif ALUsig = "1100" then
        A(7 downto 0) <= CARRY & A(7 downto 1);
      end if;
    end if;
  end process;
  
  -- TB : To Bus
  DATA_BUS <=
    "00000000" & IR when TBsig = "0001" else
    PM when TBsig = "0010" else
    PC when TBsig = "0011" else
    "00000000" & PC(15 downto 8) when TBsig = "0100" else
    SP when TBsig = "0101" else
    "00000000" & SP(15 downto 8) when TBSIG = "0110" else
    "00000000" & A(7 downto 0)  when TBsig = "0111" else
    "00000000" & X  when TBsig = "1000" else
    "00000000" & Y  when TBsig = "1001" else
    "00000000" & UADDRsig when TBsig = "1101" else
    ASR when TBsig = "1110" else
    "00000000" & ASR(15 downto 8) when TBsig = "1111" else
    (others => '0');

  -- FB : From Bus
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        SP <= (others => '0');
        X <= (others => '0');
        Y <= (others => '0');
      elsif FBsig = "0010" then
        -- Implement writing to memory
      elsif FBsig = "0101" then
        SP <= DATA_BUS(7 downto 0) & DATA_BUS(15 downto 8);
      elsif FBsig = "0110" then
        SP(15 downto 8) <= DATA_BUS(7 downto 0);
      elsif FBsig = "1000" then
        X <= DATA_BUS(7 downto 0);
      elsif FBsig = "1001" then
        Y <= DATA_BUS(7 downto 0);
      end if;
    end if;
  end process;
  
  -- PC : Program Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        PC <= (others => '0');
      elsif FBsig = "0011" then
        PC <= DATA_BUS(7 downto 0) & DATA_BUS(15 downto 8);
      elsif FBsig = "0100" then
        PC(15 downto 8) <= DATA_BUS(7 downto 0);
      elsif PCsig = '1' then
        PC <= PC + 1;
      end if;
    end if;
  end process; 
  
  -- LC : Loop Counter
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        LC <= (others => '0');
      elsif LCsig = "01" then
        LC <= LC - 1;
      elsif LCsig = "10" then
        LC <= DATA_BUS(7 downto 0);
      elsif LCsig = "11" then
        LC <= UADDRsig;
      end if;
    end if;
  end process;
  
  -- SEQ
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        uPC <= (others => '0');
        SuPC <= (others => '0');
      elsif SEQsig = b"0000" then
        uPC <= uPC + 1;
        
      elsif SEQsig = b"0001" then
        uPC <= OPVECsig;
        
      elsif SEQsig = b"0010" then
        uPC <= ADDRVECsig;
        
      elsif SEQsig = b"0011" then
        uPC <= b"00000000";
        
      elsif SEQsig = b"0100" then
        if ZERO = '0' then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"0101" then
        uPC <= UADDRsig;
        
      elsif SEQsig = b"0110" then
        SuPC <= uPC + 1;
        uPC <= uADDRsig;
        
      elsif SEQsig = b"0111" then
        uPC <= SuPC;
        
      elsif SEQsig = b"1000" then
        if ZERO = '1' then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"1001" then
        if SIGN = '1' then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"1010" then
        if CARRY = '1' then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"1011" then
        if OVERFLOW = '1' then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"1100" then
        if LC = 0 then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"1101" then
        if CARRY = '0' then
          uPC <= UADDRsig;
        end if;
        
      elsif SEQsig = b"1110" then
        if OVERFLOW = '0' then
          uPC <= UADDRsig;
        end if;
      elsif SEQsig = b"1111" then
        uPC <= uPC - 1;
      end if;
    end if;
  end process;
     	
  -- IR : Instruction Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        IR <= (others => '0');
      elsif (FBsig = "0001") then
        IR <= DATA_BUS(7 downto 0);
      end if;
    end if;
  end process;
	
  -- ASR : Address Register
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        ASR <= (others => '0');
      elsif (FBsig = "1110") then
        ASR <= DATA_BUS;
      elsif FBsig = "1111" then
        ASR(15 downto 8) <= DATA_BUS(7 downto 0);
      end if;
    end if;
  end process;

  foobar <= '0';

  CARRY <= A(8);
  ZERO <= '1' when A = 0 else '0';
  OVERFLOW <= '0';                      -- To be implemented
  SIGN <= A(7);
      
	
  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  -- program memory component connection
  U1 : pMem port map(pAddr=>ASR, pData=>PM);

  U2 : opVec port map(opAddr=>OPADDRsig, opVector=>OPVECsig);
  
  U3 : addrVec port map(addrAddr=>ADDRADDRsig, addrVector=>ADDRVECsig);     

  OPADDRsig <= IR(7 downto 3);
  ADDRADDRsig <= IR(2 downto 0);
  
  -- micro memory signal assignments
  UADDRsig      <= uM(7 downto 0);
  SEQsig        <= uM(11 downto 8);
  STACKsig      <= uM(13 downto 12);
  LCsig         <= uM(15 downto 14);
  PCsig         <= uM(16);
  FBsig         <= uM(20 downto 17);
  TBsig         <= uM(24 downto 21);
  ALUsig        <= uM(28 downto 25);

  -- Status register assignment
  S <= SIGN & OVERFLOW & '0' & '0' & '0' & '0' & ZERO & CARRY;
end Behavioral;
