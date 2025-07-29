----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/08/2023 11:05:06 PM
-- Design Name: 
-- Module Name: size_reg - Behavioral
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
use ieee.numeric_std.all;
use work.config_pkg.all;

entity size_reg is
    port
    (
        clk     : in std_logic;
        rst     : in std_logic;
        ld      : in std_logic;
        input   : in std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
        output  : out std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0)
    );
end entity size_reg;

architecture BHV of size_reg is
begin

    process(clk,rst)
    begin
        
        if(rst = '1')then
        
            output <= (others=>'0');
        
        elsif(rising_edge(clk))then
        
            if(ld = '1')then
        
                output <= input;
        
            end if;
        
        end if;
    
    end process;

end BHV;