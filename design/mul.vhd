library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

-- quando for fzr a terceira questao do igor. faça a convolução de x por h2, resulltado por h1
-- falta testbench
entity mul is 
    port (
        a: in std_logic_vector(7 downto 0);
        b: in std_logic_vector(7 downto 0);
        tempf: out std_logic_vector(15 downto 0);
        f: out std_logic_vector(7 downto 0);
        overflow_flag: out std_logic
    );

end mul;

architecture mulARCH of mul is
    begin
        tempf <= std_logic_vector(to_signed((to_integer(signed(a)) * to_integer(signed(b))),16));
        f <= tempf(7 downto 0);

        -- dá overflow se os bits alem do oitavo sao diferentes do oitavo
        overflow_flag <= '1' when full_result(15 downto 8) /= (others => full_result(7)) else '0';

end mulARCH;