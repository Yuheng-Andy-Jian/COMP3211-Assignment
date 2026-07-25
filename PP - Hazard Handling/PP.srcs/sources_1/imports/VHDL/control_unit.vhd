---------------------------------------------------------------------------
-- control_unit.vhd - Control Unit Implementation
--
-- Notes: refer to headers in single_cycle_core.vhd for the supported ISA.
--
--  control signals:
--     reg_dst    : asserted for ADD instructions, so that the register
--                  destination number for the 'write_register' comes from
--                  the rd field (bits 3-0). 
--     reg_write  : asserted for ADD and LOAD instructions, so that the
--                  register on the 'write_register' input is written with
--                  the value on the 'write_data' port.
--     alu_src    : asserted for LOAD and STORE instructions, so that the
--                  second ALU operand is the sign-extended, lower 4 bits
--                  of the instruction.
--     mem_write  : asserted for STORE instructions, so that the data 
--                  memory contents designated by the address input are
--                  replaced by the value on the 'write_data' input.
--     mem_to_reg : asserted for LOAD instructions, so that the value fed
--                  to the register 'write_data' input comes from the
--                  data memory.
--
--
-- Copyright (C) 2006 by Lih Wen Koh (lwkoh@cse.unsw.edu.au)
-- All Rights Reserved. 
--
-- The single-cycle processor core is provided AS IS, with no warranty of 
-- any kind, express or implied. The user of the program accepts full 
-- responsibility for the application of the program and the use of any 
-- results. This work may be downloaded, compiled, executed, copied, and 
-- modified solely for nonprofit, educational, noncommercial research, and 
-- noncommercial scholarship purposes provided that this notice in its 
-- entirety accompanies all copies. Copies of the modified software can be 
-- delivered to persons who use it solely for nonprofit, educational, 
-- noncommercial research, and noncommercial scholarship purposes provided 
-- that this notice in its entirety accompanies all copies.
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic;
           -- Lab 02
           in_enable  : out std_logic;
           out_enable : out std_logic;
           sadd_enable : out std_logic;
           
           -- Lab03
           bne_enable : out std_logic;
           dis_enable : out std_logic);
end control_unit;

architecture behavioural of control_unit is

constant OP_NOOP  : std_logic_vector(3 downto 0) := "0000"; --0
constant OP_LOAD  : std_logic_vector(3 downto 0) := "0001"; -- 1
constant OP_STORE : std_logic_vector(3 downto 0) := "0010"; -- 2
constant OP_ADD   : std_logic_vector(3 downto 0) := "0011"; -- 3

-- Lab02
constant OP_IN : std_logic_vector(3 downto 0) := "0100"; -- 4
constant OP_OUT : std_logic_vector(3 downto 0) := "0101"; -- 5
constant OP_SADD : std_logic_vector(3 downto 0) := "0110"; -- 6

-- Lab03
constant OP_BNE : std_logic_vector(3 downto 0) := "0111"; -- 7
constant OP_DIS : std_logic_vector(3 downto 0) := "1000"; -- 8


begin

    reg_dst    <= '1' when (opcode = OP_ADD or opcode = OP_SADD) else
                  '0';

    reg_write  <= '1' when (opcode = OP_ADD 
                            or opcode = OP_LOAD
                            or opcode = OP_IN
                            or opcode = OP_SADD) else
                  '0';
    
    alu_src    <= '1' when (opcode = OP_LOAD 
                           or opcode = OP_STORE) else
                  '0';
                 
    mem_write  <= '1' when opcode = OP_STORE else
                  '0';
                 
    mem_to_reg <= '1' when opcode = OP_LOAD else
                  '0';
                  
    in_enable <= '1' when opcode = OP_IN else '0';
    
    out_enable <= '1' when opcode = OP_OUT else '0';
    
    sadd_enable <= '1' when opcode = OP_SADD else '0';
    
    bne_enable <= '1' when opcode = OP_BNE else '0';
    
    dis_enable <= '1' when opcode = OP_DIS else '0';
    
end behavioural;
