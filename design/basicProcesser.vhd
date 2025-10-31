library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;



entity controlDecoderEntity is
    port(
        clk           : in  std_logic;
        reset         : in  std_logic;
        mainInput     : in  std_logic_vector(7 downto 0);
        decoderOutput : out std_logic_vector(7 downto 0);
        nextLine      : out std_logic;
        debug_state   : out std_logic_vector(3 downto 0) 
    );
end controlDecoderEntity;




architecture controlLogic of controlDecoderEntity is

    -- States
    type stateType is (
        loadOpcode,
        loadInputAddr,
        loadInputData,
        loadRegisterA,
        readRegisterA,   
        loadRegisterB,
        readRegisterB,   
        doneAndExecute
    );
    signal state : stateType := loadOpcode;

    -- Signals
    signal opcode      : std_logic_vector(7 downto 0) := (others => '0');
    signal inputA      : std_logic_vector(7 downto 0) := (others => '0');
    signal inputB      : std_logic_vector(7 downto 0) := (others => '0');
    signal ULAoutput   : std_logic_vector(7 downto 0);
    signal ULAenable   : std_logic := '0';
    signal ulaSEL      : std_logic_vector(7 downto 0);
    signal aux_addr    : unsigned(7 downto 0) := (others => '0');
    signal data        : std_logic_vector(7 downto 0) := (others => '0');
    signal regrst      : std_logic := '0';
    signal regwe       : std_logic := '0';
    signal addr        : unsigned(7 downto 0) := (others => '0');
    signal flags       : std_logic_vector(7 downto 0) := (others => '0');
    
    --------------- COMPONENTS ---------------
    
    -- ULA
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

    -- REGFILE
    component regfile is
        port(
            clk   : in std_logic;
            rst   : in std_logic;
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

    -- Mapeia o estado interno para a porta de debug
    with state select
        debug_state <= "0000" when loadOpcode,     -- 0
                       "0001" when loadInputAddr,  -- 1 (era decode)
                       "0010" when loadInputData,  -- 2
                       "0011" when loadRegisterA,  -- 3
                       "0100" when readRegisterA,  -- 4
                       "0101" when loadRegisterB,  -- 5
                       "0110" when readRegisterB,  -- 6
                       "0111" when doneAndExecute, -- 7
                       "1111" when others;         -- Erro/Indefinido

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
            rst   => regrst,
            we    => regwe,
            addr  => addr,
            data  => data,
            r0    => open,
            r1    => open,
            r2    => open,
            r3    => open,
            flags => flags
        );
        
    
    -- BUSCA E EXECUCAO
    
    process(clk, reset)
    begin
        if reset = '1' then
            state     <= loadOpcode;
            opcode    <= (others => '0');
            inputA    <= (others => '0');
            inputB    <= (others => '0');
            nextLine  <= '0';
            regwe     <= '0';
            addr      <= (others => '0');
            data      <= (others => '0');
            ulaENABLE <= '0';
            regrst    <= '1'; 

        elsif rising_edge(clk) then
            -- Valores padrão (importante para o 'handshake')
            nextLine  <= '0'; 
            ulaENABLE <= '0'; 
            regwe     <= '0'; 
            regrst    <= '0'; 

            case state is

                -----------------------------------
                when loadOpcode =>
                    -- 1. Armazena o opcode
                    opcode   <= mainInput;
                    
                   
                    nextLine <= '1';
                    
                  
                    if mainInput = "11100000" then 
                        state <= loadInputAddr;
                    else 
                        state <= loadRegisterA;
                    end if;

                    regwe <= '1';

                -----------------------------------
                when loadInputAddr =>

                    addr     <= unsigned(mainInput);
                    aux_addr <= unsigned(mainInput);
                    nextLine <= '1'; 
                    state    <= loadInputData;
                    regwe <= '1';

                -----------------------------------
                when loadInputData =>
                    
                    data     <= mainInput; 
                    regwe    <= '0'; 
                    nextLine <= '1'; 
                    
                   
                    state    <= loadOpcode;
                    
                   

                -----------------------------------
                when loadRegisterA =>
                    -- Agora mainInput tem o AddrA
                    addr     <= unsigned(mainInput);
                    aux_addr <= unsigned(mainInput); 
                    regwe    <= '0'; -- É uma leitura
                    nextLine <= '1'; -- Pede o próximo (AddrB ou sinaliza fim)
                    state    <= readRegisterA; 

                -----------------------------------
                when readRegisterA => 
                   
                    inputA <= data; 
                    
                    case opcode is
                   
                        when "00000010" | "00000011" | "00000100" | "00000101" =>
                            state <= doneAndExecute;
                   
                        when others =>
                            nextLine <= '1'; -- Pede o AddrB
                            state <= loadRegisterB;
                    end case;

                -----------------------------------
                when loadRegisterB =>
                   
                    addr     <= unsigned(mainInput);
                    regwe    <= '0'; -- É uma leitura
                    state    <= readRegisterB; 

                -----------------------------------
                when readRegisterB => 
                   
                    inputB <= data; 
                    state  <= doneAndExecute;

                -----------------------------------
                when doneAndExecute =>
                   
                    ulaSEL    <= opcode;
                    regwe     <= '1';      -- Habilita escrita (do resultado)
                    ulaENABLE <= '1';      -- Habilita ULA
                    addr      <= aux_addr; -- Endereço de escrita (RegA)
                    if opcode /= "11100000" then
                    data      <= ULAoutput; -- Dado de escrita (Resultado da ULA)
                    end if;
                    
                    nextLine <= '1';  -- Pede a *próxima instrução*
                    state    <= loadOpcode;

            end case;
        end if;
    end process;

end controlLogic;