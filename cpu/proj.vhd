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

  function BOOL_TO_SL(X : boolean)
    return std_logic is
  begin
    if X then
      return '1';
    else
      return '0';
    end if;
  end BOOL_TO_SL;


  -- micro Memory component
  component uMem
    port(uAddr : in unsigned(7 downto 0);
         uData : out unsigned(28 downto 0));
  end component;

  component mmu
    port(
      clk     : in std_logic;
      wr      : in std_logic;
      addr    : in unsigned(15 downto 0);
      dataIn  : in unsigned(7 downto 0);
      dataOut : out unsigned(15 downto 0);
      rWr   : in std_logic;
      rAddr : in unsigned(15 downto 0);
      rIn   : in unsigned(7 downto 0);
      rOut  : out unsigned(15 downto 0)
      );
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
  signal WR : std_logic;             -- Memory write enable
  signal PC : unsigned(15 downto 0); -- Program Counter
  signal ASR : unsigned(15 downto 0); -- Address Register
  signal IR : unsigned(7 downto 0); -- Instruction Register
  signal DATA_BUS : unsigned(15 downto 0); -- Data Bus

  signal ARESULT : unsigned(8 downto 0);
  signal CMPRESULT : unsigned(8 downto 0);

  -- Registers
  signal A : unsigned(8 downto 0);      -- Accumulator
  signal X : unsigned(7 downto 0);      -- X
  signal Y : unsigned(7 downto 0);      -- Y

  signal CARRY : std_logic;
  signal ZERO : std_logic;
  signal OVERFLOW : std_logic;
  signal SIGN : std_logic;
  
  signal S : unsigned(7 downto 0);      -- Status

  -- Stack
  signal SP : unsigned(15 downto 0);    -- Stack Pointer
  signal TOP : unsigned(15 downto 0);   -- Top of stack
  signal SWR : std_logic;
  

begin

  -- Accumulator register
  ARESULT <= '0' & DATA_BUS(7 downto 0) when ALUsig = "0001" else
             '0' & not DATA_BUS(7 downto 0) when ALUsig = "0010" else
             A + DATA_BUS(7 downto 0) when ALUsig = "0100" else
             A - DATA_BUS(7 downto 0) when ALUsig = "0101" else
             '0' & A(7 downto 0) and DATA_BUS(7 downto 0) when ALUsig = "0110" else
             '0' & A(7 downto 0) or DATA_BUS(7 downto 0) when ALUsig = "0111" else
             '0' & A(7 downto 0) xor DATA_BUS(7 downto 0) when ALUsig = "1000" else
             '0' & A(7 downto 0) + DATA_BUS(7 downto 0) when ALUsig = "1001" else
             '0' & A(6 downto 0) & '0' when ALUsig = "1010" else
             '0' & A(7) & A(7 downto 1) when ALUsig = "1011" else
             '0' & CARRY & A(7 downto 1) when ALUsig = "1100" else A;

  CMPRESULT <= A - DATA_BUS(7 downto 0);       
  
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        A <= (others => '0');
        ZERO <= '0';
        SIGN <= '0';
        OVERFLOW <= '0';
        CARRY <= '0';
      else
        A <= ARESULT;
      end if;

      -- Set status flags
      if ALUsig = "0001" then
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');
      elsif ALUsig = "0010" then        -- A := buss'
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');
        
      elsif ALUsig = "0011" then        -- Set Z if bit indexed by DATA_BUS in A is 0
        ZERO <= BOOL_TO_SL(ARESULT(to_integer(DATA_BUS(2 downto 0))) = '0');
        
      elsif ALUsig = "0100" then        -- A := A + buss
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');
        OVERFLOW <= '0';                -- To be implemented.
        CARRY <= ARESULT(8);
        
      elsif ALUsig = "0101" then        -- A := A - buss
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');
        OVERFLOW <= '0';                -- To be implemented.
        CARRY <= ARESULT(8);
        
      elsif ALUsig = "0110" then        -- A := A AND buss
        ZERO <= BOOL_TO_SL((A + DATA_BUS(7 downto 0)) = x"00");
        SIGN <= BOOL_TO_SL((not DATA_BUS(7)) = '0');

        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');
        
      elsif ALUsig = "0111" then        -- A := A OR buss
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');
        
      elsif ALUsig = "1000" then        -- A := A XOR buss
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        SIGN <= BOOL_TO_SL(ARESULT(7) = '1');

      elsif ALUsig = "1010" then        -- Shift A left
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        
      elsif ALUsig = "1011" then        -- Shift A aritm right
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");
        
      elsif ALUsig = "1100" then
        ZERO <= BOOL_TO_SL(ARESULT(7 downto 0) = x"00");

      elsif ALUsig = "1111" then        -- A CMP buss
        ZERO <= BOOL_TO_SL(CMPRESULT(7 downto 0) = x"00");
        SIGN <= CMPRESULT(7);
        OVERFLOW <= '0';                -- To be implemented.
        CARRY <= CMPRESULT(8);
        
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
    "00000000" & X + 1  when TBsig = "1010" else
    "00000000" & X - 1  when TBsig = "1011" else
    TOP when TBsig = "1100" else
    "00000000" & UADDRsig when TBsig = "1101" else
    ASR when TBsig = "1110" else
    "00000000" & ASR(15 downto 8) when TBsig = "1111" else
    (others => '0');
  
  -- FB : From Bus
  WR <= '1' when FBsig = "0010" else '0';
  SWR <= '1' when FBsig = "1100" else '0';
  
  process(clk)
  begin
    if rising_edge(clk) then    
      if rst = '1' then
        X <= (others => '0');
        Y <= (others => '0');
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
        PC <= PM;
      elsif FBsig = "0011" then
        PC <= DATA_BUS;
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

  -- STACK : Stack Pointer
  -- Stack starts at 0x01FF and grows down
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        SP <= x"01FF";
      elsif FBsig = "0101" then
        SP <= DATA_BUS(7 downto 0) & DATA_BUS(15 downto 8);
      elsif FBsig = "0110" then
        SP(15 downto 8) <= DATA_BUS(7 downto 0);
      elsif STACKsig = "01" then
        SP <= SP + 1;
      elsif STACKsig = "10" then
        SP <= SP - 1;
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
        else
          uPC <= uPC + 1;
        end if;
        
      elsif SEQsig = b"1001" then
        if SIGN = '1' then
          uPC <= UADDRsig;
        else
          uPC <= uPC + 1;
        end if;
        
      elsif SEQsig = b"1010" then
        if CARRY = '1' then
          uPC <= UADDRsig;
        else
          uPC <= uPC + 1;
        end if;
        
      elsif SEQsig = b"1011" then
        if OVERFLOW = '1' then
          uPC <= UADDRsig;
        else
          uPC <= uPC + 1;
        end if;
        
      elsif SEQsig = b"1100" then
        if LC = 0 then
          uPC <= UADDRsig;
        else
          uPC <= uPC + 1;
        end if;
        
      elsif SEQsig = b"1101" then
        if CARRY = '0' then
          uPC <= UADDRsig;
        else
          uPC <= uPC + 1;
        end if;
        
      elsif SEQsig = b"1110" then
        if OVERFLOW = '0' then
          uPC <= UADDRsig;
        else
          uPC <= uPC + 1;
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
        ASR <= x"FFFE";
      elsif (FBsig = "1110") then
        ASR <= DATA_BUS;
      elsif FBsig = "1111" then
        ASR(15 downto 8) <= DATA_BUS(7 downto 0);
      end if;
    end if;
  end process;

  foobar <= '0';

  --CARRY <= A(8);
  --ZERO <= '1' when A = 0 else '0';
  --OVERFLOW <= '0';                      -- To be implemented
  --SIGN <= A(7);
      
	
  -- micro memory component connection
  U0 : uMem port map(uAddr=>uPC, uData=>uM);

  U1 : mmu port map (
    clk => clk,
    wr => WR,
    addr => ASR,
    dataIn => DATA_BUS(7 downto 0),
    dataOut => PM,
    
    rWr => SWR,
    rAddr => SP,
    rIn  => DATA_BUS(7 downto 0),
    rOut => TOP
  );

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
