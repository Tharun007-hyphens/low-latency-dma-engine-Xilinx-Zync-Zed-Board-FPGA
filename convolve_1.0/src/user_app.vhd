library ieee;
use ieee.std_logic_1164.all;

use work.config_pkg.all;
use work.user_pkg.all;
use ieee.numeric_std.all;

entity user_app is
    generic
    (
        words: positive  := 128;
        bits :positive := 16  
    );
    port 
    (
        clk : in std_logic;
        rst : in std_logic;
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE);
        ram0_rd_rd_en : out std_logic;
        ram0_rd_go    : out std_logic;
        ram0_rd_valid : in  std_logic;
        ram0_rd_data  : in  std_logic_vector(RAM0_RD_DATA_RANGE);
        ram0_rd_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_rd_size  : out std_logic_vector(RAM0_RD_SIZE_RANGE);
        ram0_rd_done  : in  std_logic;

        -- debug signals
        debug_ram0_rd_count      : in std_logic_vector(RAM0_RD_SIZE_RANGE);
        debug_ram0_rd_start_addr : in std_logic_vector(RAM0_ADDR_RANGE);
        debug_ram0_rd_addr       : in std_logic_vector(RAM0_ADDR_RANGE);
        debug_ram0_rd_size       : in std_logic_vector(C_RAM0_ADDR_WIDTH downto 0);
		
        ram1_wr_ready : in  std_logic;
        ram1_wr_go    : out std_logic;
        ram1_wr_valid : out std_logic;
        ram1_wr_data  : out std_logic_vector(RAM1_WR_DATA_RANGE);
        ram1_wr_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_wr_size  : out std_logic_vector(RAM1_WR_SIZE_RANGE);
        ram1_wr_done  : in  std_logic
    );
end user_app;

architecture default  of user_app is

    signal sg_size      : std_logic_vector(RAM0_RD_SIZE_RANGE);
    signal go               : std_logic;
    signal clear       : std_logic;

    signal kb_en         : std_logic;
    signal Kernel_full          : std_logic;
    signal Kernel_empty         : std_logic;
    signal Kernel_input            : std_logic_vector(15 downto 0);
    signal Kernel_output           : std_logic_vector ((words*bits) - 1 downto 0);

    signal signal_full          : std_logic;
    signal signal_empty         : std_logic;
    signal signal_out           : std_logic_vector ((words*bits) - 1 downto 0);

	signal pp_output  : std_logic_vector(38 downto 0);
	signal pp_clipped : std_logic_vector(15 downto 0);

begin

    U_MMAP : entity work.memory_map
        port map 
        (
            clk             => clk,
            rst             => rst,

            wr_en           => mmap_wr_en,
            wr_addr         => mmap_wr_addr,
            wr_data         => mmap_wr_data,
            rd_en           => mmap_rd_en,
            rd_addr         => mmap_rd_addr,
            rd_data         => mmap_rd_data, 
            go              => go, 
            clear           => clear,
            sw_rst          => open,
            signal_size     => sg_size,
            kernel_data     => Kernel_input,
            kernel_load     => kb_en,
            kernel_ready    => Kernel_full,
            done            => ram1_wr_done 

        );

    U_SB : entity work.s_b
        generic map
        (
            words        => words,
            bits            => bits
        )
    
        port map
        (
            clk             => clk,          
            rst             => rst or clear,
            wr_en           => ram0_rd_valid,
            rd_en           => ram1_wr_ready and (not signal_empty),
            data_in         => ram0_rd_data,

            empty           => signal_empty,
            full            => signal_full,
            data_out        => signal_out
        );

    U_KB : entity work.k_b
        generic map
        (
            words    => words,
            bits        => bits
        )
        port map
        (
            clk         => clk,            
            rst         => rst or clear,  
            wr_en       => kb_en,
            rd_en       => ram1_wr_ready and Kernel_full,
            data_in     => Kernel_input,
            
            data_out    => Kernel_output,
            empty       => Kernel_empty,
            full        => Kernel_full
        );
        
    U_DATAPATH: entity work.mult_add_tree(unsigned_arch)
        generic map
        (
            num_inputs      => 128,
            input1_width    => bits,
            input2_width    => bits
        )
        port map
        ( 
            clk 		    => clk,
            rst 		    => rst,
            en 		        => ram1_wr_ready,
            input1	        => signal_out,
            input2	        => Kernel_output, 
            output	        => pp_output
        );


    U_PIPELINE_VALID_DELAY : entity work.delay
        generic map 
        (
            width       => 1,
            cycles      => 8
        )
        port map 
        (
            clk         => clk,
            en          => ram1_wr_ready,
            input(0)    => ram1_wr_ready and (not signal_empty),
            output(0)   => ram1_wr_valid
        );

    -- Clipping
    process(pp_output)
	begin
            
        if(unsigned(pp_output(38 downto 16)) > 0 ) then
    
            pp_clipped  <= "1111111111111111";  
    
        else
    
            pp_clipped   <= pp_output(15 downto 0); 
    
        end if;
              
    end process;

    ram0_rd_go      <= go;
    ram0_rd_rd_en   <= ram0_rd_valid and ram1_wr_ready;
    ram0_rd_size    <= std_logic_vector(2*(words-1)+unsigned(sg_size));
    ram0_rd_addr    <= (others=>'0');
    ram1_wr_go      <= go;
    ram1_wr_size    <= std_logic_vector((words-1)+unsigned(sg_size));
    ram1_wr_data    <= pp_clipped;
    ram1_wr_addr    <= (others=>'0');

end default;



	--sb_rd_en<=ram1_wr_ready and (not signal_empty);
	--reset<=rst or memory_clear;

 
	
	--kb_rd_en<=ram1_wr_ready and Kernel_full;
	
  

	--ip_delay<=ram1_wr_ready and (not signal_empty);

   