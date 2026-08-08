----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.07.2026 14:41:18
-- Design Name: 
-- Module Name: display - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display is
    Port (
        clk   : in  std_logic;
        value : in  std_logic_vector(3 downto 0);
        seg   : out std_logic_vector(0 TO 6);
        an    : out std_logic_vector(3 downto 0);
        dp    : out std_logic
    );
end display;

architecture Behavioral of display is
    COMPONENT bcd_to_hex IS
	PORT( B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	      H : OUT STD_LOGIC_VECTOR(0 TO 6));
    END COMPONENT;

    signal clk_divider : unsigned(17 downto 0) := (others => '0');
    signal d0, d1, d2, d3 : std_logic_vector(0 TO 6);
    signal ones, tens : std_logic_vector(3 downto 0);

begin

-- Converter
    PROCESS(value)
        VARIABLE value_int : INTEGER;
    BEGIN
    value_int := to_integer(unsigned(value));

    tens <= std_logic_vector(to_unsigned(value_int / 10, 4));
    ones <= std_logic_vector(to_unsigned(value_int MOD 10, 4));
    END PROCESS;

-- 7-segment decoder outputs
    ds0: bcd_to_hex PORT MAP(ones, d0);
    ds1: bcd_to_hex PORT MAP(tens, d1);
    d2 <= "1111111";
    d3 <= "1111111";

-- output to 7-segment displays 
-- NO NEED TO EDIT

    PROCESS (clk) -- reduce 100MHz input clock frequency
    BEGIN
        IF (clk'event AND clk = '1') THEN
            clk_divider <= clk_divider + 1;
        END IF;
    END PROCESS;
    
    WITH clk_divider(17 DOWNTO 16) SELECT -- determine which digit to display
        seg <= d0 WHEN "00",
               d1 WHEN "01",
               d2 WHEN "10",
               d3 WHEN OTHERS;

    an(0) <= clk_divider(17) OR clk_divider(16); -- determine when to display each digit
    an(1) <= clk_divider(17) OR NOT(clk_divider(16));
    an(2) <= NOT(clk_divider(17)) OR clk_divider(16);
    an(3) <= NOT(clk_divider(17)) OR NOT(clk_divider(16));
    
    dp <= '1';

end Behavioral;


-- BCD to Hex from somewhere
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd_to_hex IS
    PORT( B : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
          H : OUT STD_LOGIC_VECTOR(0 TO 6));
END bcd_to_hex;

ARCHITECTURE logicfunc OF bcd_to_hex IS
BEGIN
    H(0) <= (B(2) AND (NOT B(1)) AND (NOT B(0))) OR 
            ((NOT B(3)) AND (NOT B(2)) AND (NOT B(1)) AND B(0));
            
    H(1) <= B(2) AND (B(1) XOR B(0));
    
    H(2) <= (NOT B(2)) AND B(1) AND (NOT B(0));
    
    H(3) <= ((NOT B(3)) AND (NOT B(2)) AND (NOT B(1)) AND B(0)) OR 
			(B(2) AND (NOT B(1)) AND (NOT B(0))) OR
			(B(2) AND B(1) AND B(0));
			
	H(4) <= B(0) OR (B(2) AND (NOT B(1)));
	
	H(5) <= (B(1) AND B(0)) OR 
			((NOT B(2)) AND B(1)) OR
            ((NOT B(3)) AND (NOT B(2)) AND B(0));
    
    H(6) <= ((NOT B(3)) AND (NOT B(2)) AND (NOT B(1))) OR 
			(B(2) AND B(1) AND B(0));
END logicfunc;