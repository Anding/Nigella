library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constants is 

	constant prog_mem_addr_top : integer := 65535;
	constant max_instruction_duration : integer := 255;
	constant p_stack_width : integer := 32;
	
	constant clock_period : time := 10 ns;
	constant half_clock_period : time := 5 ns;
	
		
end package;
		