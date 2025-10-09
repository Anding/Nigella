library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library nigella;
use nigella.constants.all;

package types is 

	-- architechure
	
	subtype p_stack_cell is std_logic_vector (p_stack_width -1 down to 0);

	-- program_flow

	type instruction_type is ( pf_nxt, pf_bra, pf_beq, pf_rts, pf_jmp, pf_jsl, pf_jsr );
			-- pf_rti
			-- pf_cth, pf_thw
			-- pf_pau
			
	subtype program_counter_type is integer range 0 to prog_mem_addr_top;
	subtype program_counter_offset is integer range -1 * max_branch_offset to prog_mem_addr_top;
	subtype instruction_duration_type is integer range 0 to max_instruction_duration;
		
end package;
		