----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.07.2026 02:02:25
-- Design Name: 
-- Module Name: mux_3to1_16b - Behavioral
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

entity mux_3to1_16b is
    port( mux_select : in  std_logic_vector(1 downto 0);
          data_00    : in  std_logic_vector(15 downto 0);  -- no forward
          data_01    : in  std_logic_vector(15 downto 0);  -- MEM/WB forward
          data_10    : in  std_logic_vector(15 downto 0);  -- EX/MEM forward
          data_out   : out std_logic_vector(15 downto 0) );
end mux_3to1_16b;
 
architecture behavioral of mux_3to1_16b is
begin
    process(mux_select, data_00, data_01, data_10)
    begin
        case mux_select is
            when "10"   => data_out <= data_10;
            when "01"   => data_out <= data_01;
            when others => data_out <= data_00;
        end case;
    end process;
end behavioral;