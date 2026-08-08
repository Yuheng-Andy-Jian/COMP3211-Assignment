
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pipeline_TB_VHDL is
end pipeline_TB_VHDL;


architecture behave of pipeline_TB_VHDL is
 
  -- 1 GHz = 2 nanoseconds period
  constant c_CLOCK_PERIOD : time := 2 ns; 


 signal r_CLOCK     : std_logic := '0';
 signal r_reset    : std_logic := '0';
 
 signal r_sw   : std_logic_vector(15 downto 0) := (others => '0');
 signal r_btnC : std_logic := '0';
 signal r_btnL : std_logic := '0';

 signal w_led : std_logic_vector(15 downto 0);
 signal w_seg : std_logic_vector(0 to 6);
 signal w_an  : std_logic_vector(3 downto 0);
 signal w_dp  : std_logic;
 

-- Component declaration for the Unit Under Test (UUT)
component pipeline_core is
    port (     
        reset : in std_logic;    
        clk  : in std_logic;
        sw   : in std_logic_vector(15 downto 0);
        led  : out std_logic_vector(15 downto 0);
        btnC : in std_logic;
        btnL : in std_logic;
        seg  : out std_logic_vector(0 to 6);
        an   : out std_logic_vector(3 downto 0);
        dp   : out std_logic
       );
      end component ;
      
      
      begin
       
        -- Instantiate the Unit Under Test (UUT)
        UUT : pipeline_core
          port map (
                reset => r_reset,
                clk   => r_CLOCK,
                sw    => r_sw,
                led   => w_led,
                btnC  => r_btnC,
                btnL  => r_btnL,
                seg   => w_seg,
                an    => w_an,
                dp    => w_dp
                        
            );
       
        p_CLK_GEN : process is
        begin
          wait for c_CLOCK_PERIOD/2;
          r_CLOCK <= not r_CLOCK;
        end process p_CLK_GEN; 
         
        process                               -- main testing
        begin
          r_reset <= '0';
       
             wait for 2*c_CLOCK_PERIOD ;
        r_reset <= '1';
           
           wait for 2*c_CLOCK_PERIOD ;
                r_reset <= '0';         
          
          wait for 2 sec;
           
        end process;
         
      end behave;
      
      
      
      
      
      
      