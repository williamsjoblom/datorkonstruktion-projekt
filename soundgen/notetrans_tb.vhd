LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY notetrans_tb IS
END notetrans_tb;

ARCHITECTURE behavior OF notetrans_tb IS

  --Component Declaration for the Unit Under Test (UUT)
  COMPONENT notetrans
  PORT(clk: in std_logic;
       chreg: in unsigned(1 downto 0);
       nte: in std_logic;
       rst: in std_logic;
       rdy: in std_logic;
       send: out std_logic;
       datareg: in unsigned(7 downto 0);
       nte_done: out std_logic;
       translatednote: out unsigned(7 downto 0)
       );
  END COMPONENT;

  --Inputs
  signal clk : std_logic:= '0';
  signal rst : std_logic:= '0';
  signal chreg : unsigned(1 downto 0) := b"11";
  signal nte : std_logic := '0';
  signal send : std_logic := '0';
  signal datareg : unsigned(7 downto 0) := x"00";
  signal translatednote : unsigned(7 downto 0) := x"00";
  signal nte_done : std_logic := '1';
  signal rdy : std_logic;

  --Clock period definitions
  constant clk_period : time:= 10 ns;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  uut: notetrans PORT MAP (
    clk => clk,
    rst => rst,
    rdy => rdy,
    chreg => chreg,
    nte => nte,
    send => send,
    translatednote => translatednote,
    datareg => datareg,
    nte_done => nte_done
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
      nte <= '1';
      chreg <= b"01";
      datareg <= b"00010001";
      wait for 2 us;
      rdy <= '1';
      nte <= '0';
      
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

