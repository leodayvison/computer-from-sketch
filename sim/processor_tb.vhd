library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_controlDecoderEntity is
end tb_controlDecoderEntity;

architecture sim of tb_controlDecoderEntity is
    
    -- Função de conversão corrigida
    function std_logic_vector_to_string(v : std_logic_vector) return string is
        variable s : string(1 to v'length);
    begin
        for i in v'range loop
            if v(i) = '1' then
                s(v'length - i) := '1';
            else
                s(v'length - i) := '0'; -- Corrigido de 'tlength' para 'length'
            end if;
        end loop;
        return s;
    end function;

    ----------------------------------------------------------------
    -- Sinais do DUT (Device Under Test)
    ----------------------------------------------------------------
    signal clk            : std_logic := '0';
    signal reset          : std_logic := '0';
    signal mainInput      : std_logic_vector(7 downto 0) := (others => '0');
    signal decoderOutput  : std_logic_vector(7 downto 0);
    signal nextLine_tb    : std_logic;
    signal state_from_dut : std_logic_vector(3 downto 0); 

    ----------------------------------------------------------------
    -- Arquivo de instruções
    ----------------------------------------------------------------
    file instruction_file : text open read_mode is "instructions.txt";
    
    constant clk_period : time := 10 ns;

begin

    ----------------------------------------------------------------
    -- Instancia o processador (DUT)
    ----------------------------------------------------------------
    DUT: entity work.controlDecoderEntity
        port map(
            clk           => clk,
            reset         => reset,
            mainInput     => mainInput,
            decoderOutput => decoderOutput,
            nextLine      => nextLine_tb,
            debug_state   => state_from_dut
        );

    ----------------------------------------------------------------
    -- Gera o clock
    ----------------------------------------------------------------
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    ----------------------------------------------------------------
    -- Reset inicial
    ----------------------------------------------------------------
    reset_process: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;
    end process;

    ----------------------------------------------------------------
    -- Leitor de arquivo de instruções (<<< PROCESSO CORRIGIDO)
    ----------------------------------------------------------------
    reader_process: process
        variable line_buffer : line;
        variable read_data   : string(1 to 8);
        variable bit_vector  : std_logic_vector(7 downto 0);
    begin
        -- 1. Espera o reset terminar (o reset dura 20ns).
        wait for 20 ns; 
        
        -- 2. Lê a *primeira* linha e a coloca no barramento IMEDIATAMENTE.
        --    Isso acontece @20ns, *antes* do primeiro rising_edge (25ns).
        if not endfile(instruction_file) then
            readline(instruction_file, line_buffer);
            read(line_buffer, read_data);

            -- converte string binária para std_logic_vector
            for i in 1 to 8 loop
                if read_data(i) = '0' then
                    bit_vector(8 - i) := '0';
                else
                    bit_vector(8 - i) := '1';
                end if;
            end loop;
            
            mainInput <= bit_vector; -- Coloca 'E0' no barramento
        end if;

        -- 3. Agora começa o loop síncrono principal
        while not endfile(instruction_file) loop
            
            -- 4. Espera o DUT sinalizar que consumiu o dado (nextLine_tb = '1')
            wait until nextLine_tb = '1';

            -- 5. ASSIM que o DUT sinaliza '1', ele já leu o dado atual.
            --    Ele espera o *próximo* dado no *próximo* ciclo de clock.
            --    Temos que ler o próximo dado do arquivo e colocá-lo
            --    no barramento IMEDIATAMENTE.

            -- 6. Lê a *próxima* linha do arquivo
            if not endfile(instruction_file) then
                readline(instruction_file, line_buffer);
                read(line_buffer, read_data);

                -- (conversão...)
                for i in 1 to 8 loop
                    if read_data(i) = '0' then
                        bit_vector(8 - i) := '0';
                    else
                        bit_vector(8 - i) := '1';
                    end if;
                end loop;
                
                -- 7. Coloca o *próximo* dado no barramento
                mainInput <= bit_vector;
            else
                exit; -- Sai do loop se o arquivo acabou
            end if;

            -- 8. O DUT vai ler este novo dado no próximo rising_edge.
            --    No início daquele ciclo, ele vai baixar 'nextLine' para '0'.
            --    Devemos esperar por isso para evitar um loop infinito
            --    neste 'wait until nextLine_tb = '1''.
            wait until nextLine_tb = '0';
            
        end loop;
        
        report "Fim do arquivo instructions.txt." severity note;
        -- Limpa o input para 'U' para vermos que acabou
        mainInput <= (others => 'U');
        wait; -- Fim da simulação
    end process;

    ----------------------------------------------------------------
    -- Monitor de saída (mostra no console)
    ----------------------------------------------------------------
    monitor_process: process(clk)
    begin
        if rising_edge(clk) and reset = '0' then
            report "Tempo=" & time'image(now) &
                   " | State=" & std_logic_vector_to_string(state_from_dut) &
                   " | mainInput=" & std_logic_vector_to_string(mainInput) &
                   " | nextLine=" & std_logic'image(nextLine_tb) &
                   " | decoderOutput=" & std_logic_vector_to_string(decoderOutput);
        end if;
    end process;

end sim;