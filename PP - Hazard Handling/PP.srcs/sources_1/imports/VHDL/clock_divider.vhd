----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.07.2026 20:41:44
-- Design Name: 
-- Module Name: clock_divider - Behavioral
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

entity clock_divider is
    Port (
        clk      : in std_logic;
        slow_clk : out std_logic
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal counter : unsigned(26 downto 0) := (others => '0');
begin

process(clk)
begin
    if rising_edge(clk) then
        counter <= counter + 1;
    end if;
end process;

slow_clk <= counter(26);

end Behavioral;
