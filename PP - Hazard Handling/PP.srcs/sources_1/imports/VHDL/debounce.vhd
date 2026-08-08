----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2026 20:38:48
-- Design Name: 
-- Module Name: debounce - Behavioral
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
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY Debounce IS
    PORT( clk : IN std_logic;
          noisy_sig : IN std_logic;
          clean_sig : OUT std_logic);
END Debounce;

ARCHITECTURE behavioural OF Debounce is
    SIGNAL input_prev : std_logic;
    SIGNAL synch_count : std_logic_vector(20 DOWNTO 0);
BEGIN
    synchronize: PROCESS
    BEGIN
        WAIT UNTIL clk'event AND clk = '1';
        input_prev <= noisy_sig;
        IF noisy_sig /= input_prev THEN
            synch_count <= (others => '0');
        ELSIF synch_count /= x"100000" THEN
            synch_count <= synch_count + 1;
        END IF;
        IF synch_count = x"100000" THEN
            clean_sig <= noisy_sig;
        END IF;
    END PROCESS;
END behavioural;
