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
    rOut  : out unsigned(15 downto 0)
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
  
  signal ramOut : unsigned(15 downto 0);
  signal romOut : unsigned(15 downto 0);

  signal ramWr : std_logic;
begin  -- MMU

  dataOut <= ramOut when addr(15 downto 13) = "000" else romOut;

  ramWr <= wr when addr(15 downto 13) = "000" else '0';
       
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

  

end Behavioral;
