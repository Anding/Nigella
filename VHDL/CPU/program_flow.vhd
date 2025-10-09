library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library nigella;
use nigella.constants.all;
use nigella.types.all;

entity program_flow is
	generic (
	);	
	port (
		clk : in std_logic;
		rst : in std_logic;
		-- program memory access
		program_counter : out program_counter_type;
		next_instruction : in program_flow_instruction_type;
		next_instruction_offset : in program_counter_offset;
		-- datapath inspection
		equal_zero : in std_logic;		
		-- return stack access and control
		return_program_counter : in program_counter_offset;
		push_return_program_counter : in std_logic;
		pop_return_program_counter : out std_logic;
	);
	
end entity;
	
architecture rtl of program_flow is
	
begin

end architecture;