----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.07.2026 20:31:35
-- Design Name: 
-- Module Name: bne_unit - Behavioral
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

entity bne_unit is
    Port(
        enable        : in  std_logic;
        rs            : in  std_logic_vector(15 downto 0);
        rt            : in  std_logic_vector(15 downto 0);
        branch_taken  : out std_logic
    );
end bne_unit;

architecture Behavioral of bne_unit is
begin
    branch_taken <= '1' when ( enable= '1' and rs /= rt) else '0';
end Behavioral;
