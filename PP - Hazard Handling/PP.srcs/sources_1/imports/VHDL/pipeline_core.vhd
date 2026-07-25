---------------------------------------------------------------------------
-- single_cycle_core.vhd - A Single-Cycle Processor Implementation
--
-- Notes : 
--
-- See single_cycle_core.pdf for the block diagram of this single
-- cycle processor core.
--
-- Instruction Set Architecture (ISA) for the single-cycle-core:
--   Each instruction is 16-bit wide, with four 4-bit fields.
--
--     noop      
--        # no operation or to signal end of program
--        # format:  | opcode = 0 |  0   |  0   |   0    | 
--
--     load  rt, rs, offset     
--        # load data at memory location (rs + offset) into rt
--        # format:  | opcode = 1 |  rs  |  rt  | offset |
--
--     store rt, rs, offset
--        # store data rt into memory location (rs + offset)
--        # format:  | opcode = 3 |  rs  |  rt  | offset |
--
--     add   rd, rs, rt
--        # rd <- rs + rt
--        # format:  | opcode = 8 |  rs  |  rt  |   rd   |
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

entity pipeline_core is
    port ( reset  : in std_logic;
           clk    : in  std_logic;
           sw     : in std_logic_vector(15 downto 0);
           led    : out std_logic_vector(15 downto 0);
           btnC   : in std_logic;
           btnL   : in std_logic;
           
           seg  : out std_logic_vector(0 to 6);
           an   : out std_logic_vector(3 downto 0);
           dp   : out std_logic);
end pipeline_core;

architecture structural of pipeline_core is

component program_counter is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           stall    : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           addr_out : out std_logic_vector(3 downto 0) );
end component;

component instruction_memory is
    port ( reset    : in  std_logic;
           clk      : in  std_logic;
           addr_in  : in  std_logic_vector(3 downto 0);
           insn_out : out std_logic_vector(15 downto 0) );
end component;

component sign_extend_4to16 is
    port ( data_in  : in  std_logic_vector(3 downto 0);
           data_out : out std_logic_vector(15 downto 0) );
end component;

component mux_2to1_4b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(3 downto 0);
           data_b     : in  std_logic_vector(3 downto 0);
           data_out   : out std_logic_vector(3 downto 0) );
end component;

component mux_2to1_16b is
    port ( mux_select : in  std_logic;
           data_a     : in  std_logic_vector(15 downto 0);
           data_b     : in  std_logic_vector(15 downto 0);
           data_out   : out std_logic_vector(15 downto 0) );
end component;

component control_unit is
    port ( opcode     : in  std_logic_vector(3 downto 0);
           reg_dst    : out std_logic;
           reg_write  : out std_logic;
           alu_src    : out std_logic;
           mem_write  : out std_logic;
           mem_to_reg : out std_logic;
           -- New Below
           in_enable  : out std_logic;
           out_enable : out std_logic;
           sadd_enable : out std_logic;
           bne_enable : out std_logic;
           dis_enable : out std_logic);
end component;

component register_file is
    port ( reset           : in  std_logic;
           clk             : in  std_logic;
           read_register_a : in  std_logic_vector(3 downto 0);
           read_register_b : in  std_logic_vector(3 downto 0);
           write_enable    : in  std_logic;
           write_register  : in  std_logic_vector(3 downto 0);
           write_data      : in  std_logic_vector(15 downto 0);
           read_data_a     : out std_logic_vector(15 downto 0);
           read_data_b     : out std_logic_vector(15 downto 0) );
end component;

component adder_4b is
    port ( src_a     : in  std_logic_vector(3 downto 0);
           src_b     : in  std_logic_vector(3 downto 0);
           sum       : out std_logic_vector(3 downto 0);
           carry_out : out std_logic );
end component;

component adder_16b is
    port ( src_a     : in  std_logic_vector(15 downto 0);
           src_b     : in  std_logic_vector(15 downto 0);
           sum       : out std_logic_vector(15 downto 0);
           carry_out : out std_logic);
end component;

component data_memory is
    port ( reset        : in  std_logic;
           clk          : in  std_logic;
           write_enable : in  std_logic;
           write_data   : in  std_logic_vector(15 downto 0);
           addr_in      : in  std_logic_vector(3 downto 0);
           data_out     : out std_logic_vector(15 downto 0) );
end component;

-- New Component
component saturator is
    port( sum      : in std_logic_vector(15 downto 0);
          carry    : in std_logic;
          result   : out std_logic_vector(15 downto 0) );
end component;

component debounce is 
    PORT( clk : IN std_logic;
          noisy_sig : IN std_logic;
          clean_sig : OUT std_logic);
end component;

component clock_divider
    Port( clk      : in std_logic;
          slow_clk : out std_logic );
end component;

component led_displays
    port ( clk       : in  std_logic;
           reset     : in  std_logic;
           enable    : in  std_logic;
           data_in   : in  std_logic_vector(15 downto 0);
           led_out   : out std_logic_vector(15 downto 0) );
end component;

component display
    Port ( clk   : in  std_logic;
           value : in  std_logic_vector(3 downto 0);
           seg   : out std_logic_vector(0 TO 6);
           an    : out std_logic_vector(3 downto 0);
           dp    : out std_logic );
end component;

component bne_unit
    Port( enable        : in  std_logic;
          rs            : in  std_logic_vector(15 downto 0);
          rt            : in  std_logic_vector(15 downto 0);
          branch_taken  : out std_logic );
end component;

component dispatch
  Port ( clk : in std_logic;
         reset : in std_logic;
         enable : in std_logic;
         rs_data : in std_logic_vector(15 downto 0);
         rt_data : in std_logic_vector(15 downto 0);
         immediate : in std_logic_vector(15 downto 0);
         cop1     : out std_logic_vector(15 downto 0);
         cop2     : out std_logic_vector(15 downto 0);
         flag     : out std_logic;
         led_data : out std_logic_vector(15 downto 0));
end component;

-- Pipeline Components
component if_id_reg
    port( clk      : in  std_logic;
          reset    : in  std_logic;
          flush    : in  std_logic;
          stall    : in  std_logic;
          pc_in    : in  std_logic_vector(3 downto 0);
          insn_in  : in  std_logic_vector(15 downto 0);
          pc_out   : out std_logic_vector(3 downto 0);
          insn_out : out std_logic_vector(15 downto 0) );
end component;

component id_ex_reg
    port( clk         : in  std_logic;
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
          
          rs_reg_in   : in std_logic_vector(3 downto 0);  
          rt_reg_in   : in std_logic_vector(3 downto 0);
          rs_reg_out   : out std_logic_vector(3 downto 0);  
          rt_reg_out   : out std_logic_vector(3 downto 0) );
end component;
 
component ex_mem_reg
    port( clk         : in  std_logic;
          reset       : in  std_logic;
          result_in     : in  std_logic_vector(15 downto 0);
          store_data_in : in  std_logic_vector(15 downto 0);
          write_reg_in  : in  std_logic_vector(3 downto 0);
          reg_write_in  : in std_logic;
          mem_write_in  : in std_logic;
          mem_to_reg_in : in std_logic;
          in_enable_in  : in std_logic;
          out_enable_in : in std_logic;
          result_out     : out std_logic_vector(15 downto 0);
          store_data_out : out std_logic_vector(15 downto 0);
          write_reg_out  : out std_logic_vector(3 downto 0);
          reg_write_out  : out std_logic;
          mem_write_out  : out std_logic;
          mem_to_reg_out : out std_logic;
          in_enable_out  : out std_logic;
          out_enable_out : out std_logic );
end component;

component mem_wb_reg
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
        reg_write_out : out std_logic;
        mem_to_reg_out: out std_logic;
        in_enable_out : out std_logic;
        out_enable_out : out std_logic );
end component;

-- Forwarding Units
component forwarding_unit 
      Port ( ex_reg : in std_logic_vector(3 downto 0);
         mem_write_reg : in std_logic_vector(3 downto 0);
         wb_write_reg : in std_logic_vector(3 downto 0);
         mem_reg_write : in std_logic;
         wb_reg_write : in std_logic;
         result       : out std_logic_vector(1 downto 0));
end component;

component mux_3to1_16b 
    port( mux_select : in  std_logic_vector(1 downto 0);
          data_00    : in  std_logic_vector(15 downto 0);  -- no forward
          data_01    : in  std_logic_vector(15 downto 0);  -- MEM/WB forward
          data_10    : in  std_logic_vector(15 downto 0);  -- EX/MEM forward
          data_out   : out std_logic_vector(15 downto 0) );
end component;

component hazard_detector
    port( ex_mem_to_reg : in  std_logic;
      ex_write_reg  : in  std_logic_vector(3 downto 0);
      id_rs         : in  std_logic_vector(3 downto 0);
      id_rt         : in  std_logic_vector(3 downto 0);
      stall         : out std_logic );
end component;

-------------------------------------------------------------------
-- IF stage signals
-------------------------------------------------------------------
signal sig_next_pc              : std_logic_vector(3 downto 0);
signal sig_curr_pc              : std_logic_vector(3 downto 0);
signal sig_one_4b               : std_logic_vector(3 downto 0);
signal sig_pc_carry_out         : std_logic;
signal sig_fetched_insn         : std_logic_vector(15 downto 0);

-- BNE (Lab03 T1)
signal sig_new_pc    : std_logic_vector(3 downto 0); 

-- IF/ID register outputs (Lab03 T2)
signal sig_ifid_pc   : std_logic_vector(3 downto 0);
signal sig_ifid_insn : std_logic_vector(15 downto 0);

-- Smth to Forward to ID
signal id_forward_rs, id_forward_rt : std_logic_vector(1 downto 0);
signal id_bne_rs, id_bne_rt : std_logic_vector(15 downto 0);

-------------------------------------------------------------------
-- ID stage signals
-------------------------------------------------------------------
signal id_reg_dst, id_reg_write, id_alu_src, id_mem_write, id_mem_to_reg : std_logic;
signal id_write_register       : std_logic_vector(3 downto 0);
signal id_read_data_a          : std_logic_vector(15 downto 0);
signal id_read_data_b          : std_logic_vector(15 downto 0);
signal id_sign_extended_offset : std_logic_vector(15 downto 0); 

-- Lab02 & Lab03 Enables
signal id_out_ea, id_in_ea, id_sadd_ea, id_bne_ea, id_dis_ea : std_logic;

-- Lab03 BNE
signal id_pc_plus1     : std_logic_vector(3 downto 0);
signal id_branch_taken : std_logic;
signal id_branch_target : std_logic_vector(3 downto 0);
signal id_branch_carry : std_logic;

-- Flushing
signal id_flush         : std_logic; -- bubble the instruction currently in IF

-- Lab03 Dispatch
signal sig_cop1 : std_logic_vector(15 downto 0);
signal sig_cop2 : std_logic_vector(15 downto 0);
signal sig_flag : std_logic;
signal sig_dis_led : std_logic_vector(15 downto 0);
signal sig_final_led : std_logic_vector(15 downto 0);

-- ID/EX register outputs
signal ex_rs_data, ex_rt_data, ex_imm : std_logic_vector(15 downto 0);
signal ex_opcode : std_logic_vector(3 downto 0);
signal ex_write_register : std_logic_vector(3 downto 0);
signal ex_reg_write, ex_alu_src, ex_mem_write, ex_mem_to_reg : std_logic;
signal ex_in_enable, ex_out_enable, ex_sadd_enable, ex_dis_enable : std_logic;

-- Smth for Forwarding to EX
signal ex_rs_reg, ex_rt_reg : std_logic_vector(3 downto 0);

-------------------------------------------------------------------
-- EX stage signals
-------------------------------------------------------------------
signal ex_alu_src_b            : std_logic_vector(15 downto 0);
signal ex_alu_result           : std_logic_vector(15 downto 0); 
signal ex_alu_carry_out        : std_logic;

-- Lab02 Saturated Sum
signal ex_saturated_sum  : std_logic_vector(15 downto 0);
signal ex_final_alu      : std_logic_vector(15 downto 0);

-- EX/Register Output Signals
signal mem_result       : std_logic_vector(15 downto 0);
signal mem_store_data   : std_logic_vector(15 downto 0);
signal mem_write_reg    : std_logic_vector(3 downto 0);
signal mem_reg_write, mem_mem_write, mem_mem_to_reg : std_logic;
signal mem_in_enable, mem_out_enable : std_logic;
-------------------------------------------------------------------
-- MEM stage signals
-------------------------------------------------------------------
signal mem_data_mem_out         : std_logic_vector(15 downto 0);
signal mem_led_out      : std_logic_vector(15 downto 0);

-- MEM/WB Output Signals
signal wb_result        : std_logic_vector(15 downto 0);
signal wb_mem_data      : std_logic_vector(15 downto 0);
signal wb_mem_to_reg    : std_logic;
signal wb_in_enable     : std_logic;
signal wb_reg_write     : std_logic;
signal wb_out_led       : std_logic_vector(15 downto 0);
signal wb_write_reg     : std_logic_vector(3 downto 0);
signal wb_out_enable    : std_logic;

-------------------------------------------------------------------
-- WB stage signals
-------------------------------------------------------------------
signal wb_write_data           : std_logic_vector(15 downto 0);
signal wb_norm_data_write      : std_logic_vector(15 downto 0);

-------------------------------------------------------------------
-- Clock and Reset
-------------------------------------------------------------------
SIGNAL btnLs, btnCs : STD_LOGIC;
signal slow_clk : std_logic;

-------------------------------------------------------------------
-- Hazard + Forwarding
-------------------------------------------------------------------
signal hazard_stall : std_logic;
signal id_ex_bubble : std_logic;
signal forward_a, forward_b : std_logic_vector(1 downto 0);
signal fwd_rs_data, fwd_rt_data : std_logic_vector(15 downto 0);


-- Use clk => clk for simulated clock (ns)
-- Use clk => slow clk for 100 MHz Clock
-- Use clk => btnLs for button based clock
-- btnC for reset
-- 7 Segment Display is faster by 1-2 instruction (Since insn_mem(0) requires btn press and it starts at 0)
begin

    sig_one_4b <= "0001";
    -------------------------------------------------------------------
    -- STAGE 1: IF
    -------------------------------------------------------------------
    pc : program_counter
    port map ( reset    => reset,
               clk      => clk,
               stall    => hazard_stall,
               addr_in  => sig_new_pc, -- Changed from sig_next_pc
               addr_out => sig_curr_pc ); 

    next_pc : adder_4b 
    port map ( src_a     => sig_curr_pc, 
               src_b     => sig_one_4b,
               sum       => sig_next_pc,   
               carry_out => sig_pc_carry_out );
    
    insn_mem : instruction_memory 
    port map ( reset    => reset,
               clk      => clk,
               addr_in  => sig_curr_pc,
               insn_out => sig_fetched_insn );

     if_id : if_id_reg
     port map( clk      => clk,
               reset    => reset,
               flush    => id_flush,
               stall    => hazard_stall,
               pc_in    => sig_curr_pc,
               insn_in  => sig_fetched_insn,
               pc_out   => sig_ifid_pc,
               insn_out => sig_ifid_insn );

    -------------------------------------------------------------------
    -- STAGE 2: ID
    -------------------------------------------------------------------
    ctrl_unit : control_unit 
    port map ( opcode     => sig_ifid_insn(15 downto 12),
               reg_dst    => id_reg_dst,
               reg_write  => id_reg_write,
               alu_src    => id_alu_src,
               mem_write  => id_mem_write,
               mem_to_reg => id_mem_to_reg,
               in_enable => id_in_ea,
               out_enable => id_out_ea,
               sadd_enable => id_sadd_ea,
               bne_enable => id_bne_ea,
               dis_enable => id_dis_ea );
       
    sign_extend : sign_extend_4to16 
    port map ( data_in  => sig_ifid_insn(3 downto 0),
               data_out => id_sign_extended_offset );
               
    mux_reg_dst : mux_2to1_4b 
    port map ( mux_select => id_reg_dst,
               data_a     => sig_ifid_insn(7 downto 4),
               data_b     => sig_ifid_insn(3 downto 0),
               data_out   => id_write_register );

    reg_file : register_file 
    port map ( reset           => reset, 
               clk             => clk,
               read_register_a => sig_ifid_insn(11 downto 8),
               read_register_b => sig_ifid_insn(7 downto 4),
               write_enable    => wb_reg_write, -- MEM
               write_register  => wb_write_reg, -- MEM
               write_data      => wb_norm_data_write,  -- WB
               read_data_a     => id_read_data_a,
               read_data_b     => id_read_data_b );
         
    -- New FWD unit for 4 inputs? (Copy Forwarding, add new condition)   
    id_fwd_rs : forwarding_unit
    port map ( ex_reg        => sig_ifid_insn(11 downto 8),
               mem_write_reg => ex_write_register,           
               wb_write_reg  => mem_write_reg,               
               mem_reg_write => ex_reg_write,
               wb_reg_write  => mem_reg_write,
               result        => id_forward_rs );
    
    id_fwd_rt : forwarding_unit
    port map ( ex_reg        => sig_ifid_insn(7 downto 4),   
               mem_write_reg => ex_write_register,
               wb_write_reg  => mem_write_reg,
               mem_reg_write => ex_reg_write,
               wb_reg_write  => mem_reg_write,
               result        => id_forward_rt );
               
    fwd_mux_rs_id : mux_3to1_16b
    port map ( mux_select => id_forward_rs,
               data_00    => id_read_data_a,
               data_01    => mem_result,   
               data_10    => ex_final_alu,          
               data_out   => id_bne_rs  );
               
    fwd_mux_rt_id : mux_3to1_16b
    port map ( mux_select => id_forward_rt,
               data_00    => id_read_data_b,
               data_01    => mem_result,  
               data_10    => ex_final_alu,           
               data_out   => id_bne_rt  );

    bne : bne_unit
    port map( enable        => id_bne_ea,
              rs            => id_bne_rs,
              rt            => id_bne_rt,
              branch_taken  => id_branch_taken );
             
    id_pc_adder : adder_4b
    port map( src_a     => sig_ifid_pc,
              src_b     => sig_one_4b,
              sum       => id_pc_plus1,
              carry_out => open );
    
    branch_adder : adder_4b
    port map( src_a     => id_pc_plus1,
              src_b     => sig_ifid_insn(3 downto 0),  -- immediate
              sum       => id_branch_target,
              carry_out => id_branch_carry );
             
    branch_mux : mux_2to1_4b
    port map ( mux_select => id_branch_taken,
               data_a => sig_next_pc,
               data_b => id_branch_target,
               data_out => sig_new_pc );
         
   -- Flusher here 
   id_flush <= id_branch_taken;
   
   -- Forwarding to Stall 
   id_ex_bubble <= id_flush OR hazard_stall;
   
   -- Detects for EX only??? i.e need new detector unit for ID?
   hazard_det : hazard_detector
   port map( ex_mem_to_reg => ex_mem_to_reg,
             ex_write_reg  => ex_write_register,
             id_rs         => sig_ifid_insn(11 downto 8),
             id_rt         => sig_ifid_insn(7 downto 4),
             stall         => hazard_stall);
                   
    id_ex : id_ex_reg
    port map( clk    => clk,
              reset  => reset,
              flush  => id_ex_bubble,
              rs_data_in   => id_read_data_a,
              rt_data_in   => id_read_data_b,
              imm_in       => id_sign_extended_offset,
              opcode_in    => sig_ifid_insn(15 downto 12),
              write_reg_in => id_write_register,
              reg_write_in   => id_reg_write,
              alu_src_in     => id_alu_src,
              mem_write_in   => id_mem_write,
              mem_to_reg_in  => id_mem_to_reg,
              in_enable_in   => id_in_ea,
              out_enable_in  => id_out_ea,
              sadd_enable_in => id_sadd_ea,
              dis_enable_in  => id_dis_ea,
              rs_data_out   => ex_rs_data,
              rt_data_out   => ex_rt_data,
              imm_out       => ex_imm,
              opcode_out    => ex_opcode,
              write_reg_out => ex_write_register,
              reg_write_out   => ex_reg_write,
              alu_src_out     => ex_alu_src,
              mem_write_out   => ex_mem_write,
              mem_to_reg_out  => ex_mem_to_reg,
              in_enable_out   => ex_in_enable,
              out_enable_out  => ex_out_enable,
              sadd_enable_out => ex_sadd_enable,
              dis_enable_out  => ex_dis_enable,
              
              rs_reg_in => sig_ifid_insn(11 downto 8),
              rs_reg_out   => ex_rs_reg,
              rt_reg_in  => sig_ifid_insn(7 downto 4),
              rt_reg_out    => ex_rt_reg);       
    -------------------------------------------------------------------
    -- STAGE 3: EX
    -------------------------------------------------------------------
    ex_fwd_rs : forwarding_unit
    port map ( ex_reg        => ex_rs_reg,
               mem_write_reg => mem_write_reg,
               wb_write_reg  => wb_write_reg,
               mem_reg_write => mem_reg_write,
               wb_reg_write  => wb_reg_write,
               result        => forward_a );
               
    ex_fwd_rt : forwarding_unit
    port map ( ex_reg        => ex_rt_reg,
               mem_write_reg => mem_write_reg,
               wb_write_reg  => wb_write_reg,
               mem_reg_write => mem_reg_write,
               wb_reg_write  => wb_reg_write,
               result        => forward_b );   
    
    fwd_mux_rs_ex : mux_3to1_16b
    port map ( mux_select => forward_a,
               data_00    => ex_rs_data,
               data_01    => wb_norm_data_write,   -- MEM/WB (being written this cycle)
               data_10    => mem_result,           -- EX/MEM
               data_out   => fwd_rs_data );
               
    fwd_mux_rt_ex : mux_3to1_16b
    port map ( mux_select => forward_b,
               data_00    => ex_rt_data,
               data_01    => wb_norm_data_write,   -- MEM/WB (being written this cycle)
               data_10    => mem_result,           -- EX/MEM
               data_out   => fwd_rt_data );
    
    mux_alu_src : mux_2to1_16b 
    port map ( mux_select => ex_alu_src,
               data_a     => fwd_rt_data,       -- Forwarded from ex_rt_data
               data_b     => ex_imm,
               data_out   => ex_alu_src_b );
    
    alu : adder_16b 
    port map ( src_a     => fwd_rs_data,        -- Forwaded from ex_rs_data
               src_b     => ex_alu_src_b,
               sum       => ex_alu_result,
               carry_out => ex_alu_carry_out );
         
    sat : saturator
    port map( sum    => ex_alu_result,
              carry  => ex_alu_carry_out,
              result => ex_saturated_sum );
              
    mux_sadd : mux_2to1_16b
    port map ( mux_select => ex_sadd_enable,
               data_a     => ex_alu_result,
               data_b     => ex_saturated_sum,
               data_out   => ex_final_alu );
    
    dispatcher : dispatch
    port map ( clk => clk,
               reset => reset,
               enable => ex_dis_enable,
               rs_data => fwd_rs_data,
               rt_data => fwd_rt_data,
               immediate => ex_imm,
               cop1 => sig_cop1,
               cop2 => sig_cop2,
               flag => sig_flag,
               led_data => sig_dis_led );
               
   -- MUX to choose between DIS and Nothing
   null_dis_mux : mux_2to1_16b
   port map( mux_select => sig_flag,
             data_a     => (others => '0'),
             data_b     => sig_dis_led,
             data_out   => sig_final_led );
             
    -- EX MEM Register Here   
    ex_mem : ex_mem_reg
    port map( clk   => clk,
              reset => reset,
              result_in     => ex_final_alu,
              store_data_in => fwd_rt_data,
              write_reg_in  => ex_write_register,
              reg_write_in  => ex_reg_write,
              mem_write_in  => ex_mem_write,
              mem_to_reg_in => ex_mem_to_reg,
              in_enable_in  => ex_in_enable,
              out_enable_in => ex_out_enable,
              result_out     => mem_result,
              store_data_out => mem_store_data,
              write_reg_out  => mem_write_reg,
              reg_write_out  => mem_reg_write,
              mem_write_out  => mem_mem_write,
              mem_to_reg_out => mem_mem_to_reg,
              in_enable_out  => mem_in_enable,
              out_enable_out => mem_out_enable ); 
    -------------------------------------------------------------------
    -- STAGE 4: MEM
    -------------------------------------------------------------------
    data_mem : data_memory 
    port map ( reset        => reset,
               clk          => clk,
               write_enable => mem_mem_write,
               write_data   => mem_store_data,
               addr_in      => mem_result(3 downto 0), -- Change from sig_alu_result
               data_out     => mem_data_mem_out );
    
    out_unit : led_displays
    port map ( clk     => clk,
               reset   => reset,
               enable  => mem_out_enable,
               data_in => mem_store_data,
               led_out => wb_out_led );
   
    mem_wb : mem_wb_reg
    port map(
        clk => clk,
        reset => reset,
        result_in => mem_result,
        mem_data_in => mem_data_mem_out,
        write_reg_in => mem_write_reg,
        reg_write_in => mem_reg_write,
        mem_to_reg_in => mem_mem_to_reg,
        in_enable_in => mem_in_enable,
        out_enable_in => mem_out_enable,
        result_out => wb_result,
        mem_data_out => wb_mem_data,
        write_reg_out => wb_write_reg,
        reg_write_out => wb_reg_write,
        mem_to_reg_out => wb_mem_to_reg,
        in_enable_out => wb_in_enable,
        out_enable_out => wb_out_enable );  
                  
    -------------------------------------------------------------------
    -- STAGE 5: WB
    -------------------------------------------------------------------
    mux_mem_to_reg : mux_2to1_16b 
    port map ( mux_select => wb_mem_to_reg,
               data_a     => wb_result, -- Change from sig_alu_result
               data_b     => wb_mem_data,
               data_out   => wb_write_data );
    
    mux_in : mux_2to1_16b
    port map ( mux_select => wb_in_enable,
               data_a     => wb_write_data,
               data_b     => sw,
               data_out   => wb_norm_data_write  );
               
    null_led_mux : mux_2to1_16b
    port map( mux_select => wb_out_enable, -- Change
              data_a     => sig_final_led,
              data_b     => wb_out_led,
              data_out   => led );
    -------------------------------------------------------------------
    -- Peripherals (unchanged)
    -------------------------------------------------------------------
    dbg : display port map( clk => clk, value => sig_curr_pc, seg => seg, an => an, dp => dp );
    db0 : debounce PORT MAP (clk => clk, noisy_sig => btnL, clean_sig => btnLs);
    db1 : debounce PORT MAP (clk => clk, noisy_sig => btnC, clean_sig => btnCs);
    clkdiv : clock_divider port map( clk => clk, slow_clk => slow_clk );
end structural;
