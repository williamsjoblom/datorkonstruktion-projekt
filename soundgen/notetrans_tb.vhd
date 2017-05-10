LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY notetrans_tb IS
END notetrans_tb;

ARCHITECTURE behavior OF notetrans_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT notetrans
  PORT(clk: in std_logic;
       ch0: in std_logic;
       ch1: in std_logic;
       nte: in std_logic;
       rst: in std_logic;
       send: in std_logic;
       in_data: in unsigned(7 downto 0);
       out_data: out unsigned(7 downto 0)
       );
  END COMPONENT;

  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';
  signal ch0 : std_logic := '0';
  signal ch1 : std_logic := '0';
  signal nte : std_logic := '0';
  signal send : std_logic := '0';
  signal in_data : unsigned(7 downto 0) := x"00";
  signal out_data : unsigned(7 downto 0) := x"00";

  --Clock period definitions
  constant clk_period : time:= 10 ns;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: notetrans PORT MAP (
    clk => clk,
    rst => rst,
    ch0 => ch0,
    ch1 => ch1,
    nte => nte,
    send => send,
    in_data => in_data,
    out_data => out_data
  );
		
  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc: process
    begin
      wait for 1 us;
      rst <= '1';
      wait for 1 us;
      rst <= '0';
      ch0 <= '1';
      ch1 <= '0';
      wait for 2 us;
      in_data <= b"10010000";

      nte <= '1';
      
      wait for 1 us;
       <= '1';
      wait for 1 us;
      rdy <= '0';
      wait for 1 us;
      rdy <= '1';
      wait for 1 us;
      rdy <= '0';
      wait for 1 us;
      rdy <= '1';
      wait for 1 us;
      rdy <= '0';
      wait for 1 us;
      rdy <= '1';
      wait for 1 us;
      rdy <= '0';
      wait;
    end process;
END;

