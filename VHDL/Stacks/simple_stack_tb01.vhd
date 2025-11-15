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
constant width : integer := 32;
constant addr_width : integer := 16;
constant base_address : integer := 0;

signal test_ended : boolean := false;
signal test_ok : boolean := false;

signal clk : std_logic := '0';
signal rst : std_logic := '1';
signal stack_op : stack_op_type := op_nop;
signal stack_cell_1 : std_logic_vector(width - 1 downto 0);
signal new_cell_1 : std_logic_vector(width - 1 downto 0) := (others => '0');
signal mem_addr : std_logic_vector (addr_width - 1 downto 0) := (others => '0');
signal mem_data_to_RAM : std_logic_vector(width - 1 downto 0) := (others => '0');	
signal mem_data_from_RAM : std_logic_vector(width - 1 downto 0) := (others => '0');
signal mem_we : std_logic :='0';

shared variable tb_rec : testbench_recorder_protected ;

type stack_mem_type is array (0 to 2**addr_width - 1 ) of std_logic_vector(width - 1 downto 0);	
signal stack_mem : stack_mem_type := (others => (others => '0'));

begin

	DUT: entity work.simple_stack(rtl)
	generic map(																	
		width => width,									-- data bus width
		addr_width => addr_width ,						-- address bus width
		base_address => base_address					-- offset to address stack memory
	)
	port map(
		clk => clk,
		rst => rst,
		stack_op => stack_op,
		stack_cell_1 => stack_cell_1,
		new_cell_1 => new_cell_1,
		mem_addr => mem_addr,
		mem_data_to_RAM => mem_data_to_RAM,
		mem_data_from_RAM => mem_data_from_RAM,
		mem_we => mem_we
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
					"stack_cell_1 = " & to_string(stack_cell_1) & ", " &
					"mem_addr = " & to_string(mem_addr) & ", " &							
					"mem_we = " & to_string(mem_we)
						);
			end if;
	end process;	
	
	memory: process is
	variable sp : integer;
	begin
		sp := to_integer(unsigned(mem_addr));
		wait until rising_edge(clk);
			mem_data_from_RAM <= stack_mem(sp);	
			if mem_we = '1' then
				stack_mem(sp) <= mem_data_to_RAM;
			else
				stack_mem(sp) <= stack_mem(sp);
			end if;
	end process;
	
	
	sequencer_process: process is
	begin
		wait for 3 * half_clock_period;
		rst <= '0';
		
		wait for clock_period;
		new_cell_1 <= x"00001234";
		stack_op <= op_psh;
		wait for clock_period;
		
		new_cell_1 <= x"00005678";
		stack_op <= op_psh;
		wait for clock_period;
		
		new_cell_1 <= x"00000000";
		stack_op <= op_pop;	
		wait for clock_period;
		
		new_cell_1 <= x"00000000";
		stack_op <= op_pop;	
		wait for clock_period;
		
		new_cell_1 <= x"00009ABC";
		stack_op <= op_rpl;
		wait for clock_period;		
				
		new_cell_1 <= x"00000000";
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