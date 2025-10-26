library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sub is
    port(
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        f   : out std_logic_vector(7 downto 0)
    );
end sub;

architecture subARCH of sub is
    -- Sinais internos para a lógica
    signal b_invertido: std_logic_vector(7 downto 0);
    signal saida_sum  : std_logic_vector(7 downto 0);
    -- O 'complemento' nem precisa ser um signal, pode ligar '1' direto

    component sum
        port(
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            f    : out std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            cout : out std_logic
        );
    end component;
    
begin
    -- Atribuição concorrente: Inverte B
    -- Isso acontece "imediatamente" quando 'b' muda.
    b_invertido <= not b;

    -- Instanciação concorrente:
    -- O 'cin' é '1' para fazer a soma (a + not(b) + 1), que é o complemento de 2.
    U1: sum port map(
        a    => a,
        b    => b_invertido,
        f    => saida_sum,
        cin  => '1',         -- Ligado direto em '1'
        cout => open
    );

    -- Atribuição concorrente: A saída 'f' é a saída do somador.
    -- Isso acontece "imediatamente" quando 'saida_sum' muda.
    f <= saida_sum;

end subARCH;