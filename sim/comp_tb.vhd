library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_comp is
end tb_comp;

architecture sim of tb_comp is
    -- Entradas da COMP
    signal a, b : std_logic_vector(7 downto 0) := (others => '0');
    signal en   : std_logic := '0';
    signal clk  : std_logic := '0';

    -- Saída da COMP
    signal res_comp : std_logic_vector(7 downto 0) := (others => '0');

    constant clk_period : time := 10 ns;

begin
    -- Instanciação da Comp
    UUT: entity work.compEntity
        port map(
            a    => a,
            b    => b,
            en   => en,
            res_comp => res_comp,
            clk  => clk
        );

    
    process
    begin
        -- Ativa COMP
        en <= '1';
        wait for clk_period;

        -- Teste 1: a ≠ b
        a <= "00000011"; b <= "00000010";
        wait for 1 ns;
        assert (res_comp = "00000000")
            report " FAIL: esperado 00000000 (a /= b)" severity error;

        -- Teste 2: a = b
        a <= "00000011"; b <= "00000011";
        wait for 1 ns;
        assert (res_comp = "00000001")
            report " FAIL: esperado 00000001 (a = b)" severity error;

        -- Desativa COMP
        en <= '0';
        wait for clk_period;

        -- Espera pra ver as ondas
        wait for 50 ns;
        report " Teste finalizado com sucesso." severity note;
        wait;
    end process;

end sim;
