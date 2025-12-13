library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;
use work.testbench_recorder.all;

entity byte_addressable_tb01 is
end entity;
	
architecture sim of byte_addressable_tb01 is
	
signal clk : std_logic := '0';
signal test_ended : boolean := false;
signal test_ok : boolean := false;

constant ADDR_WIDTH : integer := 8;

signal addr : integer := 0;
signal mem_data_to_RAM : std_logic_vector(31 downto 0) := (others => '0');
signal mem_data_from_RAM : std_logic_vector(31 downto 0) := (others => '0');
signal we : std_logic_vector(3 downto 0) := (others => '0');
signal addr_a : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
signal mem_data_to_RAM_a : std_logic_vector(31 downto 0) := (others => '0');
signal mem_data_from_RAM_a : std_logic_vector(31 downto 0) := (others => '0');
signal we_a : std_logic_vector(3 downto 0) := (others => '0');	
signal addr_b : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
signal mem_data_to_RAM_b : std_logic_vector(31 downto 0) := (others => '0');
signal mem_data_from_RAM_b : std_logic_vector(31 downto 0) := (others => '0');		
signal we_b : std_logic_vector(3 downto 0) := (others => '0');

shared variable tb_rec : testbench_recorder_protected ;
	
begin
	
	DUT: entity work.byte_addressable(rtl)
	generic map(																	
		addr_width => ADDR_WIDTH
	)
	port map(
		-- internal memory bus
		addr => addr,
		mem_data_to_RAM => mem_data_to_RAM,
		mem_data_from_RAM => mem_data_from_RAM,
		we => we,
		-- BLOCKRAM port A
		addr_a => addr_a,
		mem_data_to_RAM_a => mem_data_to_RAM_a,
		mem_data_from_RAM_a => mem_data_from_RAM_a,	
		we_a => we_a,			
		-- BLOCKRAM port B
		addr_b => addr_b,
		mem_data_to_RAM_b => mem_data_to_RAM_b,
		mem_data_from_RAM_b => mem_data_from_RAM_b,	
		we_b => we_b	
	);
	
	clk <= not clk after half_clock_period;

	recorder: process is
	begin
		wait until rising_edge(clk);
			if (test_ended) then
				-- either save or verify
				tb_rec.save_recording("E:\coding\Nigella\VHDL\Memory\byte_addressable_tb01_log.txt");
				--tb_rec.load_reference_recording("E:\coding\Nigella\VHDL\Memory\byte_addressable_tb01_log.txt");
				--tb_rec.verify_recording_to_reference;
			else
				tb_rec.make_record(
					"to_RAM = " & to_hstring(mem_data_to_RAM) & ", " &					
					"from_RAM = " & to_hstring(mem_data_from_RAM) & ", " &
					"to_RAM_a = " & to_hstring(mem_data_to_RAM_a) & ", " &	
					"from_RAM_a = " & to_hstring(mem_data_from_RAM_a) & ", " &		
					"we_a = " & to_hstring(we_a) 										
						);
			end if;
	end process;	
		
	sequencer_process: process is
	begin
		wait for 3 * half_clock_period;
		
		wait until rising_edge(clk);
		mem_data_to_RAM <= x"87654321";
		mem_data_from_RAM_a <= x"44332211";
		mem_data_from_RAM_b <= x"ddccbbaa";		
		
		wait for clock_period;
		addr <= 1;

		wait for clock_period;
		addr <= 2;	
			
		wait for clock_period;
		we <= "0001";
		
		wait for clock_period;
		we <= "0010";		
		
		wait for clock_period;
		we <= "0100";			

		wait for clock_period;
		we <= "1000";
		
		wait for clock_period;
		we <= "0011";	
		
		wait for clock_period;
		we <= "1100";		

		wait for clock_period;
		we <= "1111";	
		
		wait for clock_period;
		addr <= 3;	
		we <= "0000";
		
		wait for clock_period;
		addr <= 4;	
		we <= "0000";
		
		wait for clock_period;
		addr <= 5;	
		we <= "0000";	
		
		wait for clock_period;
		we <= "0001";
		
		wait for clock_period;
		we <= "0010";		
		
		wait for clock_period;
		we <= "0100";			

		wait for clock_period;
		we <= "1000";
		
		wait for clock_period;
		we <= "0011";	
		
		wait for clock_period;
		we <= "1100";		

		wait for clock_period;
		we <= "1111";	
			
		wait for 2 * clock_period;
		
		test_ended <= true;	wait for clock_period;
		-- save or verify the testbench recording
		test_ok <= true;	wait for clock_period; 
		report ("*** TEST COMPLETED OK ***");		
		std.env.finish;
	end process;

end architecture;