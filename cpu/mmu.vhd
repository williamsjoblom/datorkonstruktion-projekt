library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- MMU Interface
entity mmu is
  port(
    clk     : in std_logic;
    we      : in std_logic;
    addr    : in unsigned(15 downto 0);
    dataIn  : in unsigned(7 downto 0);
    dataOut : out unsigned(15 downto 0)
    );
end mmu;

architecture Behavioral of mmu is
  component pMem
    port(pAddr : in unsigned(15 downto 0);
         pData : out unsigned(15 downto 0));
  end component;

  component ramMem
    port (clk		: in std_logic;
         we		: in std_logic;
         dataIn	        : in unsigned(7 downto 0);
         dataOut	: out unsigned(15 downto 0);
         addr	        : in unsigned(12 downto 0));
   end component;
  
  signal ramOut : unsigned(15 downto 0);
  signal romOut : unsigned(15 downto 0);
begin  -- MMU

  dataOut <= ramOut when addr(15 downto 13) = "000" else romOut;
       
  U1 : ramMem port map (
    clk  => clk,
    we   => we,
    addr => addr(12 downto 0),
    dataIn => dataIn,
    dataOut => ramOut
  );

  U2 : pMem port map (
    pAddr => addr,
    pData => romOut
  );

  

end Behavioral;
