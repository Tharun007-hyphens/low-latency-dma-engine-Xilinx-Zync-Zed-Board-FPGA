----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2023 07:07:17 PM
-- Design Name: 
-- Module Name: dual_flop_reset - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.config_pkg.all;
use work.user_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dual_flop_reset is
    port 
    (
        clk_src       : in  std_logic;
        clk_dest       : in  std_logic;
        rst         : in  std_logic;
        input       : in  std_logic;
        output      : out std_logic
    );
end dual_flop_reset;

architecture Behavioral of dual_flop_reset is
    signal pulse1,pulse2,pulse3: std_logic;
begin

-- Synchronizer in the source clock domain (clk_src)
process(clk_src, rst)
begin
    if rst = '1' then
        pulse1 <= '0';
    elsif rising_edge(clk_src) then
        pulse1 <= input; -- Capture the pulse in source clock domain
    end if;
end process;

-- Synchronizer in the destination clock domain (clk_dest)
process(clk_dest, rst)
begin
    if rst = '1' then
        pulse2 <= '0';
        pulse3 <= '0';
    elsif rising_edge(clk_dest) then
        pulse2 <= pulse1; -- First stage of synchronization
        pulse3 <= pulse2; -- Second stage of synchronization
    end if;
end process;
output<=pulse3;

end Behavioral;
