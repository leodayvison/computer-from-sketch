library IEEE;
use IEEE.std_logic_1164.all;

entity uc is
    port(
        entrada: in std_logic_vector (7 downto 0);
        saida: out std_logic_vector (7 downto 0)
    );
end uc;

architecture logica_uc of uc is
    begin
        with entrada select -- decoder
            saida <= "00000000" when "00000000",
            "00000001" when "00000001",
            "11111111" when "11111111";
    end logica_uc;