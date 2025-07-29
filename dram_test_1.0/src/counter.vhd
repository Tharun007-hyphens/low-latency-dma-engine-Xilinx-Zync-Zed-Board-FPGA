----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2023 06:37:16 PM
-- Design Name: 
-- Module Name: counter - Behavioral
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

entity counter is
    port
    (
        clk             : in std_logic;
        rst             : in std_logic;
        update_count    : in std_logic;
        go              : in std_logic;
        size_input      : in std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);

        send_rst_output : out std_logic;
        done_output     : out std_logic
    );
end entity counter;

architecture BHV of counter is

    type state_t is (RESET, COUNT_STATE, SEND_DONE);
    signal state_r, next_state : state_t;
    signal size_r, size : std_logic_vector (C_DRAM0_SIZE_WIDTH downto 0);
    signal count_r, count : std_logic_vector(C_DRAM0_SIZE_WIDTH downto 0);
    signal done_r, done : std_logic;
    signal send_rst_r, send_rst : std_logic;

begin

    done_output <=  done_r;
    send_rst_output <= send_rst_r;

    process(clk,rst)
    begin
        
        if(rst = '1')then

            state_r         <= RESET;
            done_r          <= '0';
            size_r          <= (others=>'0');
            count_r         <= (others=>'0');
            send_rst_r      <= '0';

        elsif(rising_edge(clk))then

            state_r         <= next_state;
            done_r          <= done;
            size_r          <= size_input;
            count_r         <= count;
            send_rst_r      <= send_rst;
        
        end if;
    
    end process;

    process(go, update_count, size_r, state_r, done_r,count_r)
    begin

        next_state  <= state_r;
        done        <= done_r;
        size        <= size_r;
        count       <= count_r;
        send_rst    <= '0';

        case state_r is 

            when RESET => 
        
                next_state <= COUNT_STATE;
            
            when COUNT_STATE =>

                if(unsigned(count_r) <= ((unsigned(size_r))-1))then 
                    
                    if(update_count = '1') then

                        count <= std_logic_vector((unsigned(count_r) + to_unsigned(1, C_DRAM0_SIZE_WIDTH)));

                    end if;

                else
                    send_rst   <= '1';
                    next_state <= SEND_DONE;
                    count<= (others=>'0');
                end if;

            when SEND_DONE=> 
                done    <= '1';
                send_rst   <= '0';
                if(go = '1')then
                    done    <= '0';
                    next_state <= RESET;
                end if;

            when others => null;

        end case;
    end process;

end BHV;
