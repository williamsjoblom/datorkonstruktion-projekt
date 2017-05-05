----------------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Author:  Mihaita Nagy
--          Copyright 2014 Digilent, Inc.
----------------------------------------------------------------------------
-- 
-- Create Date:    17:11:29 03/06/2013 
-- Design Name: 
-- Module Name:    dbncr - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- This module represents a debouncer and is used to synchronize with the system clock
-- and remove glitches from the incoming button signals
--
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dbncr is
   generic(
      NR_OF_CLKS : integer := 4095 -- Number of System Clock periods while the incoming signal 
   );                              -- has to be stable until a one-shot output signal is generated
   port(
      clk : in std_logic;
      sig_i : in std_logic;
      sig_o : out std_logic
   );
end dbncr;

architecture Behavioral of dbncr is

signal cnt : integer range 0 to NR_OF_CLKS-1;
signal sigTmp : std_logic;
signal stble : std_logic := '0';

begin

   DEB: process(clk)
   begin
      if rising_edge(clk) then
         if sig_i = sigTmp then -- Count the number of clock periods if the signal is stable
            if cnt = NR_OF_CLKS-1 then
               stble <= sig_i;
            else
               cnt <= cnt + 1;
            end if;
         else -- Reset counter and sample the new signal value
            cnt <= 0;
            sigTmp <= sig_i;
         end if;
      end if;
   end process DEB;
   
   -- generate the one-shot output signal
   sig_o <= stble; --'1' when stbleTmp = '0' and stble = '1' else '0';

end Behavioral;
