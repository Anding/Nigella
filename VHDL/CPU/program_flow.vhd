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
		validfor_read : out std_logic;
		-- instruction decoding
		instruction : in instruction_type;
		instruction_literal : in instruction_literal_type;			-- branch offset / jump literal
		instruction_duration : in instruction_duration_type;		-- no. of additional cycles. 0 for a single-cycle instruction
		validfor_execution : out std_logic;
		-- datapath inspection
		equal_zero : in std_logic;											-- conditional flag of parameter stack
		top_of_p_stack : in program_counter_type;						-- parameter stack 
		-- multi tasking
		req_sleep : in std_logic;
		req_wake : in std_logic;		
		acq_sleep : out std_logic;
		-- subroutine stack access and control
		top_of_s_stack : in program_counter_type;						-- subroutine stack
		push_s_stack : out std_logic;
		pop_s_stack : out std_logic
	);
	
end entity;
	
architecture rtl of program_flow is
	
type state_type is ( run_pipeline, restart_pipeline, delay_pipeline, sleep);
signal state, state_n : state_type := restart_pipeline;
signal pc, pc_n : program_counter_type := 0;
signal countdown, countdown_n : instruction_duration_type := 0;
	
begin
	
	program_counter <= pc;
	push_s_stack <= '0';
	pop_s_stack <= '0';
	
	fsm_registers: process is
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			state <= restart_pipeline;
			pc <= 0;
		else
			state <= state_n;
			pc <= pc_n;
			countdown <= countdown_n;
		end if;
	end process;
	
	fsm_transitions: process(all) is
	begin
		
		case state is	
			when run_pipeline =>
				validfor_execution <= '1';
					case instruction is
						when pf_nxt_1 =>					-- pf_nxt_1, a 1 byte sequential instruction
							case instruction_duration is
								when 0 =>
									countdown_n <= 0;										
									if (req_sleep = '0') then
										state_n <= run_pipeline;	
										validfor_read <= '1';
										pc_n <= pc + 1;				-- the pipeline ASSUMES that the next instruction will be a one cycle instruction		
									else 
										state_n <= sleep;
										validfor_read <= '0';
										pc_n <= pc;				
									end if;							
								when 1 =>
									state_n <= restart_pipeline;	
									countdown_n <= 0;		
									validfor_read <= '0';
									pc_n <= pc;											
								when others => 	 
									state_n <= delay_pipeline;
									countdown_n <= instruction_duration - 2;
									validfor_read <= '0';
									pc_n <= pc;
							end case;
						
						when pf_nxt_2 =>			-- 2 byte sequential instructions
							state_n <= restart_pipeline;
							countdown_n <= 0;
							validfor_read <= '0';
							pc_n <= pc + 1;				-- the prior instruction length assumption was wrong!  Correct the PC and restart the pipeline
	
						when pf_nxt_3 =>			-- 3 byte sequential instructions
							state_n <= restart_pipeline;
							countdown_n <= 0;
							validfor_read <= '0';
							pc_n <= pc + 2;
												
						when pf_nxt_5 =>			-- 5 byte sequential instructions
							state_n <= restart_pipeline;
							countdown_n <= 0;
							validfor_read <= '0';
							pc_n <= pc + 4;
						
						when pf_bra =>				-- branch, the offset is calculated from the second byte (i.e. -1 for an indefinite loop)
							state_n <= restart_pipeline;
							countdown_n <= 0;
							validfor_read <= '0';
							pc_n <= pc + instruction_literal;
	
						when pf_beq =>				-- conditional branch
							state_n <= restart_pipeline;
							countdown_n <= 0;
							validfor_read <= '0';
							if (equal_zero = '1') then
								pc_n <= pc + instruction_literal;
							else
								pc_n <= pc + 1;
							end if;
								
						when pf_jmp =>				-- jump to the address on the stack
							state_n <= restart_pipeline;
							countdown_n <= 0;
							validfor_read <= '0';
							pc_n <= top_of_p_stack;
						
						when others =>				-- pf_nxt_1, a 1 byte sequential instruction
							state_n <= run_pipeline;	-- the prior instruction length assumption was correct!  Continue execution
							countdown_n <= 0;
							validfor_read <= '0';
							pc_n <= pc + 1;				-- the pipeline ASSUMES that the next instruction will be a one cycle instruction	
					end case;
			
			when delay_pipeline =>
				validfor_execution <= '0';
				pc_n <= pc;					
				if (countdown = 0) then 
					countdown_n <= 0;
					state_n <= restart_pipeline;			
				else
					countdown_n <= countdown - 1;
					state_n <= delay_pipeline;			
				end if;
				validfor_read <= '0';
				
			when sleep =>
				validfor_execution <= '0';
				validfor_read <= '0';
				countdown_n <= 0;	
				pc_n <= pc;									
				if (req_wake = '0') then
					state_n <= sleep;
				else 
					state_n <= restart_pipeline;		
				end if;					
									
			when others =>						-- restart_pipeline
				validfor_execution <= '0';
				countdown_n <= 0;				
				if (req_sleep = '0') then
					state_n <= run_pipeline;	-- on the last clock latch the PC was 'caught up', after this clock cycle it will have read the next instruction from memory	
					validfor_read <= '1';
					pc_n <= pc + 1;				-- the pipeline ASSUMES that the next instruction will be a one cycle instruction		
				else 
					state_n <= sleep;
					validfor_read <= '0';
					pc_n <= pc;				
				end if;			
		end case;
	end process;

end architecture;
	
	
