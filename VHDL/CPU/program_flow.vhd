library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_flow is
	generic (
	);	
	port (
		clk : in std_logic;
		rst : in std_logic;
		program_counter : out integer;
		next_instruction : in << decoded instruction type >>
	);
	
end entity;
	
architecture rtl of program_flow is
	
begin

end architecture;