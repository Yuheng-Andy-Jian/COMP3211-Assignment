----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.07.2026 21:08:26
-- Design Name: 
-- Module Name: dispatch - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dispatch is
  Port ( clk : in std_logic;
         reset : in std_logic;
         enable : in std_logic;
         rs_data : in std_logic_vector(15 downto 0);
         rt_data : in std_logic_vector(15 downto 0);
         immediate : in std_logic_vector(15 downto 0);
         cop1 : out std_logic_vector(15 downto 0);
         cop2 : out std_logic_vector(15 downto 0);
         flag : out std_logic;
         led_data : out std_logic_vector(15 downto 0));
end dispatch;

architecture Behavioral of dispatch is
    signal regCOP1 : std_logic_vector(15 downto 0);
    signal regCOP2 : std_logic_vector(15 downto 0);
    signal regFLAG : std_logic;
begin

    process(clk, reset, enable)
    begin
        if reset = '1' then
            regCOP1 <= (others=>'0');
            regCOP2 <= (others=>'0');
            regFLAG <= '0';
        elsif (rising_edge(clk)) then
            if (enable = '1') then
                regCOP1 <= rs_data + immediate;
                regCOP2 <= rt_data;
                regFlag <= '1';
            else 
                regFlag <= '0';
            end if;
        end if;
    end process;
    
    cop1 <= regCOP1;
    cop2 <= regCOP2;
    flag <= regFlag;
    led_data <= "1000000000000000" when (regFlag = '1') else (others => '0');

end Behavioral;
