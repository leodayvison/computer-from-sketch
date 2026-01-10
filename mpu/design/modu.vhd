library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity modu is
    port(
        a : in  std_logic_vector(7 downto 0);
        b : in  std_logic_vector(7 downto 0);
        f : out std_logic_vector(7 downto 0)
    );
end modu;

architecture moduARCH of modu is
begin
    process(a, b)
    begin
        if b /= "00000000" then
            f <= std_logic_vector(unsigned(a) mod unsigned(b));
        else
            f <= (others => '0');
        end if;
    end process;

end moduARCH;