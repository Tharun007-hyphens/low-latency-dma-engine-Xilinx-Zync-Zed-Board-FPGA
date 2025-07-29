----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2023 11:57:33 PM
-- Design Name: 
-- Module Name: dram_rd_DMA - Behavioral
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

entity dram_rd_DMA is
    port (
            -- user dma control signals
            dram_clk             : in  std_logic;
            user_clk             : in  std_logic;
            dram_rst             : in  std_logic;
            user_rst             : in  std_logic;
            go                   : in  std_logic;
            rd_en                : in  std_logic;
            stall                : in  std_logic;
            start_addr           : in  std_logic_vector (C_DRAM0_ADDR_WIDTH-1 downto 0);
            size                 : in  std_logic_vector (C_DRAM0_SIZE_WIDTH downto 0);
            
            valid                : out std_logic;
            data                 : out std_logic_vector (15 downto 0);
            done                 : out std_logic;

            -- debugging signals
            debug_count          : out std_logic_vector (16 downto 0);
            debug_dma_size       : out std_logic_vector (15 downto 0);
            debug_dma_start_addr : out std_logic_vector (14 downto 0);
            debug_dma_addr       : out std_logic_vector (14 downto 0);
            debug_dma_prog_full  : out std_logic;
            debug_dma_empty      : out std_logic;
            
            -- dram control signals
            dram_ready           : in  std_logic;
            dram_rd_en           : out std_logic;
            dram_rd_addr         : out std_logic_vector (C_DRAM0_ADDR_WIDTH-1 downto 0); 
            dram_rd_data         : in  std_logic_vector (C_DRAM0_DATA_WIDTH-1 downto 0); 
            dram_rd_valid        : in  std_logic
    );
    
end entity dram_rd_DMA;

architecture default of dram_rd_DMA is

    signal g_rcv    : std_logic;
    signal fifo_go   : std_logic;
    signal reset_fifo             : std_logic;
    signal ctr_done         : std_logic;
    signal fifo_empty           : std_logic;
    signal fifo_pg_full       : std_logic;
    signal dummy       : std_logic;
    signal reg_sz        : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
    signal data_reverse      : std_logic_vector (C_DRAM0_DATA_WIDTH-1 downto 0);

begin


    done <= ctr_done;
    valid <= not fifo_empty;

    
    U_ADDR_GEN : entity work.dram_addr_gen
        port map 
        (
            clk                     => dram_clk,
            rst                     => dram_rst,
            stall                   => fifo_pg_full,     
            dram_ready              => dram_ready,
            go                      => g_rcv,   
            size_input              => reg_sz,              
            start_addr              => start_addr,           

            valid_output            => dram_rd_en,
            done_output             => open, 
            output_addr             => dram_rd_addr
        );
    U_HANDSHAKE : entity work.handshake_1
        port map
        (
            clk_src     => user_clk,
            clk_dest    => dram_clk,
            rst         => user_rst,
            go          => go,
            delay_ack   => '0', 

            rcv         => g_rcv,
            ack         => open 
        );

    U_SIZE_REG : entity work.size_reg 
        port map 
        (
            clk     => user_clk,
            rst     => user_rst,
            ld      => go,
            input   => size,

            output  => reg_sz
        );
		
	fifo_go <= (rd_en and (not fifo_empty));
    
    U_DRAM_COUNTER : entity work.counter
        port map
        (
            clk             => user_clk,
            rst             => user_rst,
            update_count    => fifo_go, 
            go              => go,
            size_input      => reg_sz,

            send_rst_output => dummy,
            done_output     => ctr_done
        );

    U_DUAL_FLOP : entity work.dual_flop_reset
        port map 
        (
            clk_src       => user_clk,
            clk_dest       => dram_clk,
            rst         => user_rst,
            input       => ctr_done, 
            output      => reset_fifo 
        );
		
		
    data_reverse <= dram_rd_data(15 downto 0) & dram_rd_data(31 downto 16);

    U_DRAM_RD_FIFO: entity work.FIFO
        port map (
            rst         => reset_fifo,
            clk_src      => dram_clk,
            clk_dest      => user_clk,
            data_in         => data_reverse, 
            wr       => dram_rd_valid, 
            rd       => fifo_go,

            data_out        => data,
            full        => open, 
            empty       => fifo_empty,
            prog_full   => fifo_pg_full
        );

end default;
