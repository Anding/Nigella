library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;
use work.testbench_recorder.all;

entity program_flow_tb01 is
end entity;
	
architecture sim of program_flow_tb01 is
	
signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal program_counter : program_counter_type;
signal instruction : instruction_type := pf_nxt_1;
signal instruction_literal : instruction_literal_type := 0;
signal instruction_duration : instruction_duration_type := 0;
signal valid_instruction : std_logic;
signal equal_zero : std_logic := '0';
signal top_of_p_stack : program_counter_type := 0;
signal top_of_s_stack : program_counter_type := 0;
signal push_s_stack : std_logic;
signal pop_s_stack : std_logic;

signal test_ended : boolean := false;
signal test_ok : boolean := false;

shared variable tb_rec : testbench_recorder_protected ;

-- example program flow data
type instruction_mem_type is array (0 to 127) of instruction_type;
signal instruction_mem : instruction_mem_type := (0 => pf_nxt_1, 1 => pf_nxt_1, 2 => pf_nxt_2, 
		3 => pf_null, 4 => pf_nxt_2, 5 => pf_null, 6 => pf_bra, 7 => pf_null, 10 => pf_beq, 11 => pf_null, 
		12 => pf_jmp, 17 => pf_beq, others => pf_nxt_1);

type instruction_literal_mem_type is array (0 to 127) of instruction_literal_type;
signal instruction_literal_mem : instruction_literal_mem_type := (6 => 3, 10 => -1, 12 => -1, others => 0);
	
type equal_zero_mem_type is array (0 to 127) of std_logic;
signal equal_zero_mem : equal_zero_mem_type := (12 => '1', others => '0');

type p_stack_cell_mem_type is array (0 to 127) of program_counter_type;
signal p_stack_cell_mem : p_stack_cell_mem_type := (12 => 16, others => 0);
	
begin
	
	DUT: entity work.program_flow(rtl)
	port map(
		clk => clk,
		rst => rst,
		program_counter => program_counter,
		instruction => instruction,
		instruction_literal => instruction_literal,
		instruction_duration => instruction_duration,
		valid_instruction => valid_instruction,
		equal_zero => equal_zero,
		top_of_p_stack => top_of_p_stack,
		top_of_s_stack => top_of_s_stack,
		push_s_stack => push_s_stack,
		pop_s_stack => pop_s_stack
	);
	
	clk <= not clk after half_clock_period;
	
	program_memory: process is
	begin
		wait until rising_edge(clk);	
		instruction <= instruction_mem(program_counter);
		instruction_literal <= instruction_literal_mem(program_counter);	
		equal_zero <= equal_zero_mem(program_counter);	
		top_of_p_stack <= p_stack_cell_mem(program_counter);
	end process;
	
	recorder: process is
	begin
		wait until rising_edge(clk);
			if (test_ended) then
				-- either save or verify
				--	tb_rec.save_recording("E:\coding\Nigella\VHDL\CPU\program_flow_tb01_log.txt");
					tb_rec.load_reference_recording("E:\coding\Nigella\VHDL\CPU\program_flow_tb01_log.txt");
					tb_rec.verify_recording_to_reference;
			else
				tb_rec.make_record(
					"rst = " & to_string(rst) & ", " &
					"PC = " & to_string(program_counter) & ", " &
					"vld = " & to_string(valid_instruction)
						);
			end if;
	end process;	
		
	sequencer_process: process is
	begin
		wait for 3 * half_clock_period;
		rst <= '0';
		
		wait until rising_edge(clk);
			
		wait for 14 * clock_period;
		
		test_ended <= true;	wait for clock_period;
		-- save or verify the testbench recording
		test_ok <= true;	wait for clock_period; 
		report ("*** TEST COMPLETED OK ***");		
		std.env.finish;
	end process;

end architecture;