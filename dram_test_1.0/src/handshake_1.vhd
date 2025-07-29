-- Entity: handshake
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.config_pkg.all;
use work.user_pkg.all;


entity handshake_1 is
    port (
        clk_src   : in  std_logic;
        clk_dest  : in  std_logic;
        rst       : in  std_logic;
        go        : in  std_logic;
        delay_ack : in  std_logic;
        rcv       : out std_logic;
        ack       : out std_logic
        );
end handshake_1;

architecture TRANSITIONAL of handshake_1 is

    type state_type is (S_READY, S_WAIT_FOR_ACK, S_RESET_ACK);
    type state_type2 is (S_READY, S_SEND_ACK, S_RESET_ACK);
    signal state_src  : state_type;
    signal state_dest : state_type2;

    signal send_src_r : std_logic;
    signal start_address_src :std_logic_vector(RAM0_ADDR_RANGE);
    signal size_src       : std_logic_vector(RAM0_RD_SIZE_RANGE);
    signal ack_dest_r : std_logic;
    signal ack_start_address_src :std_logic;
    signal ack_size_src       : std_logic;
    signal dest1,dest2,src1,src2 : std_logic;
begin

    -----------------------------------------------------------------------------
    -- State machine in source domain that sends to dest domain and then waits
    -- for an ack
-------------------------------------------------------------------------------------
    process(clk_src, rst)
    begin
        if (rst = '1') then
            state_src  <= S_READY;
            send_src_r <= '0';
            ack        <= '0';
            src1<='0';
            src2<='0';
        elsif (rising_edge(clk_src)) then
            src1<=ack_dest_r;
            src2<=src1;

            ack <= '0';

            case state_src is
                when S_READY =>
                    if (go = '1') then
                        send_src_r <= '1';
                        state_src  <= S_WAIT_FOR_ACK;
                    end if;

                when S_WAIT_FOR_ACK =>
                    if (src2 = '1') then
                        send_src_r <= '0';
                        state_src  <= S_RESET_ACK;
                    end if;

                when S_RESET_ACK =>
                    if (src2 = '0') then
                        ack       <= '1';
                        state_src <= S_READY;
                    end if;

                when others => null;
            end case;
        end if;
    end process;
-----------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------
    -- State machine in dest domain that waits for source domain to send signal,
    -- which then gets acknowledged

    process(clk_dest, rst)
    begin
        if (rst = '1') then
            state_dest <= S_READY;
            ack_dest_r <= '0';
            rcv        <= '0';
            dest1   <='0';
            dest2   <='0';
        elsif (rising_edge(clk_dest)) then
            dest1<=send_src_r;
            dest2<=dest1;
            

            rcv <= '0';

            case state_dest is
                when S_READY =>
                    -- if source is sending data, assert rcv (received)
                    if (dest2 = '1') then
                        rcv        <= '1';
                        state_dest <= S_SEND_ACK;
                    end if;

                when S_SEND_ACK =>
                    -- send ack unless it is delayed
                    if (delay_ack = '0') then
                        ack_dest_r <= '1';
                        state_dest <= S_RESET_ACK;
                    end if;

                when S_RESET_ACK =>
                    -- send ack unless it is delayed
                    if (dest2 = '0') then
                        ack_dest_r <= '0';
                        state_dest <= S_READY;
                    end if;

                when others => null;
            end case;
        end if;
    end process;

end TRANSITIONAL;