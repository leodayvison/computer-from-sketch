library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity bitshiftright is
port(
  a: IN std_logic_vector(7 downto 0);
  s: OUT std_logic_vector(7 downto 0));
end bitshiftright;


architecture rtl of bitshiftright is
begin
  process(a) is
  begin
  	s(0) <= a(1);
    s(1) <= a(2);
    s(2) <= a(3);
    s(3) <= a(4);
    s(4) <= a(5);
    s(5) <= a(6);
    s(6) <= a(7);
    s(7) <= a(0);
  end process;
end rtl;