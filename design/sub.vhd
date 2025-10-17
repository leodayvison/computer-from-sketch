library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity sub is
    port(a: in std_logic_vector(7 downto 0);
         b: in std_logic_vector(7 downto 0);
         f: out std_logic_vector(7 downto 0);
         cin: in std_logic;
         );
end sub;

architecture subARCH of sub is
signal b_invertido, saida_sum: std_logic_vector(7 downto 0);
signal complemento: std_logic;

    component sum
    port(
        a: in std_logic_vector(7 downto 0);
        b: in std_logic_vector(7 downto 0);
        f: out std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic);
    end component sum;

    begin
        complemento <= '1';
        b_invertido <= not b;
        U1: sum port map(a, b, saida_sum, complemento, cout);
        f <= saida_sum;

end subARCH;