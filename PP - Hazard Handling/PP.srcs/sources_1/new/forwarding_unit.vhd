----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2026 01:43:11
-- Design Name: 
-- Module Name: forwarding_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity forwarding_unit is
  Port ( ex_reg : in std_logic_vector(3 downto 0);
         mem_write_reg : in std_logic_vector(3 downto 0);
         wb_write_reg : in std_logic_vector(3 downto 0);
         mem_reg_write : in std_logic;
         wb_reg_write : in std_logic;
         result       : out std_logic_vector(1 downto 0));
end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin
    process(ex_reg, mem_write_reg, wb_write_reg, mem_reg_write, wb_reg_write)
    begin
        if (mem_reg_write = '1') AND (mem_write_reg = ex_reg) then
            result <= "10";
        elsif (wb_reg_write = '1') AND (wb_write_reg = ex_reg) then
            result <= "01";
        else 
            result <= "00";
        end if;
    end process;
end Behavioral;
