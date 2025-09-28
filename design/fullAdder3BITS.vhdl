library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity somadorEntity is
port(
  a: IN std_logic_vector(2 downto 0);
  b: IN std_logic_vector(2 downto 0);
  q: OUT std_logic_vector(2 downto 0);
  cin: IN std_logic;
  cout: OUT std_logic);
end somadorEntity;

architecture somadorARCH of somadorEntity is
begin
  process(a, b, cin)
  	variable carry: std_logic;
  begin
  	carry := cin;
  	for n in 0 to 2 loop
    	q(n) <= ((carry XOR a(n)) XOR b(n));
    	carry := ((a(n) and b(n)) or (carry and (a(n) or b(n))));
    end loop;
    cout <= carry;
  end process;
end somadorARCH;

