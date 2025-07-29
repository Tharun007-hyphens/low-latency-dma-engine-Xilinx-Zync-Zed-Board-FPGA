library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.math_custom.all;
use work.user_pkg.all;

entity k_b is
generic 
(
	words : positive := 128;
	bits : positive  := 16
);

port 
(
	clk 		: in std_logic;
	rst 		: in std_logic;
	wr_en 	  	: in std_logic;
	rd_en 	  	: in std_logic;
	data_in   	: in std_logic_vector (bits-1 downto 0); 

	empty 		: out std_logic;
	full 		: out std_logic;
	data_out 	: out std_logic_vector ((bits * words) - 1 downto 0)
);
end k_b;

architecture default of k_b is

	signal win  : window(0 to 127);
	signal ctr : std_logic_vector(clog2(words) downto 0);  

begin

	
	U_ctr : entity work.counter
	generic map
	(
		words => words
	)
	port map
	( 
		clk => clk,
		rst => rst,
		rd_en => '0',
		wr_en => wr_en,
		c_out => ctr
	 );


	process(rst, clk)
	begin
		
		if(rst = '1') then
		
			win <= (others => (others => '0'));

		
		elsif(rising_edge(clk)) then

			if(wr_en = '1') then 
		
				win(0) <= data_in;
		
				for i in 0 to words-2 loop
					win(i + 1) <= win(i);
				end loop;
		
			end if;
		end if;
	end process;
	

	process(rst, rd_en, win)
	begin
		
		if(rst = '1') then
		
			data_out <= (others => '0');
		
		else 
		
			if(rd_en = '1') then 
		
				for j in 0 to words-1 loop
					data_out((j+1)*bits - 1 downto (j*bits)) <= win(j); 
				end loop;
	
			else

				data_out <= (others => '0');
	
			end if;
	
		end if;
	
	end process;


	process(ctr, rst ) 
	variable temp_ctr : positive := words;
	begin
		if(rst = '1') then

			full <= '0';
			empty  <= '1';
		
		else
			if(ctr =  std_logic_vector(to_unsigned(temp_ctr, clog2(words)+1) )) then
				full <= '1';
			else 
				full <= '0';
			end if;
			if(ctr < std_logic_vector(to_unsigned(temp_ctr, clog2(words)+1))) then
				empty <= '1'; 
			else
				empty <= '0';
			end if;
		
		end if;
	end process;
	

end default;