-- Testbench for full adder
library IEEE;
use IEEE.std_logic_1164.all;
 
entity somador_tb is
-- empty
end somador_tb; 

architecture tb of somador_tb is

-- DUT component
component sum is
port(
  a: in std_logic_vector(7 downto 0);
  b: in std_logic_vector(7 downto 0);
  f: out std_logic_vector(7 downto 0);
  cin: in std_logic;
  cout: out std_logic);
end component;

signal a_in, b_in, s_out: std_logic_vector(7 downto 0);
signal c_in, c_out: std_logic;

begin

  -- Connect DUT
  DUT: sum port map(a_in, b_in, s_out, c_in, c_out);

  process
  begin
    a_in <= "00000001";
    b_in <= "00000001";
    c_in <= '0';
    wait for 1 ns;
    assert(s_out="00000010") report "Fail 0/0/0" severity error;
  
    

    -- Clear inputs
    a_in <= "00000000";
    b_in <= "00000000";
    c_in <= '0';

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
