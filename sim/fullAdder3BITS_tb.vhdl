-- Testbench for SOMADOR
library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

-- DUT component
component somadorEntity is
port(
  a: IN std_logic_vector(2 downto 0);
  b: IN std_logic_vector(2 downto 0);
  q: OUT std_logic_vector(2 downto 0);
  cin: IN std_logic;
  cout: OUT std_logic);
end component;

signal a_in, b_in, q_out: std_logic_vector(2 downto 0);
signal cin_in, cout_out: std_logic;

begin

  -- Connect DUT
  DUT: somadorEntity port map(a_in, b_in, q_out, cin_in, cout_out);

  process
  begin
    a_in <= "010";
    b_in <= "011";
    cin_in <= '0';
    wait for 1 ns;
    assert(q_out="101") report "Fail" severity error;
    assert(cout_out='0') report "Fail" severity error;
    
    a_in <= "001";
    b_in <= "011";
    cin_in <= '0';
    wait for 1 ns;
    assert(q_out="100") report "Fail" severity error;
    assert(cout_out='0') report "Fail" severity error;
    
    a_in <= "111";
    b_in <= "111";
    cin_in <= '0';
    wait for 1 ns;
    assert(q_out="110") report "Fail 0/0/0" severity error;
    assert(cout_out='1') report "Fail 0/0/0" severity error;
    
    -- Clear inputs
    a_in <= "000";
    b_in <= "000";
    cin_in <= '0';

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
