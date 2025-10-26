-- Testbench for SOMADOR
library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity testbench is
-- empty
end testbench; 

architecture tb of testbench is --TODO terminar testbench com casos de subtracao

-- DUT component
component ulaEntity is
port(
  a: IN std_logic_vector(7 downto 0);
  b: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0);
  s: IN std_logic_vector(2 downto 0);
  cout: OUT std_logic
  en: in std_logic
);
end component;

signal a_in, b_in, f_out: std_logic_vector(7 downto 0);
signal s_in, en_in: std_logic_vector(2 downto 0);
signal cin_in, cout_out: std_logic;

begin

  -- Connect DUT
  DUT: ulaEntity port map(a_in, b_in, f_out, s_in, cout_out, en_in);

  process
  begin
    a_in <= "00000010";
    b_in <= "00000011";
    s_in <= "000"
    wait for 1 ns;
    assert(f_out="00000101") report "Fail" severity error;
    assert(cout_out='0') report "Fail" severity error;
    
    a_in <= "00000001";
    b_in <= "00000011";
    s_in <= "000";
    wait for 1 ns;
    assert(f_out="00000100") report "Fail" severity error;
    assert(cout_out='0') report "Fail" severity error;
    
    a_in <= "00000111";
    b_in <= "00000111";
    s_in <= "000"
    wait for 1 ns;
    assert(f_out="00000110") report "Fail 0/0/0" severity error;
    assert(cout_out='1') report "Fail 0/0/0" severity error;
    
    -- Clear inputs
    a_in <= "00000000";
    b_in <= "00000000";
    cin_in <= '0';

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;
