library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity sum is
    port(a: in std_logic_vector(7 downto 0);
         b: in std_logic_vector(7 downto 0);
         f: out std_logic_vector(7 downto 0);
         cin: in std_logic;
         cout: out std_logic
         );
end sum;

architecture sumARCH of sum is
    signal carry: std_logic_vector(8 downto 0);

    begin
        carry(0) <= cin;
        for n in 0 to 7 loop
            f(n) <= ((carry(n) XOR a(n)) XOR b(n));
            carry(n+1) <= ((a(n) and b(n)) or (carry(n) and (a(n) or b(n))));
        end loop;
    cout <= carry(8);
end sumARCH;