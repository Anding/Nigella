library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

entity decoder is
	port (
		clk : in std_logic;
		rst : in std_logic;
		-- program memory
		validfor_read : in std_logic;
		prog_mem_data_from_RAM : in std_logic_vector(31 downto 0);	-- longword from byte-addressable BLOCK RAM
		-- instruction decoding
		instruction : out instruction_type;
		instruction_literal : out instruction_literal_type;			-- branch offset / jump literal
		instruction_duration : out instruction_duration_type;			-- no. of additional cycles. 0 for a single-cycle instruction
		validfor_execution : out std_logic;
		r_stack_op : out stack_op_type;	
	);