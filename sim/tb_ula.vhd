library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ula is
end tb_ula;

architecture sim of tb_ula is
    -- Entradas da ULA
    signal a, b : std_logic_vector(7 downto 0) := (others => '1');
    signal s    : std_logic_vector(2 downto 0) := (others => '0');
    signal en   : std_logic := '0';
    signal clk  : std_logic := '0';

    -- Saídas da ULA
    signal f    : std_logic_vector(7 downto 0) := (others => '0');
    signal cout : std_logic;

    constant clk_period : time := 10 ns;

begin
    -- Instanciação da ULA
    UUT: entity work.ulaEntity
        port map(
            a    => a,
            b    => b,
            f    => f,
            s    => s,
            cout => cout,
            en   => en,
            clk  => clk
        );

    -- Clock
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        -- Ativa ULA
        en <= '1';
        wait until rising_edge(clk);

        -- Test SUM
        a <= "00000001"; b <= "00000101"; s <= "000";  -- 3+5
        wait for 1 ns;
        wait until rising_edge(clk);
        wait on f;
        assert (f="00000110") report "Fail sum" severity error;

        -- Test SUB
        a <= "00001010"; b <= "00000101"; s <= "001";  -- 10-5
        wait until rising_edge(clk);
        wait on f;
        assert (f="00000101") report "Fail sub" severity error;

        -- Test MUL
        a <= "00000110"; b <= "00000101"; s <= "010";  -- 6*5
        wait until rising_edge(clk);
        wait on f;
        assert (f="00011110") report "Fail mul" severity error;


       

        -- Test XOR
        a <= "10101010"; b <= "11001100"; s <= "100";
        wait until rising_edge(clk);

        -- Test OR
        s <= "101";
        wait until rising_edge(clk);

        -- Test AND
        s <= "110";
        wait until rising_edge(clk);

        -- Desativa ULA
        en <= '0';
        a <= (others => '0');
        s <= (others => '0');
        wait until rising_edge(clk);

        -- Termina simulação
        wait;
    end process;

end sim;
