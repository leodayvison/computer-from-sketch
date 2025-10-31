library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_InstructionROM is
    
end entity tb_InstructionROM;

architecture Test of tb_InstructionROM is

    component InstructionROM is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic; -- Reset (ativo-baixo)
            addr     : in  std_logic_vector(6 downto 0);
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;

    signal s_clk  : std_logic := '0';
    signal s_rst  : std_logic := '0'; -- reset (ativo-baixo)
    signal s_addr : std_logic_vector(6 downto 0) := (others => '0');


    signal s_data_out : std_logic_vector(7 downto 0);

begin

    UUT : InstructionROM
        port map (
            clk      => s_clk,
            rst      => s_rst,
            addr     => s_addr,
            data_out => s_data_out
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
        report "Iniciando Testbench da InstructionROM...";
        
        s_rst <= '0'; -- reset (ativo-baixo)
        wait for 1 ns; 
        
        s_rst <= '1'; -- Libera o reset
        
        wait until rising_edge(s_clk);
        report "iniciando varredura de endereços...";

        for i in 0 to 127 loop
            
            s_addr <= std_logic_vector(to_unsigned(i, s_addr'length));
            
            wait until rising_edge(s_clk);
            
            
        end loop;

        report "Leitura de todos os 128 endereços concluida.";
        report "Simulação terminada.";
        
        wait;
        
    end process stimulus_process;

end architecture Test;