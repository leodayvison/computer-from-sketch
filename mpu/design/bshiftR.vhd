library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity bitshiftright is
port(
  a: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0));
end bitshiftright;


architecture rtl of bitshiftright is
begin
  process(a) is
  begin
  	f(0) <= a(1);
    f(1) <= a(2);
    f(2) <= a(3);
    f(3) <= a(4);
    f(4) <= a(5);
    f(5) <= a(6);
    f(6) <= a(7);
    f(7) <= a(0);
  end process;
end rtl;