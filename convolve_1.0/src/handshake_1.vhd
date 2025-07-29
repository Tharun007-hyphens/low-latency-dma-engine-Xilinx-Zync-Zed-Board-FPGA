library ieee;
use ieee.std_logic_1164.all;

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

-- TODO: The following implementation of the handshake_ent simulates perfectly, but
-- will not work on the FPGA. You must fix it.

architecture TRANSITIONAL of handshake_1 is

    type state_type is (S_READY, S_WAIT_FOR_ACK, S_RESET_ACK);
    type state_type2 is (S_READY, S_SEND_ACK, S_RESET_ACK);
    signal state_src  : state_type;
    signal state_dest : state_type2;

    signal send_src_r : std_logic;
    signal ack_dest_r : std_logic;

    --User Changes start

    signal ack_dest_r_2, ack_dest_r_3 : std_logic;
    signal send_src_r_2, send_src_r_3 : std_logic;

    --User Changes end

begin

    -----------------------------------------------------------------------------
    -- State machine in source domain that sends to dest domain and then waits
    -- for an ack

    process(clk_src, rst)
    begin
        if (rst = '1') then
            state_src  <= S_READY;
            send_src_r <= '0';
            ack_dest_r_2 <='0';
            ack_dest_r_3 <='0';
            ack        <= '0';
        elsif (rising_edge(clk_src)) then

            --User Changes start
            ack_dest_r_2 <= ack_dest_r;
            ack_dest_r_3 <= ack_dest_r_2;
            --User Changes end

            ack <= '0';

            case state_src is
                when S_READY =>
                    if (go = '1') then
                        send_src_r <= '1';
                        state_src  <= S_WAIT_FOR_ACK;
                    end if;

                when S_WAIT_FOR_ACK =>
                    if (ack_dest_r_3 = '1') then --Changed if 
                        send_src_r <= '0';
                        state_src  <= S_RESET_ACK;
                    end if;

                when S_RESET_ACK =>
                    if (ack_dest_r_3 = '0') then --Changed if 
                        ack       <= '1';
                        state_src <= S_READY;
                    end if;

                when others => null;
            end case;
        end if;
    end process;

    -----------------------------------------------------------------------------
    -- State machine in dest domain that waits for source domain to send signal,
    -- which then gets acknowledged

    process(clk_dest, rst)
    begin

        if (rst = '1') then
            state_dest <= S_READY;
            ack_dest_r <= '0';
            send_src_r_2 <= '0';
            send_src_r_3 <= '0';
            rcv        <= '0';
        elsif (rising_edge(clk_dest)) then


            --User Changes start
            send_src_r_2 <= send_src_r;
            send_src_r_3 <= send_src_r_2;
            --User Changes end

            rcv <= '0';

            case state_dest is
                when S_READY =>
                    -- if source is sending data, assert rcv (received)
                    if (send_src_r_3 = '1') then --Changed if 
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
                    if (send_src_r_3 = '0') then --changed if
                        ack_dest_r <= '0';
                        state_dest <= S_READY;
                    end if;

                when others => null;
            end case;
        end if;
    end process;



end TRANSITIONAL;