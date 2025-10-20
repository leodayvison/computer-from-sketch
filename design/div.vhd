library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

-- quando for fzr a terceira questao do igor. faça a convolução de x por h2, resulltado por h1
-- falta testbench
entity mul is 
    port (
        a: in std_logic_vector(7 downto 0);
        b: in std_logic_vector(7 downto 0);
        f: out std_logic_vector(7 downto 0)
    );

end mul;

architecture mulARCH of mul is
    begin
        f <= std_logic_vector(to_unsigned((to_integer(unsigned(a)) / to_integer(unsigned(b))),8)) ;
end mulARCH;