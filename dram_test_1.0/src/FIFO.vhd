----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/23/2023 11:41:13 PM
-- Design Name: 
-- Module Name: FIFO - Behavioral
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

entity FIFO is
    port(
        clk_src  : in  std_logic;
        clk_dest : in  std_logic;
        rst      : in  std_logic;
        empty    : out std_logic;
        full     : out std_logic;
        rd       : in  std_logic;
        wr       : in  std_logic;
        data_in  : in  std_logic_vector(31 downto 0);
        prog_full : out std_logic;
        data_out : out std_logic_vector(15 downto 0));
end FIFO;

architecture Behavioral of FIFO is
COMPONENT fifo_generator_0
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC 
  );
END COMPONENT;
begin
FIFO : fifo_generator_0
  PORT MAP (
    rst => rst,
    wr_clk => clk_src,
    rd_clk => clk_dest,
    din => data_in,
    wr_en => wr,
    rd_en => rd,
    dout => data_out,
    full => full,
    empty => empty,
    prog_full => prog_full,
    wr_rst_busy => open,
    rd_rst_busy => open
  );

end Behavioral;
