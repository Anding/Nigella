library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library nigella;
use nigella.constants.all;

package types is 

	-- program_flow

	type program_flow_instruction_type is ( pf_nxt, pf_bra, pf_beq, pf_rts, pf_jmp, pf_jsr, pf_jsl );
			-- pf_rti
			-- pf_cth, pf_thw
			-- pf_pau
			
	subtype program_counter_type is integer range 0 to prog_mem_addr_top;
	subtype program_counter_offset is integer range -8096 to prog_mem_addr_top;
		
end package;
		