----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.07.2026 23:28:51
-- Design Name: 
-- Module Name: hazard_detector - Behavioral
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
library ieee;
use ieee.std_logic_1164.all;

entity hazard_detector is
    port( ex_mem_to_reg : in  std_logic;
          ex_write_reg  : in  std_logic_vector(3 downto 0);
          id_rs         : in  std_logic_vector(3 downto 0);
          id_rt         : in  std_logic_vector(3 downto 0);
          stall         : out std_logic );
end hazard_detector;
 
architecture behavioral of hazard_detector is
begin
    process(ex_mem_to_reg, ex_write_reg, id_rs, id_rt)
    begin
        if (ex_mem_to_reg = '1') and
           ((ex_write_reg = id_rs) or (ex_write_reg = id_rt)) then
            stall <= '1';
        else
            stall <= '0';
        end if;
    end process;
end behavioral;
