----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2026 14:49:25
-- Design Name: 
-- Module Name: if_id_reg - Behavioral
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

entity if_id_reg is
    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        flush    : in  std_logic;
        stall    : in  std_logic;
        pc_in    : in  std_logic_vector(3 downto 0);
        insn_in  : in  std_logic_vector(15 downto 0);
        pc_out   : out std_logic_vector(3 downto 0);
        insn_out : out std_logic_vector(15 downto 0) );
end if_id_reg;

architecture rtl of if_id_reg is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc_out   <= (others => '0');
            insn_out <= (others => '0');
        elsif rising_edge(clk) then
            if flush = '1' then
                insn_out <= (others => '0');  -- NOP/bubble
                pc_out   <= pc_in;
            elsif stall = '0' then
                pc_out   <= pc_in;
                insn_out <= insn_in;
            end if;
        end if;
    end process;
end rtl;