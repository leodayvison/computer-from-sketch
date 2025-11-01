library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all; 

entity controlDecoderEntity is
    port(
        clk           : in  std_logic;
        reset         : in  std_logic;
        decoderOutput : out std_logic_vector(7 downto 0); 
        debug_state   : out std_logic_vector(4 downto 0) 
    );
end controlDecoderEntity;


architecture controlLogic of controlDecoderEntity is

    ----------------------------------------------------
    -- 1. LÓGICA DA ROM IMPORTADA (do InstructionROM.vhd)
    ----------------------------------------------------
    constant ROM_DEPTH : integer := 128; 
    constant ROM_WIDTH : integer := 8;   
    
    type rom_type is array (0 to ROM_DEPTH - 1) of std_logic_vector(ROM_WIDTH - 1 downto 0);

    -- Função para inicializar a ROM a partir do arquivo
    impure function init_rom_from_file(filename : string) return rom_type is
        file bin_file : TEXT;
        variable file_line : line;
        variable rom_data  : rom_type;
        variable temp_bv   : std_logic_vector(ROM_WIDTH - 1 downto 0);
    begin
        file_open(bin_file, filename, READ_MODE);
        for i in 0 to ROM_DEPTH - 1 loop
            if not endfile(bin_file) then
                readline(bin_file, file_line);
                read(file_line, temp_bv); 
                rom_data(i) := temp_bv;
            else
                rom_data(i) := (others => '0'); -- Preenche o resto com '0'
            end if;   
        end loop;
        file_close(bin_file);
        return rom_data;
    end function init_rom_from_file;

    -- Instancia a ROM interna lendo o arquivo
    constant ROM : rom_type := init_rom_from_file("../sim/instructions.txt");

    ----------------------------------------------------
    -- 2. SINAIS INTERNOS (antigas portas) E PC
    ----------------------------------------------------
    
    -- Program Counter (PC) interno
    signal pc : unsigned(6 downto 0) := (others => '0'); -- 7 bits = 128 posições
    
    
    signal internal_nextLine  : std_logic;
    signal internal_mainInput : std_logic_vector(7 downto 0);

    ----------------------------------------------------
    -- 3. LÓGICA DA FSM (Máquina de Estados)
    ----------------------------------------------------
    
    -- States (Renomeados para clareza: "Pede" e "Le")
    type stateType is (
        -- Ciclo 0
        pedeOpcode,
        leOpcode,
        -- Ciclo MVI
        pedeInputAddr,
        leInputAddr,
        pedeInputData,
        leInputData,
        -- Ciclo ULA
        pedeRegisterA,
        leRegisterA,
        pedeRegisterB,
        leRegisterB,
        executeULA,
        waitULA,
        writebackULA
    );
    signal state : stateType := pedeOpcode; -- Estado inicial

    -- Banco de Registradores Local
    type reg_array is array(0 to 4) of std_logic_vector(7 downto 0);
    signal local_regs : reg_array := (others => (others => '0'));

    -- Signals da ULA e FSM
    signal opcode      : std_logic_vector(7 downto 0) := (others => '0');
    signal inputA      : std_logic_vector(7 downto 0) := (others => '0');
    signal inputB      : std_logic_vector(7 downto 0) := (others => '0');
    signal ULAoutput   : std_logic_vector(7 downto 0);
    signal ULAenable   : std_logic := '0';
    signal ulaSEL      : std_logic_vector(7 downto 0);
    signal aux_addr    : unsigned(7 downto 0) := (others => '0');
    signal ula_flags   : std_logic_vector(7 downto 0) := (others => '0');
    
    --------------- COMPONENTS ---------------
    
    component ulaEntity is
        port(
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            f    : out std_logic_vector(7 downto 0);
            s    : in  std_logic_vector(7 downto 0); 
            en   : in  std_logic;
            clk  : in  std_logic;
            z    : out std_logic;
            cout : out std_logic;
            n    : out std_logic;
            ovf  : out std_logic
        );
    end component;

begin

    -- Mapeia o estado interno para a porta de debug (sem alteração)
    with state select
        debug_state <= "00000" when pedeOpcode,
                       "00001" when leOpcode,
                       "00010" when pedeInputAddr,
                       "00011" when leInputAddr,
                       "00100" when pedeInputData,
                       "00101" when leInputData,
                       "00110" when pedeRegisterA,
                       "00111" when leRegisterA,
                       "01000" when pedeRegisterB,
                       "01001" when leRegisterB,
                       "01010" when executeULA,
                       "01011" when waitULA,
                       "01100" when writebackULA,
                       "01101" when others;

    --------------- COMPONENT INSTANCIATION ---------------
    ULA: ulaEntity
        port map(
            a    => inputA,
            b    => inputB,
            f    => ULAoutput,
            s    => ulaSEL,
            en   => ULAenable,
            clk  => clk,
            z    => ula_flags(3),
            cout => ula_flags(2),
            n    => ula_flags(1),
            ovf  => ula_flags(0)
        );

    ----------------------------------------------------
    -- 4. NOVOS PROCESSOS PARA PC E LEITURA DA ROM
    ----------------------------------------------------

    pc_process: process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if internal_nextLine = '1' then
                pc <= pc + 1;
            end if;
        end if;
    end process;

    
    rom_read_process: process(clk, reset)
    begin
        if reset = '1' then -- Assumindo reset ativo-alto
            internal_mainInput <= (others => '0');
        elsif rising_edge(clk) then
            internal_mainInput <= ROM(to_integer(pc));
        end if;
    end process;


    ----------------------------------------------------
    -- 5. PROCESSO DA FSM MODIFICADO
    ----------------------------------------------------
    
    
    fsm_process: process(clk, reset)
    begin
        if reset = '1' then
            state     <= pedeOpcode; -- Estado inicial
            opcode    <= (others => '0');
            inputA    <= (others => '0');
            inputB    <= (others => '0');
            internal_nextLine <= '0'; -- Valor inicial
            ulaENABLE <= '0';
            local_regs <= (others => (others => '0')); 

        elsif rising_edge(clk) then
            -- Valores padrão (importante)
            internal_nextLine <= '0'; -- PC não incrementa por padrão
            ulaENABLE <= '0'; 

            case state is
                
                -- Ciclo 1: Pedir Opcode
                when pedeOpcode =>
                    internal_nextLine <= '1'; -- Sinaliza para o pc_process incrementar
                    state    <= leOpcode;

                -- Ciclo 2: Ler Opcode e Decodificar
                when leOpcode =>
                    opcode   <= internal_mainInput; -- Lê o dado da ROM interna
                    if internal_mainInput = "00000000" then
                        state <= pedeOpcode;
                    elsif internal_mainInput = "11100000" then -- MVI
                        state <= pedeInputAddr;
                    else -- ULA
                        state <= pedeRegisterA;
                    end if;
                
                -- Ciclo 3: Pedir Endereço
                when pedeInputAddr =>
                    internal_nextLine <= '1';
                    state    <= leInputAddr;

                -- Ciclo 4: Ler Endereço
                when leInputAddr =>
                    aux_addr <= unsigned(internal_mainInput); -- Salva o endereço
                    state    <= pedeInputData;
                
                -- Ciclo 5: Pedir Dado
                when pedeInputData =>
                    internal_nextLine <= '1';
                    state    <= leInputData;
                    
                -- Ciclo 6: Ler Dado e Escrever
                when leInputData =>
                    local_regs(to_integer(aux_addr)) <= internal_mainInput;
                    state <= pedeOpcode; -- Fim, volta ao início
                
                -- Ciclo 3: Pedir AddrA
                when pedeRegisterA =>
                    internal_nextLine <= '1';
                    state    <= leRegisterA;

                -- Ciclo 4: Ler AddrA
                when leRegisterA =>
                    aux_addr <= unsigned(internal_mainInput); -- Salva AddrA
                    inputA   <= local_regs(to_integer(unsigned(internal_mainInput)));
                    
                    case opcode is
                        -- Operações de 1 operando
                        when "00000010" | "00000011" | "00000100" | "00000101" =>
                            state <= executeULA; -- Pula para a execução
                        -- Operações de 2 operandos
                        when others =>
                            state <= pedeRegisterB; -- Continua para AddrB
                    end case;
                
                -- Ciclo 5: Pedir AddrB
                when pedeRegisterB =>
                    internal_nextLine <= '1';
                    state    <= leRegisterB;

                -- Ciclo 6: Ler AddrB
                when leRegisterB =>
                    inputB <= local_regs(to_integer(unsigned(internal_mainInput)));
                    state  <= executeULA;

                -- Ciclo 7: Executar
                when executeULA =>
                    ulaSEL    <= opcode;
                    ulaENABLE <= '1';      
                    state     <= waitULA;

                -- Ciclo 8: esperar a ULA pq ela demora mais um clock pra mandar o output
                when waitULA =>
                    state <= writebackULA;

                -- Ciclo 9: Salvar Resultado
                when writebackULA =>
                    local_regs(to_integer(aux_addr)) <= ULAoutput;
                    local_regs(4) <= ula_flags; 
                    state    <= pedeOpcode; -- Fim, volta ao início

            end case;
        end if;
    end process;

end controlLogic;