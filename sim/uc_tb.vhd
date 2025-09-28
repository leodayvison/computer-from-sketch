-- testbench da unidade de controle
library IEEE;
use IEEE.std_logic_1164.all;

entity uc_tb is
	-- empty
end uc_tb;

architecture uc_tb_logic of uc_tb is
    -- DUT component
    component uc is
        port(
            entrada: in std_logic_vector(7 downto 0);
            saida: out std_logic_vector(7 downto 0)
        );
    end component;

    -- sinal vc batiza como quiser
    signal entrada, saida: std_logic_vector(7 downto 0);

    begin
        -- Connect DUT
        DUT: uc port map(entrada, saida); -- Sinais na mesma ordem que eu defini os port do meu componente

        process
        begin -- pesquisar sobre lista de sensibilidade
            entrada <= "00000000";
            wait for 1 ns;
            assert(saida="00000000") report "Fail 00000000" severity error;

            entrada <= "00000001";
            wait for 1 ns;
            assert(saida="00000001") report "Fail 00000001" severity error;

            entrada <= "11111111";
            wait for 1 ns;
            assert(saida="11111111") report "Fail 11111111" severity error;

            -- Clear inputs
            entrada <= "00000000";
            assert false report "Test done." severity note;
            wait;
        end process;
end uc_tb_logic;