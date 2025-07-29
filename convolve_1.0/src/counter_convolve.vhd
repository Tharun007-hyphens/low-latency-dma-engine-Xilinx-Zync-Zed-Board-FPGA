library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use  work.math_custom.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity counter is 
generic
(
		words : positive := 128
);
	
port
(
	clk			: in std_logic;
	rst			: in std_logic;
	rd_en		: in std_logic;
	wr_en 		: in std_logic;
	c_out 		: out std_logic_vector(clog2(words) downto 0)--8 bits
);

end counter;

architecture default of counter is
signal count_reg : std_logic_vector(clog2(words) downto 0);

begin

process(clk, rst)

	variable temp : std_logic_vector(clog2(words) downto 0);
	begin

		if (rst = '1') then

			count_reg<= (others => '0');

		elsif(rising_edge(clk)) then
				
			temp := count_reg;		

			if(wr_en= '1' and rd_en= '1') then
			
			elsif(wr_en= '1' and unsigned(temp) < words) then

				temp := std_logic_vector(unsigned(temp) + 1);
			
			elsif(rd_en= '1' and unsigned(temp) /= 0) then 

				temp := std_logic_vector(unsigned(temp) - 1);
			
			end if;
						
			count_reg <= temp;
		
		end if;
end process;

	c_out <= count_reg;
	
end default;