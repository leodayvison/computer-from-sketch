library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_controlDecoderEntity is
end tb_controlDecoderEntity;

architecture sim of tb_controlDecoderEntity is
    function std_logic_vector_to_string(v : std_logic_vector) return string is
        variable s : string(1 to v'length);
    begin
        for i in v'range loop
            if v(i) = '1' then
                s(v'length - i) := '1';
            else
                s(v'length - i) := '0';
            end if;
        end loop;
        return s;
    end function;

    ----------------------------------------------------------------
    -- Sinais do DUT (Device Under Test)
    ----------------------------------------------------------------
    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal mainInput     : std_logic_vector(7 downto 0) := (others => '0');
    signal decoderOutput : std_logic_vector(7 downto 0);

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
            decoderOutput => decoderOutput
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
    -- Leitor de arquivo de instruções
    ----------------------------------------------------------------
    reader_process: process
    variable line_buffer  : line;
    variable read_data    : string(1 to 8);
    variable bit_vector   : std_logic_vector(7 downto 0);
    begin
        wait for 30 ns;  -- espera o reset

        while not endfile(instruction_file) loop
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

            mainInput <= bit_vector;
            wait for clk_period;  -- envia uma instrução por ciclo
        end loop;

        wait;
    end process;

    ----------------------------------------------------------------
    -- Monitor de saída (mostra no console)
    ----------------------------------------------------------------
    monitor_process: process(clk)
    begin
        if rising_edge(clk) then
            report "Tempo=" & time'image(now) &
                   " | mainInput=" & std_logic_vector_to_string(mainInput) &
                   " | decoderOutput=" & std_logic_vector_to_string(decoderOutput);
        end if;
    end process;

end sim;
