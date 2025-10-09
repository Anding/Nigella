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
		-- program memory
		program_counter : out program_counter_type;
		-- instruction decoding
		instruction : in instruction_type;
		instruction_payload : in program_counter_offset;			-- branch offset / jump literal
		instruction_width : in program_counter_offset;				-- number of bytes of program memory comprising this instruction
		instruction_duration : in instruction_duration_type;		-- required clock cycles to execute the instruction
		-- datapath inspection
		equal_zero : in std_logic;											-- conditional flag of parameter stack
		top_of_p_stack : in p_stack_cell;								-- parameter stack 
		-- subroutine stack access and control
		top_of_s_stack : in program_counter_offset;					-- subroutine stack
		push_s_stack : in std_logic;
		pop_s_stack : out std_logic;
	);
	
end entity;
	
architecture rtl of program_flow is
	
begin

end architecture;