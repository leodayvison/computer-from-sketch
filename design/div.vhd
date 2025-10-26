library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity div is
    port(
        a : in  std_logic_vector(7 downto 0);
        b : in  std_logic_vector(7 downto 0);
        f : out std_logic_vector(7 downto 0)
    );
end div;

architecture divARCH of div is
begin
    process(a, b)
    begin
        if b /= "00000000" then
            f <= std_logic_vector(to_unsigned(to_integer(unsigned(a)) / to_integer(unsigned(b)), 8));
        else
            f <= (others => '0');  -- divisão segura: resultado = 0
        end if;
    end process;
end divARCH;
