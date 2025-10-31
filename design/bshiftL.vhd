library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity bitshiftleft is
port(
  a: IN std_logic_vector(7 downto 0);
  s: OUT std_logic_vector(7 downto 0));
end bitshiftleft;


architecture rtl of bitshiftleft is
begin
  process(a) is
  begin
  	s(0) <= a(7);
    s(1) <= a(0);
    s(2) <= a(1);
    s(3) <= a(2);
    s(4) <= a(3);
    s(5) <= a(4);
    s(6) <= a(5);
    s(7) <= a(6);

  end process;
end rtl;