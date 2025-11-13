library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;
use work.testbench_recorder.all;

entity simple_stack_tb01 is
end entity;
	
architecture sim of simple_stack_tb01 is

signal test_ended : boolean := false;
signal test_ok : boolean := false;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal stack_op : stack_op_type := op_nop;
signal cell_out : std_logic_vector(width - 1 downto 0);
signal cell_in : std_logic_vector(width - 1 downto 0) := (others => '0');
signal mem_addr : std_logic_vector (addr_width -1 downto 0);
signal mem_data_out : std_logic_vector(width - 1 downto 0);	
signal mem_data_in : std_logic_vector(width - 1 downto 0) := (others => '0');
signal mem_we : std_logic := '0';

shared variable tb_rec : testbench_recorder_protected ;

begin

	DUT: entity work.simple_stack(rtl)
	generic map(																	
		width => 32;											-- data bus width
		addr_width => 16;										-- address bus width
		base_address => 0										-- offset to address stack memory
	);
	port map(
		clk => clk,
		rst => rst,
		stack_op => stack_op,
		cell_out => cell_out,
		cell_in => cell_in,
		mem_addr => mem_addr,
		mem_data_out => mem_data_out,
		mem_data_in => mem_data_in,
		mem_we => me_we
	);
	
	clk <= not clk after half_clock_period;
	
	recorder: process is
	begin
		wait until rising_edge(clk);
			if (test_ended) then
				-- either save or verify
				 	tb_rec.save_recording("E:\coding\Nigella\VHDL\Stacks\simple_stack_tb01_log.txt");
				--	tb_rec.load_reference_recording("E:\coding\Nigella\VHDL\Stacks\simple_stack_tb01_log.txt");
				-- tb_rec.verify_recording_to_reference;
			else
				tb_rec.make_record(
					"rst = " & to_string(rst) & ", " &
					"cell_out = " & to_string(cell_out) & ", " &
					"mem_addr = " & to_string(mem_addr) & ", " &							
					"mem_we = " & to_string(mem_we)
						);
			end if;
	end process;	
	
		sequencer_process: process is
	begin
		wait for 3 * half_clock_period;
		rst <= '0';
		
		wait for clock_period;
		cell_in <= x"1234";
		stack_op <= op_psh;
		wait for clock_period;
		
		cell_in <= x"5678";
		stack_op <= op_psh;
		wait for clock_period;
		
		cell_in <= x"0000";
		stack_op <= op_pop;	
		wait for clock_period;
		
		cell_in <= x"0000";
		stack_op <= op_pop;	
		wait for clock_period;
		
		cell_in <= x"9ABC";
		stack_op <= op_rpl
		wait for clock_period;		
				
		cell_in <= x"0000";
		stack_op <= op_nop;	
		wait for clock_period;	
				
		wait for 4 * clock_period;		
		
		test_ended <= true;	wait for clock_period;
		-- save or verify the testbench recording
		test_ok <= true;	wait for clock_period; 
		report ("*** TEST COMPLETED OK ***");		
		std.env.finish;
	end process;

end architecture;