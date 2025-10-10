library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity ulaEntity is
port(
  a: IN std_logic_vector(7 downto 0);
  b: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0);
  s: IN std_logic_vector(2 downto 0);
  cin: IN std_logic;
  cout: OUT std_logic
  );
end ulaEntity;

architecture ulaARCH of ulaEntity is
signal carry: std_logic;

begin
  process(a, b, s, cin)
  begin
    case s is -- usaremos o mesmo esquema do ci 74ls382
      when "011" => -- soma
        carry <= cin;
        for n in 0 to 7 loop
          f(n) <= ((carry XOR a(n)) XOR b(n));
          carry <= ((a(n) and b(n)) or (carry and (a(n) or b(n))));
        end loop;
        cout <= carry;
      when "010" => -- A MINUS B
        carry <= '1';
        for n in 0 to 7 loop
          f(n) <= ((carry XOR a(n)) XOR (not b(n)));
          carry <= ((a(n) and (not b(n))) or (carry and (a(n) or (not b(n)))));
        end loop;
        cout <= carry;
      when "101" => --LOGIC OP: OR
     	for n in 0 to 7 loop
     		f(n) <= a(n) or b(n);
     	end loop;
      when "110" => --LOGIC OP: AND
      	for n in 0 to 7 loop
        	f(n) <= a(n) and b(n);
        end loop;
      when "100" => --LOGIC OP: XOR
      	for n in 0 to 7 loop
        	f(n) <= a(n) xor b(n);
        end loop;
    end case;
  end process;
end ulaARCH;

