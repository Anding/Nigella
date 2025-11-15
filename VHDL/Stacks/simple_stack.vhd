library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

-- a configurable stack
-- the 1st item on stack is held in a register
-- stack items 2nd and below are held in block memory

entity simple_stack is
	generic(																	
		width : integer := 32;												-- data bus width
		addr_width : integer := 16;										-- address bus width
		base_address : integer := 0										-- offset to address stack memory
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		stack_op : in stack_op_type;											-- push, pop, replace, nop		
		stack_cell_1 : out std_logic_vector(width - 1 downto 0);		-- 1st on stack		
		stack_cell_2 : out std_logic_vector(width - 1 downto 0);		-- 2nd on stack	
		new_cell_1 : in std_logic_vector(width - 1 downto 0);			-- write to top of stack
		mem_addr : out std_logic_vector (addr_width - 1 downto 0);	
		mem_data_from_RAM : in std_logic_vector(width - 1 downto 0);	-- write to BLOCK RAM
		mem_data_to_RAM : out std_logic_vector(width - 1 downto 0);		-- read from BLOCK RAM
		mem_we : out std_logic
	);
end entity;
	
architecture rtl of simple_stack is 
	
signal sp_i, sp_n, sp : integer;
signal mem_data_out_i, mem_data_out_n : std_logic_vector(width - 1 downto 0);
signal cell_i, cell_n : std_logic_vector(width - 1 downto 0);


begin
	
	stack_cell_1 <= cell_i;
	stack_cell_2 <= mem_data_from_RAM;
	sp <= sp_n + base_address;	
	mem_addr <= std_logic_vector(to_unsigned(sp, addr_width));
	mem_data_to_RAM <= cell_i;

	
	fsm_registers: process is
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			sp_i <= -2;							-- utilize the full depth of the memory
			cell_i <= (others =>'0');
		else
			sp_i <= sp_n;
			cell_i <= cell_n;
		end if;
	end process;
		
		
		
	fsm_transitions: process (all)
	begin
		case stack_op is
			when op_nop =>
				sp_n <= sp_i;
				mem_we <= '0';
				cell_n <= cell_i;	
							
			when op_psh =>
				sp_n <= sp_i + 1;
				mem_we <= '1';
				cell_n <= new_cell_1;	
								
			when op_pop =>
				sp_n <= sp_i - 1;
				mem_we <= '0';
				cell_n <= mem_data_from_RAM;		
				
			when others => -- op_rpl
				sp_n <= sp_i;
				mem_we <= '0';
				cell_n <= new_cell_1;						
								
		end case;
	
	end process;
		
	
end architecture;