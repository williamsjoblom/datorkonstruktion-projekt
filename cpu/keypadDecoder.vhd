----------------------------------------------------------------------------------
-- Company: Digilent Inc 2011
-- Engineer: Michelle Yu  
-- Create Date:      17:18:24 08/23/2011 
--
-- Module Name:    Decoder - Behavioral 
-- Project Name:  PmodKYPD
-- Target Devices: Nexys3
-- Tool versions: Xilinx ISE 13.2
-- Description: 
--	This file defines a component Decoder for the demo project PmodKYPD. 
-- The Decoder scans each column by asserting a low to the pin corresponding to the column 
-- at 1KHz. After a column is asserted low, each row pin is checked. 
-- When a row pin is detected to be low, the key that was pressed could be determined.
--
-- Revision: 
-- Revision 0.01 - File Created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity keypadDecoder is
  port (
    clk : in std_logic;
    rst : in std_logic;
    row : in std_logic_vector(3 downto 0);
    col : out std_logic_vector(3 downto 0);
    decodeOut : out unsigned(4 downto 0) := "10000"
  );
end keypadDecoder;

architecture Behavioral of keypadDecoder is

  signal keyValue : unsigned(3 downto 0);
  
  signal sclk : unsigned(19 downto 0);
  signal pressed : std_logic := '0';

begin
  process(clk) begin
     if rising_edge(clk) then
       if rst = '1' then
         pressed <= '0';
         decodeOut <= "10000";
         sclk <= "00000000000000000000";
       else
         if sclk = "00000000000000000000" then
           if pressed = '1' then
             pressed <= '0';
             decodeOut <= '0' & keyValue;
           else
             decodeOut <= "10000";
           end if;

           sclk <= sclk+1;
         
         -- 1ms
         elsif sclk = "00011000011010100000" then 
           --C1
           col <= "0111";
           sclk <= sclk+1;
           -- check row pins
         elsif sclk = "00011000011010101000" then	
           --R1
           if row = "0111" then
             keyValue <= "0001"; --1
             pressed <= '1';
             --R2
           elsif row = "1011" then
             keyValue <= "0100"; --4
             pressed <= '1';
             --R3
           elsif row = "1101" then
             keyValue <= "0111"; --7
             pressed <= '1';
             --R4
           elsif row = "1110" then
             keyValue <= "0000"; --0
             pressed <= '1';
           end if;
           sclk <= sclk+1;
           -- 2ms
         elsif sclk = "00110000110101000000" then	
           --C2
           col <= "1011";
           sclk <= sclk + 1;
           -- check row pins
         elsif sclk = "00110000110101001000" then	
           --R1
           if row = "0111" then		
             keyValue <= "0010"; --2
             pressed <= '1';
             --R2
           elsif row = "1011" then
             keyValue <= "0101"; --5
             pressed <= '1';
             --R3
           elsif row = "1101" then
             keyValue <= "1000"; --8
             pressed <= '1';
             --R4
           elsif row = "1110" then
             keyValue <= "1111"; --F
             pressed <= '1';
           end if;
           sclk <= sclk+1;	
           --3ms
         elsif sclk = "01001001001111100000" then 
           --C3
           col<= "1101";
           sclk <= sclk+1;
           -- check row pins
         elsif sclk = "01001001001111101000" then 
           --R1
           if row = "0111" then
             keyValue <= "0011"; --3
             pressed <= '1';
             --R2
           elsif row = "1011" then
             keyValue <= "0110"; --6
             pressed <= '1';
             --R3
           elsif row = "1101" then
             keyValue <= "1001"; --9
             pressed <= '1';
             --R4
           elsif row = "1110" then
             keyValue <= "1110"; --E
             pressed <= '1';
           end if;
           sclk <= sclk+1;
           --4ms
         elsif sclk = "01100001101010000000" then 			
           --C4
           col <= "1110";
           sclk <= sclk+1;
           -- check row pins
         elsif sclk = "01100001101010001000" then 
           --R1
           if row = "0111" then
             keyValue <= "1010"; --A
             pressed <= '1';
             --R2
           elsif row = "1011" then
             keyValue <= "1011"; --B
             pressed <= '1';
             --R3
           elsif row = "1101" then
             keyValue <= "1100"; --C
             pressed <= '1';
             --R4
           elsif row = "1110" then
             keyValue <= "1101"; --D
             pressed <= '1';
           end if;
           
           sclk <= "00000000000000000000";
           
         else
           sclk <= sclk+1;	
         end if;
       end if;
     end if;
   end process;								 
 end Behavioral;
