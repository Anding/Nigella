library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

entity program_flow_tb01 is
end entity;
	
architecture sim of program_flow_tb01 is
	
signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal program_counter : program_counter_type;
signal instruction : instruction_type := pf_nxt_1;
signal instruction_payload : program_counter_offset := 0;
signal valid_instruction : std_logic;
signal equal_zero : std_logic := '0';
signal top_of_p_stack : p_stack_cell := (others=>'0');
signal top_of_s_stack : program_counter_offset := 0;
signal push_s_stack : std_logic;
signal pop_s_stack : std_logic;

type instruction_mem_type is array (0 to 15) of instruction_type;
signal instruction_mem : instruction_mem_type := (0 => pf_nxt_1, 1 => pf_nxt_1, 2 => pf_nxt_2, 
		3 => pf_null, 4 => pf_nxt_2, 5 => pf_null, others => pf_nxt_1);

begin
	
	DUT: entity work.program_flow(rtl)
	port map(
		clk => clk,
		rst => rst,
		program_counter => program_counter,
		instruction => instruction,
		instruction_payload => instruction_payload,
		valid_instruction => valid_instruction,
		equal_zero => equal_zero,
		top_of_p_stack => top_of_p_stack,
		top_of_s_stack => top_of_s_stack,
		push_s_stack => push_s_stack,
		pop_s_stack => pop_s_stack
	);
	
	clk <= not clk after half_clock_period;
	
	instruction <= instruction_mem(program_counter);
	
	sequencer_process: process is
	begin
		wait for 3 * half_clock_period;
		rst <= '0';
		
		wait until rising_edge(clk);
			
		wait for 10 * clock_period;
		report ("*** TEST COMPLETED OK ***");
		std.env.finish;
	end process;
	
end architecture;