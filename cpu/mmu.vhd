library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- MMU Interface
entity mmu is
  port(
    clk     : in std_logic;
    rst     : in std_logic;
    wr      : in std_logic;
    addr    : in unsigned(15 downto 0);
    dataIn  : in unsigned(7 downto 0);
    dataOut : out unsigned(15 downto 0);

    -- Direct RAM access, utilizes dual RAM ports to enable faster stack ops.
    rWr   : in std_logic;
    rAddr : in unsigned(15 downto 0);
    rIn   : in unsigned(7 downto 0);
    rOut  : out unsigned(15 downto 0);
    
    IO_P : out std_logic_vector(19 downto 0);
    IO_N : out std_logic_vector(19 downto 0);

    vgaAddr : in unsigned(13 downto 0);
    vgaDataOut : out std_logic_vector(7 downto 0);

    Led   : out std_logic_vector(7 downto 0)
    );
end mmu;

architecture Behavioral of mmu is
  component pMem
    port(pAddr : in unsigned(14 downto 0);
         pData : out unsigned(15 downto 0));
  end component;

  component ramMem
    port (clk		: in std_logic;
         wr1		: in std_logic;
         data1In	: in unsigned(7 downto 0);
         data1Out	: out unsigned(15 downto 0);
         addr1	        : in unsigned(12 downto 0);

         wr2		: in std_logic;
         data2In	: in unsigned(7 downto 0);
         data2Out	: out unsigned(15 downto 0);
         addr2	        : in unsigned(12 downto 0));
   end component;

  -- picture memory component
  component pictMem
    port ( clk			: in std_logic;                         -- system clock
	 -- port 1
           we1		        : in std_logic;                         -- write enable
           data_in1	        : in std_logic_vector(7 downto 0);      -- data in
           data_out1	        : out std_logic_vector(7 downto 0);     -- data out
           addr1	        : in unsigned(13 downto 0);             -- address
	 -- port 2
           we2			: in std_logic;                         -- write enable
           data_in2	        : in std_logic_vector(7 downto 0);      -- data in
           data_out2	        : out std_logic_vector(7 downto 0);     -- data out
           addr2		: in unsigned(13 downto 0));            -- address
  end component;

  component textMode
    port(
      clk : in std_logic;
      rst : in std_logic;
      curIn : in unsigned(7 downto 0);

      curXOut : out unsigned(7 downto 0);
      curYOut : out unsigned(7 downto 0);
      curXWr : in std_logic;
      curYWr : in std_logic;
      
      charAddr : out unsigned(13 downto 0);
      colorAddr : out unsigned(13 downto 0)
      );
  end component;

  component soundinterface
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
  end component;
  
  signal ramOut : unsigned(15 downto 0);
  signal romOut : unsigned(15 downto 0);
  signal pictOut : std_logic_vector(7 downto 0);

  signal ramWr : std_logic;
  signal pictWr : std_logic;

  signal ledState : std_logic_vector(7 downto 0) := x"FF";

  signal curX : unsigned(7 downto 0) := (others => '0');
  signal curY : unsigned(7 downto 0) := (others => '0');
  signal curXWr : std_logic := '0';
  signal curYWr : std_logic := '0';
  signal charAddr : unsigned(13 downto 0);
  signal colorAddr : unsigned(13 downto 0);

  -----------------------------------------------------------------------------
  signal soundWr : std_logic := '0';
  signal ch : unsigned(1 downto 0) := (others => '1');
  signal rdy : std_logic := '1';
  -----------------------------------------------------------------------------

  signal BB1 : std_logic_vector(19 downto 0) := (others => '0');
  signal BB2 : std_logic_vector(19 downto 0) := (others => '0');
  
  alias AY_BC1 : std_logic is BB1(0);
  alias AY_BDIR : std_logic is BB1(1);
  alias AY_RESET : std_logic is BB1(2);
  alias AY_DATA : std_logic_vector(7 downto 0) is BB2(12 downto 5);
  
begin  -- MMU

  dataOut <= ramOut when addr(15 downto 13) = "000" else
             "00000000" & unsigned(pictOut) when addr(15 downto 14) = "01" else
             
             "00000000" & curX when addr = x"2002" else
             "00000000" & curY when addr = x"2003" else
             
             "01" & charAddr when addr = x"2004" else
             "0100000000" & charAddr(13 downto 8) when addr = x"2005" else
             
             "01" & colorAddr when addr = x"2006" else
             "0100000000" & colorAddr(13 downto 8) when addr = x"2007" else

             -- ready to write signal is lsb on addr 2015.
             "000000000000000" & rdy when addr = x"2015" else
             
             romOut;

  ramWr <= wr when addr(15 downto 13) = "000" else '0';
  pictWr <= wr when addr(15 downto 14) = "01" else '0';

  curXWr <= wr when addr = x"2002" else '0';
  curYWr <= wr when addr = x"2003" else '0';

  soundWr <= wr when addr(15 downto 2) = b"00100000000100" else '0';
  ch <= addr(1 downto 0) when addr(15 downto 2) = b"00100000000100" else b"11"; 

  IO_P <= BB1;        
  IO_N <= BB2;
  
       
  U1 : ramMem port map (
    clk  => clk,
    wr1   => ramWr,
    addr1 => addr(12 downto 0),
    data1In => dataIn,
    data1Out => ramOut,

    wr2   => rWr,
    addr2 => rAddr(12 downto 0),
    data2In => rIn,
    data2Out => rOut
  );

  U2 : pMem port map (
    pAddr => addr(14 downto 0),
    pData => romOut
  );

-- picture memory component connection
  U3 : pictMem port map(
    clk=>clk,
    we1=>pictWr,
    data_in1=>std_logic_vector(dataIn),
    data_out1 => pictOut,
    addr1=>addr(13 downto 0),
    we2=>'0',
    data_in2=>"00000000",
    data_out2=>vgaDataOut,
    addr2=>vgaAddr
    );

  U4 : textMode port map(
    clk => clk,
    rst => rst,
    curIn => dataIn,

    curXOut => curX,
    curYOut => curY,
    
    curXWr => curXWr,
    curYWr => curYWr,
    
    charAddr => charAddr,
    colorAddr => colorAddr
  );
  U5 : soundinterface port map(
    clk => clk,
    rst => rst,                         
    ch => ch,
    wr => soundWr,
    datain=> dataIn,
    rdyout=>rdy,

    dataout => AY_DATA,
    BDIR => AY_BDIR,
    BC1 => AY_BC1
  );

end Behavioral;
