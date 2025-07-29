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

    signal go_from_handshake    : std_logic;
    signal fifo_update_count_go   : std_logic;
    signal rst_fifo             : std_logic;
    signal counter_done         : std_logic;
    signal fifo_empty           : std_logic;
    signal fifo_prog_full       : std_logic;
    signal rst_from_counter       : std_logic;
    signal size_from_reg        : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
    signal data_in_flipped      : std_logic_vector (C_DRAM0_DATA_WIDTH-1 downto 0);

begin


    done <= counter_done;
    valid <= not fifo_empty;
    fifo_update_count_go <= (rd_en and (not fifo_empty));
    data_in_flipped <= dram_rd_data(15 downto 0) & dram_rd_data(31 downto 16); --may need to unflip
    
    U_ADDR_GEN : entity work.dram_addr_gen
        port map 
        (
            clk                     => dram_clk,
            rst                     => dram_rst,
            stall                   => fifo_prog_full,      -- Connected to prog_full from FIFO
            dram_ready              => dram_ready,
            go                      => go_from_handshake,   -- go connected directly to handshake
            size_input              => size_from_reg,                -- Goes through handshake but is directly connected to input signal
            start_addr              => start_addr,           -- Goes through handshake but is directly connected to input signal

            valid_output            => dram_rd_en,
            done_output             => open, --just lets you know the addr_gen is done
            output_addr             => dram_rd_addr
        );

    U_HANDSHAKE : entity work.handshake_1
        port map
        (
            clk_src     => user_clk,
            clk_dest    => dram_clk,
            rst         => user_rst,
            go          => go,
            delay_ack   => '0', --not sure what to do with this input

            rcv         => go_from_handshake,
            ack         => open --maybe make ack the new go signal for addr_gen?
        );

    U_SIZE_REG : entity work.size_reg 
        port map --Might mess up the timing of the addr_gen where it gets the wrong value for the size?
        (
            clk     => user_clk,
            rst     => user_rst,
            ld      => go,
            input   => size,

            output  => size_from_reg
        );
    
    U_DRAM_COUNTER : entity work.dram_counter
        port map
        (
            clk             => user_clk,
            rst             => user_rst,
            update_count    => fifo_update_count_go, --takes valid read en from fifo
            go              => go,
            size_input      => size_from_reg,

            send_rst_output => rst_from_counter,
            done_output     => counter_done
        );

    U_DUAL_FLOP : entity work.dual_flop_reset
        port map 
        (
            clk_src       => user_clk,
            clk_dest       => dram_clk,
            rst         => user_rst,
            input       => counter_done, -- rst_from_counter,
            output      => rst_fifo --TO FIFO RST
        );

 fifo:entity work.FIFO
    port map(
        clk_src =>dram_clk,
        clk_dest =>user_clk,
        rst      =>rst_fifo,
        empty    =>fifo_empty,-----------logic
        full     =>open,
        rd       =>fifo_update_count_go,-----------need logic
        wr       =>dram_rd_valid,
        data_in  =>data_in_flipped,
        prog_full =>fifo_prog_full,
        data_out =>data
    );

end default;
 

