library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

entity program_flow is
	port (
		clk : in std_logic;
		rst : in std_logic;
		-- program memory
		program_counter : out program_counter_type;
		-- instruction decoding
		instruction : in instruction_type;
		instruction_payload : in program_counter_offset;			-- branch offset / jump literal
		valid_instruction : out std_logic;
		-- datapath inspection
		equal_zero : in std_logic;											-- conditional flag of parameter stack
		top_of_p_stack : in p_stack_cell;								-- parameter stack 
		-- subroutine stack access and control
		top_of_s_stack : in program_counter_offset;					-- subroutine stack
		push_s_stack : out std_logic;
		pop_s_stack : out std_logic
	);
	
end entity;
	
architecture rtl of program_flow is
	
type state_type is ( running, wait_one_cycle);
signal state, state_n : state_type := wait_one_cycle;
signal pc, pc_n : program_counter_type;
	
begin
	
	program_counter <= pc;
	push_s_stack <= '0';
	pop_s_stack <= '0';
	
	fsm_registers: process is
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			state <= wait_one_cycle;
			pc <= 0;
		else
			state <= state_n;
			pc <= pc_n;
		end if;
	end process;
	
	fsm_transitions: process(all) is
	begin
		
		case state is	
			when running =>
				valid_instruction <= '1';
				case instruction is
					when pf_nxt_2 =>
						state_n <= wait_one_cycle;
						pc_n <= pc + 1;		-- the prior instruction length assumption was wrong!  Correct the PC and restart the pipeline
						
					when pf_nxt_4 =>
						state_n <= wait_one_cycle;
						pc_n <= pc + 3;		-- the prior instruction length assumption was wrong!  Correct the PC and restart the pipeline
						
					when others =>				-- pf_nxt_1
						state_n <= running;	-- the prior instruction length assumption was correct!  Continue execution
						pc_n <= pc + 1;		-- the pipeline ASSUMES that the next instrution will be a one cycle instruction	
				end case;
					
			when others =>						-- wait_one_cycle
				valid_instruction <= '0';
				state_n <= running;
				pc_n <= pc + 1;
	
		end case;
	end process;

end architecture;
	
	
