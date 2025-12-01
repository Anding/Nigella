library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;
use work.testbench_recorder.all;

entity decoder_tb01 is
end entity;
	
architecture sim of decoder_tb01 is
	
signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal validfor_read : std_logic := '1';
signal prog_mem_data_from_RAM : std_logic_vector(31 downto 0) := (others => '0');	
signal instruction : instruction_type;
signal instruction_literal : instruction_literal_type;
signal instruction_duration : instruction_duration_type;
signal r_stack_op : stack_op_type;	
signal test_ended : boolean := false;
signal test_ok : boolean := false;

shared variable tb_rec : testbench_recorder_protected ;
	
begin
	
	DUT: entity work.decoder(rtl)
	port map(
		clk => clk,
		rst => rst,
		validfor_read => validfor_read, 
		prog_mem_data_from_RAM => prog_mem_data_from_RAM,
		instruction => instruction,
		instruction_literal => instruction_literal,
		instruction_duration => instruction_duration,
		r_stack_op => r_stack_op
	);
	
	clk <= not clk after half_clock_period;

	recorder: process is
	begin
		wait until rising_edge(clk);
			if (test_ended) then
				-- either save or verify
				--	tb_rec.save_recording("E:\coding\Nigella\VHDL\Decoder\decoder_tb01_log.txt");
				tb_rec.load_reference_recording("E:\coding\Nigella\VHDL\Decoder\decoder_tb01_log.txt");
				tb_rec.verify_recording_to_reference;
			else
				tb_rec.make_record(
					"instruction = " & to_string(instruction) & ", " &
					"instruction_literal = " & to_string(instruction_literal) & ", " &	
					"instruction_duration = " & to_string(instruction_duration) & ", " &		
					"r_stack_op = " & to_string(r_stack_op)												
						);
			end if;
	end process;	
		
	sequencer_process: process is
	begin
		wait for 3 * half_clock_period;
		rst <= '0';
		
		wait until rising_edge(clk);
			
		for i in 0 to 256 loop
			wait until rising_edge(clk);
			prog_mem_data_from_RAM <= std_logic_vector(to_unsigned(i, 8)) & "000000000000000000000000";
		end loop;
		
		prog_mem_data_from_RAM <= (others => '0');
		wait for 4 * clock_period;
		
		test_ended <= true;	wait for clock_period;
		-- save or verify the testbench recording
		test_ok <= true;	wait for clock_period; 
		report ("*** TEST COMPLETED OK ***");		
		std.env.finish;
	end process;

end architecture;