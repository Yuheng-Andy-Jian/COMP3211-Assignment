----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.07.2026 14:50:14
-- Design Name: 
-- Module Name: id_ex_reg - Behavioral
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

entity id_ex_reg is
    port ( clk         : in  std_logic;
           reset       : in  std_logic;
           flush       : in  std_logic;
           rs_data_in  : in  std_logic_vector(15 downto 0);
           rt_data_in  : in  std_logic_vector(15 downto 0);
           imm_in      : in  std_logic_vector(15 downto 0);
           opcode_in   : in  std_logic_vector(3 downto 0);
           write_reg_in: in  std_logic_vector(3 downto 0);
           reg_write_in  : in std_logic;
           alu_src_in    : in std_logic;
           mem_write_in  : in std_logic;
           mem_to_reg_in : in std_logic;
           in_enable_in  : in std_logic;
           out_enable_in : in std_logic;
           sadd_enable_in: in std_logic;
           dis_enable_in : in std_logic;
           rs_data_out  : out std_logic_vector(15 downto 0);
           rt_data_out  : out std_logic_vector(15 downto 0);
           imm_out      : out std_logic_vector(15 downto 0);
           opcode_out   : out std_logic_vector(3 downto 0);
           write_reg_out: out std_logic_vector(3 downto 0);
           reg_write_out  : out std_logic;
           alu_src_out    : out std_logic;
           mem_write_out  : out std_logic;
           mem_to_reg_out : out std_logic;
           in_enable_out  : out std_logic;
           out_enable_out : out std_logic;
           sadd_enable_out: out std_logic;
           dis_enable_out : out std_logic;
           
           -- New
           rs_reg_in   : in std_logic_vector(3 downto 0);  
           rt_reg_in   : in std_logic_vector(3 downto 0);
           rs_reg_out   : out std_logic_vector(3 downto 0);  
           rt_reg_out   : out std_logic_vector(3 downto 0) );
end id_ex_reg;
 
architecture behavioral of id_ex_reg is
begin
    process(clk)
    begin
        if reset = '1' then
            rs_data_out    <= (others => '0');
            rt_data_out    <= (others => '0');
            imm_out        <= (others => '0');
            opcode_out     <= (others => '0');
            write_reg_out  <= (others => '0');
            reg_write_out  <= '0';
            alu_src_out    <= '0';
            mem_write_out  <= '0';
            mem_to_reg_out <= '0';
            in_enable_out  <= '0';
            out_enable_out <= '0';
            sadd_enable_out<= '0';
            dis_enable_out <= '0';
            
            rs_reg_out <= (others => '0');
            rt_reg_out <= (others => '0');
        elsif (rising_edge(clk)) then
            if flush = '1' then
                rs_data_out    <= rs_data_in;
                rt_data_out    <= rt_data_in;
                imm_out        <= imm_in;
                opcode_out     <= opcode_in;
                write_reg_out  <= write_reg_in;
                reg_write_out  <= '0';
                alu_src_out    <= '0';
                mem_write_out  <= '0';
                mem_to_reg_out <= '0';
                in_enable_out  <= '0';
                out_enable_out <= '0';
                sadd_enable_out<= '0';
                dis_enable_out <= '0';
                
                rs_reg_out <= rs_reg_in;
                rt_reg_out <= rt_reg_in;            
            else
                rs_data_out    <= rs_data_in;
                rt_data_out    <= rt_data_in;
                imm_out        <= imm_in;
                opcode_out     <= opcode_in;
                write_reg_out  <= write_reg_in;
                reg_write_out  <= reg_write_in;
                alu_src_out    <= alu_src_in;
                mem_write_out  <= mem_write_in;
                mem_to_reg_out <= mem_to_reg_in;
                in_enable_out  <= in_enable_in;
                out_enable_out <= out_enable_in;
                sadd_enable_out<= sadd_enable_in;
                dis_enable_out <= dis_enable_in;
                
                rs_reg_out <= rs_reg_in;
                rt_reg_out <= rt_reg_in; 
            end if;
        end if;
    end process;
end behavioral;
