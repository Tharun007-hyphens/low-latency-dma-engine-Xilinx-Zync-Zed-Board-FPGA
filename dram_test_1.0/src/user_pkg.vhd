-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;

package user_pkg is

    constant C_RAM0_ADDR_WIDTH  : positive := 15;
    constant C_RAM0_RD_DATA_WIDTH  : positive := 16;
    constant C_RAM0_WR_DATA_WIDTH  : positive := 32;
    -- adjust for ratio of data width and ram width
    constant C_RAM0_RD_SIZE_WIDTH  : positive := C_DRAM0_ADDR_WIDTH+1+1;
    constant C_RAM0_WR_SIZE_WIDTH  : positive := C_DRAM0_ADDR_WIDTH+1;
    constant C_RAM1_ADDR_WIDTH : positive := 15;
    constant C_RAM1_RD_DATA_WIDTH : positive := 32;
    constant C_RAM1_WR_DATA_WIDTH : positive := 16;
    -- adjust for ratio of data width and ram width
    constant C_RAM1_RD_SIZE_WIDTH  : positive := C_DRAM1_ADDR_WIDTH+1;
    constant C_RAM1_WR_SIZE_WIDTH  : positive := C_DRAM1_ADDR_WIDTH+1+1;

    subtype RAM0_ADDR_RANGE is natural range C_RAM0_ADDR_WIDTH-1 downto 0;
    subtype RAM0_RD_DATA_RANGE is natural range C_RAM0_RD_DATA_WIDTH-1 downto 0;
    subtype RAM0_WR_DATA_RANGE is natural range C_RAM0_WR_DATA_WIDTH-1 downto 0;
    subtype RAM0_RD_SIZE_RANGE is natural range C_RAM0_RD_SIZE_WIDTH-1 downto 0;
    subtype RAM0_WR_SIZE_RANGE is natural range C_RAM0_WR_SIZE_WIDTH-1 downto 0;
    subtype RAM1_ADDR_RANGE is natural range C_RAM1_ADDR_WIDTH-1 downto 0;
    subtype RAM1_RD_DATA_RANGE is natural range C_RAM1_RD_DATA_WIDTH-1 downto 0;
    subtype RAM1_WR_DATA_RANGE is natural range C_RAM1_WR_DATA_WIDTH-1 downto 0;
    subtype RAM1_RD_SIZE_RANGE is natural range C_RAM1_RD_SIZE_WIDTH-1 downto 0;
    subtype RAM1_WR_SIZE_RANGE is natural range C_RAM1_WR_SIZE_WIDTH-1 downto 0;

    constant C_GO_ADDR   : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(1, C_MMAP_ADDR_WIDTH));
    constant C_RAM0_RD_ADDR_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(2, C_MMAP_ADDR_WIDTH));
    constant C_RAM1_WR_ADDR_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(3, C_MMAP_ADDR_WIDTH));
    constant C_SIZE_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(4, C_MMAP_ADDR_WIDTH));
    constant C_DONE_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(5, C_MMAP_ADDR_WIDTH));

    constant C_DMA_RD_COUNT_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(6, C_MMAP_ADDR_WIDTH));
    constant C_DMA_RD_START_ADDR_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(7, C_MMAP_ADDR_WIDTH));
    constant C_DMA_RD_ADDR_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(8, C_MMAP_ADDR_WIDTH));
    constant C_DMA_RD_SIZE_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(9, C_MMAP_ADDR_WIDTH));

    constant C_DMA_RD_PROG_FULL_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(10, C_MMAP_ADDR_WIDTH));
    constant C_DMA_RD_EMPTY_ADDR : std_logic_vector(MMAP_ADDR_RANGE) :=  std_logic_vector(to_unsigned(11, C_MMAP_ADDR_WIDTH));
	
	type window is array(integer range<>) of std_logic_vector(15 downto 0);
    
    constant C_1 : std_logic := '1';
    constant C_0 : std_logic := '0';

end user_pkg;
