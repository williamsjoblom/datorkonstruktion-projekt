library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- MMU Interface
entity mmu is
  port(
    clk     : in std_logic;
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
  
  signal ramOut : unsigned(15 downto 0);
  signal romOut : unsigned(15 downto 0);

  signal ramWr : std_logic;
  signal pictWr : std_logic;

  signal ledState : std_logic_vector(7 downto 0) := x"FF";

  alias BC1 : std_logic is IO_P(0);
  alias BDIR : std_logic is IO_P(1);
  
begin  -- MMU

  dataOut <= ramOut when addr(15 downto 13) = "000" else romOut;

  ramWr <= wr when addr(15 downto 13) = "000" else '0';
  pictWr <= wr when addr(15 downto 14) = "01" else '0';

  IO_N <= (others => '0');

  IO_P <= "0000000000000000000" & clk;

  
    
  process(clk)
  begin
    if rising_edge(clk) then
      if wr='1' then
         ledState <= std_logic_vector(dataIn);
      end if;
    end if;
  end process;
  
  Led <= ledState;
       
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
    addr1=>addr(13 downto 0),
    we2=>'0',
    data_in2=>"00000000",
    data_out2=>vgaDataOut,
    addr2=>vgaAddr
    );

  

end Behavioral;
