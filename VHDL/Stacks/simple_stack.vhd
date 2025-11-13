library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

entity simple_stack is
	generic(																	
		width : integer := 32;												-- data bus width
		addr_width : integer := 16;										-- address bus width
		base_address : integer := 0										-- offset to address stack memory
	);
	port (
		clk : in std_logic;
		rst : in std_logic;
		stack_op : in stack_op_type;										-- push, pop, replace, nop		
		cell_out : out std_logic_vector(width - 1 downto 0);		-- top of stack		
		cell_in : in std_logic_vector(width - 1 downto 0);			-- write to top of stack
		mem_addr : out std_logic_vector (addr_width - 1 downto 0);	
		mem_data_out : out std_logic_vector(width - 1 downto 0);	-- write to BLOCK RAM
		mem_data_in : in std_logic_vector(width - 1 downto 0);	-- read from BLOCK RAM
		mem_we : out std_logic
	);
end entity;
	
architecture rtl of simple_stack is 
	
signal sp_i, sp_n, sp : integer;
signal mem_data_out_i, mem_data_out_n : std_logic_vector(width - 1 downto 0);
signal mem_we_i, mem_we_n : std_logic;
signal cell_out_i, cell_out_n : std_logic_vector(width - 1 downto 0);


begin
	
	sp <= sp_i + base_address;
	mem_addr <= to_unsigned(sp, addr_width);
	mem_data_out <= cell_out_i;
	
	fsm_registers: process is
	begin
		wait until rising_edge(clk);
		if rst = '1' then
			sp_i <= 0;
			mem_we_i <= '0';
			cell_out_i <= (others =>'0');
		else
			sp_i <= sp_n;
			mem_we_i <= mem_we_n;
			cell_out_i <= cell_out_n;
		end if;
	end process;
		
		
		
	fsm_transitions: process (all)
	begin
		case stack_op is
			when op_nop =>
				sp_n <= sp_i;
				mem_we_n <= '0';
				cell_out_n <= cell_out_i;	
							
			when op_psh =>
				sp_n <= sp_i + 1;
				mem_we_n <= '1';
				cell_out_n <= cell_in;	
								
			when op_pop =>
				sp_n <= sp_i - 1;
				mem_we_n <= '0';
				cell_out_n <= mem_data_in;		
				
			when others => -- op_rpl
				sp_n <= sp_i;
				mem_we_n <= '0';
				cell_out_n <= cell_in;					
								
		end case;
	
	end process;
		
	
end architecture;