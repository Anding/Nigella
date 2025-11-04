library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

entity simple_stack is
	generic(																	
		width : integer := 32;												-- data bus width
		addr_width : integer := 16											-- address bus width
		base_address : interger := 0;										-- offset to address stack memory
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		stack_op : in stack_op_type										-- push, pop, replace, nop		
		cell_out : out std_logic_vector(width - 1 downto 0);		-- top of stack		
		cell_in : in std_logic_vector(width - 1 downto 0);			-- write to top of stack
		sp : out integer;														-- stack pointer indicates the number of items on the stack, including zero
		mem_addr : out std_logic_vector (addr_width -1 downto 0);	
		mem_data_out : out std_logic_vector(width - 1 downto 0);	-- write to BLOCK RAM
		mem_data_in : out std_logic_vector(width - 1 downto 0);	-- read from BLOCK RAM
		mem_we : out std_logic;

	);
end entity;
	
architecture rtl of simple_stack is 
	
begin
	
end architecture;