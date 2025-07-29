library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity dram_addr_gen is
    port (

        clk                     : in  std_logic;
        rst                     : in  std_logic;
        go                      : in  std_logic;
        stall                   : in  std_logic;
        dram_ready              : in  std_logic;
        size_input              : in  std_logic_vector (C_DRAM0_SIZE_WIDTH downto 0);
        start_addr              : in  std_logic_vector (C_DRAM0_ADDR_WIDTH-1 downto 0);

        valid_output            : out std_logic;
        done_output             : out std_logic;
        output_addr             : out std_logic_vector (C_DRAM0_ADDR_WIDTH-1 downto 0)
        );
end dram_addr_gen;

architecture default_arch of dram_addr_gen is   

    type state_t is (reset, start, addr_gen, checking, dram_check, S_done);
    signal state_r, next_state      : state_t;
    signal send_addr_r, send_addr   : std_logic_vector(C_DRAM0_ADDR_WIDTH downto 0); 
    signal size_r, size       : std_logic_vector (C_DRAM0_SIZE_WIDTH downto 0);
    signal done_r, done, valid, valid_r : std_logic;

begin

    valid_output<=  valid_r;
    done_output <=  done_r;
    output_addr <=  send_addr_r(C_DRAM0_ADDR_WIDTH-1 downto 0);


    --CLK Process
    process(clk,rst)
    begin
        if(rst = '1') then
    
            state_r         <= reset;
            send_addr_r     <= (others=>'0');
            done_r          <= '0';
            valid_r         <= '0';
            size_r          <= (others=>'0');

        elsif (rising_edge(clk)) then

            state_r         <= next_state;
            send_addr_r     <= send_addr;
            done_r          <= done;
            valid_r         <= valid;
            size_r          <= size;
            
        end if;
    end process;

    --State Process
    process(go, stall, dram_ready, size_r, start_addr, size_input, state_r, send_addr_r, done_r,valid_r)
    begin

        next_state  <= state_r;
        send_addr   <= send_addr_r;
        done        <= done_r;
        valid       <= '0';
        size        <= size_r;

        case state_r is 

            when reset => 
        
                next_state <= start;

            when start =>

                if(go = '1')then
                    send_addr <= '0' & start_addr; 
                    size <= size_input;
                    next_state <= checking;
                end if;

            when checking =>
            
                if(stall = '0' and  dram_ready = '1' )then 
                    if(unsigned(send_addr_r) <= (unsigned(start_addr) + ((unsigned(size_r)/2)+(unsigned(size_r) mod 2)) - 1))then

                        valid     <= '1'; 
                        next_state <= addr_gen;
                    
                    else
                        next_state <= S_done;
                    end if;
                end if;

            when addr_gen =>

                if(dram_ready = '1' )then 
                    send_addr <= std_logic_vector(unsigned(send_addr_r) + to_unsigned(1,C_DRAM0_ADDR_WIDTH-1));
                    next_state <= checking;
                else
                    next_state <= dram_check;
                end if;

            when dram_check =>

                if(dram_ready = '1' )then
                    valid     <= '1'; 
                    next_state <= addr_gen;
                end if; 

            when S_done=>

                done    <= '1';
                if(go = '1')then
                    done    <= '0';
                    send_addr <= '0' & start_addr; 
                    size <= size_input;
                    next_state <= checking;
                end if;

            when others => null;

        end case;
    end process;
end default_arch;