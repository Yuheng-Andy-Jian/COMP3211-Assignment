----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.07.2026 22:50:28
-- Design Name: 
-- Module Name: led_displays - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity led_displays is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        enable    : in  std_logic;
        data_in   : in  std_logic_vector(15 downto 0);
        led_out   : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavioral of led_displays is
    signal reg : std_logic_vector(15 downto 0);
begin

process(clk)
begin
    if reset = '1' then
        reg <= (others => '0');
    elsif (rising_edge(clk) AND enable = '1') then
        reg <= data_in;
    end if;
end process;

led_out <= reg;

end behavioral;
