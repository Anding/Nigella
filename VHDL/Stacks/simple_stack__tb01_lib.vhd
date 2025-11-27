library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

-- create a new package out of the generic package

package simple_stack_tb01_RAM is new work.RAM_for_testbench
  generic map (
    DATA_WIDTH => 32,
    ADDR_WIDTH => 8
  );