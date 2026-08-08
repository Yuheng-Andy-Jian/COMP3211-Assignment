----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2026 17:28:24
-- Design Name: 
-- Module Name: saturator - Behavioral
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

entity saturator is
    port(
        sum        : in std_logic_vector(15 downto 0);
        carry      : in std_logic;
        result     : out std_logic_vector(15 downto 0)
    );
end;

architecture Behavioral of saturator is

begin
    process(sum, carry)
    begin
        if carry = '1' then
            result <= X"FFFF";
        else
            result <= sum;
        end if;
    end process;
end Behavioral;
