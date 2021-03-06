LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY proj_tb IS
END proj_tb;

ARCHITECTURE behavior OF proj_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT proj
  generic(
      RST_CLKS : integer
   ); 
  PORT(clk : IN std_logic;
       rstB : IN std_logic;
       btnUpB : in std_logic;
       btnRightB : in std_logic;
       btnDownB : in std_logic;
       btnLeftB : in std_logic);
  END COMPONENT;

  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';

  --Clock period definitions
  constant clk_period : time:= 10 ns;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: proj
    generic map (
      RST_CLKS => 3)
    PORT MAP (
    clk => clk,
    rstB => rst,
    btnUpB => '0',
    btnRightB => '0',
    btnDownB => '0',
    btnLeftB => '0'
    
  );
		
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  rst <= '1', '0' after 15 us;
END;

