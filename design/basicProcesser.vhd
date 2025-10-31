-- Imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all; -- suficiente, não precisa do synopsys
-- use IEEE.std_logic_textio.all; -- opcional, só se quiser -fsynopsys

--------------------------------------------------------------
-- Main Decoder Entity
--------------------------------------------------------------

entity controlDecoderEntity is
    port(
        clk           : in  std_logic;
        reset         : in  std_logic;
        mainInput     : in  std_logic_vector(7 downto 0); -- Words for Instruction Queue
        decoderOutput : out std_logic_vector(7 downto 0)
    );
end controlDecoderEntity;


---------------------------------------------------------
-- Main Decoder Architecture
---------------------------------------------------------

architecture controlLogic of controlDecoderEntity is

    -- States
    type stateType is (
        loadOpcode,
        decodeOpcode,
        loadInputAddr,
        loadInputData,
        loadRegisterA,
        loadRegisterB,
        doneAndExecute
    );
    signal state : stateType := loadOpcode;

    -- Signals
    signal opcode     : std_logic_vector(7 downto 0) := (others => '0');
    signal inputA     : std_logic_vector(7 downto 0) := (others => '0');
    signal inputB     : std_logic_vector(7 downto 0) := (others => '0');
    signal ULAoutput  : std_logic_vector(7 downto 0);
    signal ULAenable  : std_logic := '0';
    signal ulaSEL     : std_logic_vector(7 downto 0);
    signal aux_addr   : unsigned(7 downto 0) := (others => '0');
    signal IR, data   : std_logic_vector(7 downto 0) := (others => '0');
    signal regrst     : std_logic := '0';
    signal regwe      : std_logic := '0';
    signal addr       : unsigned(7 downto 0) := (others => '0');
    signal flags      : std_logic_vector(7 downto 0) := (others => '0');
    signal nextLine   : std_logic := '1';

    

    --------------- COMPONENTS ---------------

    -- ULA
    component ulaEntity is
        port(
            a     : in  std_logic_vector(7 downto 0);
            b     : in  std_logic_vector(7 downto 0);
            f     : out std_logic_vector(7 downto 0);
            s     : in  std_logic_vector(7 downto 0); -- ajustado pro mesmo tamanho do opcode
            en    : in  std_logic;
            clk   : in  std_logic;
            z     : out std_logic;
            cout  : out std_logic;
            n     : out std_logic;
            ovf   : out std_logic
        );
    end component;

    -- REGFILE
    component regfile is
        port(
            clk   : in std_logic;
            rst : in std_logic;
            we    : in std_logic;
            addr  : in unsigned(7 downto 0);
            data  : inout std_logic_vector(7 downto 0);
            r0    : inout std_logic_vector(7 downto 0);
            r1    : inout std_logic_vector(7 downto 0);
            r2    : inout std_logic_vector(7 downto 0);
            r3    : inout std_logic_vector(7 downto 0);
            flags : inout std_logic_vector(7 downto 0)
        );
    end component;

begin

    --------------- COMPONENT INSTANCIATION ---------------
    ULA: ulaEntity
        port map(
            a    => inputA,
            b    => inputB,
            f    => ULAoutput,
            s    => ulaSEL,
            en   => ULAenable,
            clk  => clk,
            z    => flags(3),
            cout => flags(2),
            n    => flags(1),
            ovf  => flags(0)
        );

    REGBANK: regfile
        port map(
            clk   => clk,
            rst => regrst,
            we    => regwe,
            addr  => addr,
            data  => data,
            r0    => open,
            r1    => open,
            r2    => open,
            r3    => open,
            flags => flags
        );

    


    
    -- BSUCA E EXECUCAO
    
    process(clk, reset)
    variable v_state     : stateType;
    variable v_opcode    : std_logic_vector(7 downto 0);
    variable v_aux_addr  : unsigned(7 downto 0);
    variable v_addr      : unsigned(7 downto 0);
    variable v_data      : std_logic_vector(7 downto 0);
    variable v_inputA    : std_logic_vector(7 downto 0);
    variable v_inputB    : std_logic_vector(7 downto 0);
begin
    if reset = '1' then
        -- Inicializa variáveis
        v_state    := loadOpcode;
        v_opcode   := (others => '0');
        v_aux_addr := (others => '0');
        v_addr     := (others => '0');
        v_data     := (others => '0');
        v_inputA   := (others => '0');
        v_inputB   := (others => '0');
        nextLine   <= '0';
        regwe      <= '0';
        ulaENABLE  <= '0';

    elsif rising_edge(clk) then
        -- Atualiza variáveis a partir de sinais atuais (se necessário)
        v_state    := state;       -- sinal atual para controle
        v_opcode   := opcode;
        v_aux_addr := aux_addr;
        v_addr     := addr;
        v_data     := data;
        v_inputA   := inputA;
        v_inputB   := inputB;

        -- FSM usando variáveis
        case v_state is

            -- Leitura do opcode
            when loadOpcode =>
                v_opcode := mainInput;
                nextLine <= '1';
                v_state  := decodeOpcode;

            -- Decodificação do opcode
            when decodeOpcode =>
                if v_opcode = "11100000" then
                    v_state := loadInputAddr;
                else
                    v_state := loadRegisterA;
                end if;

            -- Leitura do endereço para LOAD
            when loadInputAddr =>
                v_addr     := unsigned(mainInput);
                v_aux_addr := unsigned(mainInput);
                regwe      <= '1';
                nextLine   <= '1';
                v_state    := loadInputData;

            -- Leitura do dado para LOAD
            when loadInputData =>
                v_data   := mainInput;
                nextLine <= '1';
                v_state  := doneAndExecute;

            -- Leitura do registrador A
            when loadRegisterA =>
                v_addr     := unsigned(mainInput);
                v_aux_addr := unsigned(mainInput);
                regwe      <= '0';
                v_inputA   := v_data;
                nextLine   <= '1';

                case v_opcode is
                    when "00000010" | "00000011" | "00000100" | "00000101" =>
                        v_state := doneAndExecute;
                    when others =>
                        v_state := loadRegisterB;
                end case;

            -- Leitura do registrador B
            when loadRegisterB =>
                v_addr     := unsigned(mainInput);
                regwe      <= '0';
                v_inputB   := v_data;
                nextLine   <= '1';
                v_state    := doneAndExecute;

            -- Execução
            when doneAndExecute =>
                ulaSEL    <= v_opcode;
                regwe     <= '1';
                ulaENABLE <= '1';
                v_addr    := v_aux_addr;
                v_data    := ULAoutput;
                nextLine  <= '1';
                v_state   := loadOpcode;

        end case;

        -- Atualiza sinais a partir das variáveis
        state    <= v_state;
        opcode   <= v_opcode;
        aux_addr <= v_aux_addr;
        addr     <= v_addr;
        data     <= v_data;
        inputA   <= v_inputA;
        inputB   <= v_inputB;
end if;
end process;


end controlLogic;
