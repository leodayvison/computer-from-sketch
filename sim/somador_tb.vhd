-- Testbench for full adder
library IEEE;
use IEEE.std_logic_1164.all;
 
entity somador_tb is
-- empty
end somador_tb; 

architecture tb of somador_tb is

-- DUT component
component full_adder is
port(
  a: in std_logic;
  b: in std_logic;
  cin: in std_logic;
  s: out std_logic;
  cout: out std_logic);
end component;

signal a_in, b_in, c_in, s_out, c_out: std_logic;

begin

  -- Connect DUT
  DUT: full_adder port map(a_in, b_in, c_in, s_out, c_out);

  process
  begin
    a_in <= '0';
    b_in <= '0';
    c_in <= '0';
    wait for 1 ns;
    assert(s_out='0' and c_out='0') report "Fail 0/0/0" severity error;
  
    a_in <= '0';
    b_in <= '0';
    c_in <= '1';
    wait for 1 ns;
    assert(s_out='1' and c_out='0') report "Fail 0/0/1" severity error;

    a_in <= '0';
    b_in <= '1';
    c_in <= '0';
    wait for 1 ns;
    assert(s_out='1' and c_out='0') report "Fail 0/1/0" severity error;

    a_in <= '0';
    b_in <= '1';
    c_in <= '1';
    wait for 1 ns;
    assert(s_out='0' and c_out='1') report "Fail 0/1/1" severity error;
    
    a_in <= '1';
    b_in <= '0';
    c_in <= '0';
    wait for 1 ns;
    assert(s_out='1' and c_out='0') report "Fail 1/0/0" severity error;
    
    a_in <= '1';
    b_in <= '0';
    c_in <= '1';
    wait for 1 ns;
    assert(s_out='0' and c_out='1') report "Fail 1/0/1" severity error;
    
    a_in <= '1';
    b_in <= '1';
    c_in <= '0';
    wait for 1 ns;
    assert(s_out='0' and c_out='1') report "Fail 1/1/0" severity error;
    
    a_in <= '1';
    b_in <= '1';
    c_in <= '1';
    wait for 1 ns;
    assert(s_out='1' and c_out='1') report "Fail 1/1/1" severity error;

    -- Clear inputs
    a_in <= '0';
    b_in <= '0';
    c_in <= '0';

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
