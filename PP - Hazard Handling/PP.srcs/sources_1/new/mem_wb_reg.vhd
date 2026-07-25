----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.07.2026 23:28:51
-- Design Name: 
-- Module Name: mem_wb_reg - Behavioral
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

entity mem_wb_reg is
    port(
        clk          : in std_logic;
        reset        : in std_logic;
        result_in    : in std_logic_vector(15 downto 0);
        mem_data_in  : in std_logic_vector(15 downto 0);
        write_reg_in : in std_logic_vector(3 downto 0);
        reg_write_in : in std_logic;
        mem_to_reg_in: in std_logic;
        in_enable_in : in std_logic;
        out_enable_in : in std_logic;
        result_out    : out std_logic_vector(15 downto 0);
        mem_data_out  : out std_logic_vector(15 downto 0);
        write_reg_out : out std_logic_vector(3 downto 0);
        out_enable_out : out std_logic;
        reg_write_out : out std_logic;
        mem_to_reg_out: out std_logic;
        in_enable_out : out std_logic );
end mem_wb_reg;

architecture Behavioral of mem_wb_reg is

begin
    process (clk)
    begin
        if reset = '1' then
            result_out    <= (others => '0');
            mem_data_out    <= (others => '0');
            write_reg_out  <= (others => '0');
            reg_write_out  <= '0';
            mem_to_reg_out <= '0';
            in_enable_out  <= '0';
            out_enable_out <= '0';
        elsif (rising_edge(clk)) then
            result_out     <= result_in;
            mem_data_out   <= mem_data_in;
            write_reg_out  <= write_reg_in;
            reg_write_out  <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            in_enable_out  <= in_enable_in;
            out_enable_out <= out_enable_in;
        end if;
    end process;

end Behavioral;
