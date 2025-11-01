library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_controlDecoderEntity is
end entity tb_controlDecoderEntity;

architecture Test of tb_controlDecoderEntity is


    component controlDecoderEntity is
        port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            decoderOutput : out std_logic_vector(7 downto 0); 
            debug_state   : out std_logic_vector(4 downto 0) 
        );
    end component;

    -- 2. Sinais para conectar ao componente
    constant CLK_PERIOD : time := 10 ns;

    signal s_clk   : std_logic := '0';
    signal s_reset : std_logic := '0'; -- Usando reset ATIVO-ALTO 

    
    signal s_decoderOutput : std_logic_vector(7 downto 0);
    signal s_debug_state   : std_logic_vector(4 downto 0);

begin

    
    UUT : controlDecoderEntity
        port map (
            clk           => s_clk,
            reset         => s_reset,
            decoderOutput => s_decoderOutput,
            debug_state   => s_debug_state
        );

    
    clk_process : process
    begin
        s_clk <= '0';
        wait for CLK_PERIOD / 2;
        s_clk <= '1';
        wait for CLK_PERIOD / 2;
    end process clk_process;

    
    stimulus_process : process
    begin
        report "Iniciando Testbench do controlDecoderEntity...";
        
        -- Aplica o reset (ativo-alto)
        s_reset <= '1';
        wait for 2 * CLK_PERIOD; -- Segura o reset por 2 ciclos
        
        s_reset <= '0'; -- Libera o processador
        report "Reset liberado. Processador iniciando execução...";

        
        
        wait for 200 * CLK_PERIOD;

        report "Simulação terminada após 200 ciclos.";
        
        wait; 
        
    end process stimulus_process;

end architecture Test;