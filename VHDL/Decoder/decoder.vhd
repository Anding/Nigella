library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

entity decoder is
	port (
		clk : in std_logic;
		rst : in std_logic;
		-- program memory
		validfor_read : in std_logic;
		prog_mem_data_from_RAM : in std_logic_vector(31 downto 0);	-- longword from byte-addressable BLOCK RAM
		-- instruction decoding
		instruction : out instruction_type;
		instruction_literal : out instruction_literal_type;			-- branch offset / jump literal
		instruction_duration : out instruction_duration_type;			-- no. of additional cycles. 0 for a single-cycle instruction
		r_stack_op : out stack_op_type	
	);

end entity;
	
architecture rtl of decoder is 
	
	type instruction_rom_type is array (0 to 63) of instruction_type;
	type instruction_duration_rom_type is array (0 to 63) of instruction_duration_type;
	type r_stack_op_rom_type is array (0 to 63) of stack_op_type;

  	-- Make the ROM a constant so synthesis implements it as a combinational LUT/mux for zero latency
	constant instruction_rom : instruction_rom_type := (
		52 => pf_nxt_2, 
		53 => pf_nxt_3, 
		54 => pf_nxt_5, 
		55 => pf_jmp, 
		56 => pf_jsl, 
		57 => pf_jsr, 
		61 => pf_slp,
		others => pf_nxt_1
	);
  
  	constant instruction_duration_rom : instruction_duration_rom_type := (
		41 => 4, 
		42 => 4, 
		43 => 200, 
		44 => 200, 
		others => 0
	);
	
  -- initialize ROM with enum literals (clean and readable)
	signal r_stack_op_rom : r_stack_op_rom_type := (
		56 => op_psh, 
		57 => op_psh, 
		others => op_nop
  );
  	-- apply Xilinx attribute to the signal to encourage LUTRAM (distributed)
	attribute rom_attribute : string;
	attribute rom_attribute of r_stack_op_rom : signal is "distributed";

	signal branch_bits : std_logic_vector(1 downto 0);
	signal encoding_bits : std_logic_vector(5 downto 0);
	signal branch_literal_bits : std_logic_vector(13 downto 0);		
	signal jump_literal_bits : std_logic_vector(23 downto 0);
	signal encoding_addr : integer;

begin
	
	-- use signals rather than aliases to appear in the testbench
	branch_bits <= prog_mem_data_from_RAM(31 downto 30);
	encoding_bits <= prog_mem_data_from_RAM(29 downto 24);
	branch_literal_bits <= prog_mem_data_from_RAM(29 downto 16);		
	jump_literal_bits <= prog_mem_data_from_RAM(23 downto 0);
	encoding_addr <= to_integer(unsigned(encoding_bits));	
		
  -- combinatorial decoding for the program counter logic
	combinatorial_decode: process(all) is		
	begin
		case branch_bits is
			when bb_nop =>
				instruction <= instruction_rom(encoding_addr);
				instruction_literal <= to_integer(unsigned(jump_literal_bits));
				instruction_duration <= instruction_duration_rom(encoding_addr);					
			when bb_rts =>
				instruction <= pf_rts;
				instruction_literal <= to_integer(unsigned(jump_literal_bits));
				instruction_duration <= 0;
			when bb_beq =>
				instruction <= pf_beq;
				instruction_literal <= to_integer(signed(branch_literal_bits));
				instruction_duration <= 0;
			when others => -- bb_bra
				instruction <= pf_bra;
				instruction_literal <= to_integer(signed(branch_literal_bits));
				instruction_duration <= 0;
			end case;
				
	end process;

  -- ROM decoding for the stacks (1-cycle latency)
	ROM_decode: process is	
	begin
		wait until rising_edge(clk);
		if validfor_read = '1' then
			case branch_bits is
				when bb_nop =>
					r_stack_op <= r_stack_op_rom(encoding_addr);
				when bb_rts =>
					r_stack_op <= op_pop;
				when bb_beq =>
					r_stack_op <= op_nop;
				when others => -- bb_bra
					r_stack_op <= op_nop;
			end case;
		else
			r_stack_op <= op_nop;
		end if;		

	end process;
	
end architecture;