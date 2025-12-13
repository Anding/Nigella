library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;
use work.types.all;

-- this entity maps 2 ports of 32-bit BLOCKRAM to a single byte-addressable 32-bit databus

entity byte_addressable is
  generic (
  	 -- width of the BLOCKRAM address bus accessing 32 bit longwords at each address
    addr_width : integer := 8
  );
	port (
		-- internal memory bus
		addr : in integer;													-- byte address
		mem_data_to_RAM : in std_logic_vector(31 downto 0);
		mem_data_from_RAM : out std_logic_vector(31 downto 0);
		we : in std_logic_vector(3 downto 0);
		-- BLOCKRAM port A
		addr_a : out std_logic_vector( addr_width - 1 downto 0);	-- longword address
		mem_data_to_RAM_a : out std_logic_vector(31 downto 0);
		mem_data_from_RAM_a : in std_logic_vector(31 downto 0);	
		we_a : out std_logic_vector(3 downto 0);			
		-- BLOCKRAM port B
		addr_b : out std_logic_vector( addr_width - 1 downto 0);	-- longword address
		mem_data_to_RAM_b : out std_logic_vector(31 downto 0);
		mem_data_from_RAM_b : in std_logic_vector(31 downto 0);		
		we_b : out std_logic_vector(3 downto 0)					
);


end entity;
	
architecture rtl of byte_addressable is
	
	
begin
	
process(all) is

variable addr_lo : integer;
variable addr_a_i : integer;
variable addr_b_i : integer;

begin
	
	addr_lo := addr mod 4;
	addr_a_i := addr / 4;
	addr_b_i := addr_a_i + 1;
	
	case addr_lo is
		when 0 =>
			mem_data_from_RAM <= mem_data_from_RAM_a;
			mem_data_to_RAM_a <= mem_data_to_RAM;
			mem_data_to_RAM_b <= (others => '0');
			we_a <= we;
			we_b <= "0000";
			
		when 1 =>
			mem_data_from_RAM <= mem_data_from_RAM_a(23 downto 0) &  mem_data_from_RAM_b(31 downto 24) ;
			mem_data_to_RAM_a <= "00000000" & mem_data_to_RAM(31 downto 8);
			mem_data_to_RAM_b <= mem_data_to_RAM(7 downto 0) & "00000000" & "00000000" & "00000000";
			we_a <= "0" & we(3 downto 1);
			we_b <= we(0) & "000";
						
		when 2 =>
			mem_data_from_RAM <= mem_data_from_RAM_a(15 downto 0) &  mem_data_from_RAM_b(31 downto 16) ;
			mem_data_to_RAM_a <= "00000000" & "00000000" & mem_data_to_RAM(31 downto 16);
			mem_data_to_RAM_b <= mem_data_to_RAM(15 downto 0) & "00000000" & "00000000";
			we_a <= "00" & we(3 downto 2);
			we_b <= we(1 downto 0) & "00";
							
		when others => -- 3
			mem_data_from_RAM <= mem_data_from_RAM_a(7 downto 0) &  mem_data_from_RAM_b(31 downto 8) ;
			mem_data_to_RAM_a <= "00000000" & "00000000" & "00000000" & mem_data_to_RAM(31 downto 24);
			mem_data_to_RAM_b <= mem_data_to_RAM(23 downto 0) & "00000000";
			we_a <= "000" & we(3);
			we_b <= we(2 downto 0) & "0";
				
	end case;
			
		addr_a <= std_logic_vector(to_unsigned(addr_a_i, addr_width));
		addr_b <= std_logic_vector(to_unsigned(addr_b_i, addr_width));			
			
end process;
	
end architecture; 