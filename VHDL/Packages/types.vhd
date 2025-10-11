library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

package types is 

	-- architechure
	
	subtype p_stack_cell is std_logic_vector (p_stack_width -1 downto 0);

	-- program_flow

	type instruction_type is ( pf_nxt_1, -- consecutive instruction width 1 byte
										pf_nxt_2, -- consecutive instruction width 2 bytes
										pf_nxt_4, -- consecutive instruction width 4 bytes
										pf_bra, pf_beq, pf_rts, pf_jmp, pf_jsl, pf_jsr, pf_null );
			-- pf_rti
			-- pf_cth, pf_thw
			-- pf_pau
			
	subtype program_counter_type is integer range 0 to prog_mem_addr_top;
	subtype program_counter_offset is integer range -1 * max_branch_offset to prog_mem_addr_top;
	subtype instruction_duration_type is integer range 0 to max_instruction_duration;
		
end package;
		