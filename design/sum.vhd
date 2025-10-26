library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sum is
    port(
        a    : in  std_logic_vector(7 downto 0);
        b    : in  std_logic_vector(7 downto 0);
        f    : out std_logic_vector(7 downto 0);
        cin  : in  std_logic;
        cout : out std_logic
    );
end sum;

architecture sumARCH of sum is
begin
    process(a, b, cin)
        variable carry_v: std_logic_vector(8 downto 0);
    begin
        carry_v(0) := cin;

        
        for n in 0 to 7 loop
        
            f(n) <= carry_v(n) xor a(n) xor b(n);
            
        
        
            carry_v(n+1) := (a(n) and b(n)) or (carry_v(n) and (a(n) xor b(n)));
        end loop;

        
        cout <= carry_v(8);
    end process;
end sumARCH;