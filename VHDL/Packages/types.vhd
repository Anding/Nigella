library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;

package types is 

	-- architechure
	
	subtype p_stack_cell_type is std_logic_vector (p_stack_width -1 downto 0);

	-- program_flow

	type instruction_type is ( pf_nxt_1, -- sequential instruction width 1 byte
										pf_nxt_2, -- sequential instruction width 2 bytes (opcode + byte literal)
										pf_nxt_3, -- sequential instruction width 3 bytes (opcode + word literal)
										pf_nxt_5, -- sequential instruction width 5 bytes (opcode + longword literal)
										pf_bra, pf_beq, pf_rts, pf_jmp, pf_jsl, pf_jsr, pf_slp );
			
	subtype program_counter_type is integer ;
	subtype instruction_literal_type is integer ;
	subtype instruction_duration_type is integer range 0 to max_instruction_duration;
	
	type stack_op_type is ( op_nop, op_psh, op_pop, op_rpl);
		
	-- branch bits encoding
	constant bb_nop : std_logic_vector(1 downto 0) := "00";
	constant bb_rts : std_logic_vector(1 downto 0) := "01";	
	constant bb_beq : std_logic_vector(1 downto 0) := "10";	
	constant bb_bra : std_logic_vector(1 downto 0) := "11";				
		
end package;
		