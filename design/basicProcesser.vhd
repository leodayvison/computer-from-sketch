-- Imports
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

--------------------------------------------------------------

------- Main Decoder Entity:
--Note that we work with 8-bit words

entity controlDecoderEntity is
port(
	clk           : IN std_logic;
    reset         : IN std_logic;
    mainInput     : IN std_logic_vector(7 downto 0); --Words for Instruction Queue
    decoderOutput : OUT std_logic_vector(7 downto 0) --Main output (e.g.: adder A + B)
    --nextLine      : OUT std_logic;
	);
end controlDecoderEntity;


---------------------------------------------------------
--------------- Main Decoder Architecture ---------------
---------------------------------------------------------

architecture controlLogic of controlDecoderEntity is

--Instruction Queue Defined
--Here we created a non-specific type called stateType with 4 values (3 loarders and 1 execute); Then we create a status signal that starts with the status of the opcode;
type stateType is (loadOpcode, loadInputA, loadInputB, doneAndExecute)
signal state    : stateType := loadOpcode;

--------------- SIGNALS ---------------
--Decoder signals:
signal opcode    : std_logic_vector(7 downto 0) := (others => '0');
signal inputA    : std_logic_vector(7 downto 0) := (others => '0');
signal inputB    : std_logic_vector(7 downto 0) := (others => '0');
--Adder signals:
signal ULAoutput : std_logic_vector(7 downto 0);
signal ULAenable : std_logic;
signal ulaSEL    : std_logic_vector(7 downto 0);
--Other signals:
signal aux_addr : unsigned(7 downto 0); -- guarda o primeiro endereço pra guardar o resultado da operação
signal IR, data       : std_logic_vector(7 downto 0); -- Instruction Register
signal regrst, regwe : std_logic;
signal addr            : unsigned(7 downto 0);
signal flags           : std_logic_vector(1 downto 0);

-- signal mainInput : std_logic_vector(7 downto 0) :=  (others => '0'); -- INSTRUCTION QUEUE

--------------- COMPONENTS ---------------

--ALU component:
component ulaEntity is
port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    f    : out std_logic_vector(7 downto 0);
    s    : in  std_logic_vector(2 downto 0);
    cout : out std_logic;
    en   : in  std_logic;
    clk  : in  std_logic
    );
end component;

-- REGFILE component:
component regfile is
port(
    clk   : IN std_logic;
    reset : IN std_logic; --Reset the register BANK
    we    : IN std_logic; --Choose the operator (write/read)
    addr  : IN unsigned(7 downto 0); --Choose the register
    data  : INOUT std_logic_vector(7 downto 0);
    
    r0    : INOUT std_logic_vector(7 downto 0); -- endereco 000
    r1    : INOUT std_logic_vector(7 downto 0); -- endereco 001
    r2    : INOUT std_logic_vector(7 downto 0); -- endereco 010
    r3    : INOUT std_logic_vector(7 downto 0); -- endereco 011
    flags : INOUT std_logic_vector(7 downto 0)
    -- FLAGS: zero (2), overflow (1), carry (0)
);
end component;

--------------- COMPONENT INSTANCIATION ---------------
ULA: ulaEntity port map(
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

REGBANK: regfile port map(
    clk => clk,
    reset => regrst,
    we    => regwe,
    addr  => addr,
    data  => data,
    r0    => open,
    r1    => open,
    r2    => open,
    r3    => open,
    flags => flags
);

--------------- READER TXT PROCESS -------------------------------------

file queueFile : text open read_mode is "queue.txt"; -- ABRINDO O ARQUIVO DA FILA
--signal fileReady : boolean := false; -- FILA NAO TERMINOU (NAO É MAIS NECESSARIO)
signal nextLine : std_logic := 1;

instructionLoader : process(nextLine)
        variable inline : line;
        variable c : character;
        variable temporaryInput: std_logic_vector(7 downto 0);

    begin

        wait until nextLine = '1';

        if not endfile(queueFile) then
            --while not endfile(queueFile) loop
            readline(queueFile, inline);
                
            for bit in 0 to 7 loop
                read(inline, c);
                if c = '1' then
                    temporaryInput(7 - bit) := '1';
                else
                    temporaryInput(7 - bit) := '0';
                end if;
            end loop;

            mainInput <= temporaryInput;

                wait until rising_edge(nextLine);
        end if;

        wait for 1 ns;
    end process;



--------------- BEGIN ---------------
begin

--------------- PROCESSES ---------------

	--Insctruction Queue Reader
	process(clk, reset, mainInput)
    
    begin  
    	--If we would like to reset the Instruction Queue
    	if reset = '1' then 
        	state <= loadOpcode;
            opcode <= (others => '0');
            inputA   <= (others => '0');
            inputB   <= (others => '0');
        
        --here we read the instruction queue according to each operation
    	elsif rising_edge(clk) then 
            nextLine <= '0';   
        	case state is
                when loadOpcode =>
                    opcode <= mainInput;
                    nextLine <= '1';
                    
                    case opcode is
                        when "11100000" => --LOAD
                            state <= loadInputAddr;
                        when others => 
                            state <= loadRegisterA;
                    end case;

                when loadInputAddr =>
                    nextLine <= '0';
                    addr <= unsigned(mainInput);
                    aux_addr <= unsigned(mainInput);
                    regwe <= '1';
                    nextLine <= '1';

                    state <= loadInputData;
                
                when loadInputData =>
                    nextLine <= '0';
                    data <= mainInput;
                    nextLine <='1';

                    state <= doneAndExecute;

                when loadRegisterA =>
                    addr   <= unsigned(mainInput); -- coloca o endereço desejado no banco de registradores e pega o valor armazenado
                    aux_addr <= unsigned(mainInput);
                    regwe  <= '0';
                    inputA <= data;
                    nextLine <= '1';
                    nextLine <= '0';

                    case opcode is
                        when "00000010" =>
                            state <= doneAndExecute;
                        when "00000011" =>
                            state <= doneAndExecute;
                        when "00000100" =>
                            state <= doneAndExecute;
                        when "00000101" =>
                            state <= doneAndExecute;
                        when others =>
                            state <= loadRegisterB;
                    end case;

                when loadRegisterB =>
                    addr   <= unsigned(mainInput);
                    regwe  <= '0';
                    inputB <= data;
                    nextLine <= '1';
                    state <= doneAndExecute;
                            
                when doneAndExecute =>
                    ulaSEL <= opcode;
                    regwe <= '1';
                    ulaENABLE <= '1';
                    addr <= aux_addr;
                    data <= ULAoutput;
                    nextLine <= '1';
                    state <= loadOpcode;
                
            end case;
    	end if;
    end process;
    





end controlLogic;


--Explicando o que o código faz, resumidamente: 
--O código tem 3 entidades/componentes: MAIN DECODER, ULA, REGISTERBANK
--Atualmente o REGISTER BANK >>NÃO<< possui função, só integrei a ULA e o MAIN DECODER
--a ULA só possui ADDER, recebe A e soma com B, arquitetura padrão
--a arquitetura do MAIN DECODER é a principal e talvez a mais complicada
--Estou trabalhando com arquitetura Von-Neuman: Há apenas um barramento (MAIN INPUT) para instruções e dados
--A arquitetura do MAIN DECODER começa definindo um type estado para sabermos o que a fila está mandando: dado ou instrução
--O processo "Instruction Queue Reader" lê a fila de instruções a partir desse type state: e.g.: Se for um opcode ele diz q é opcode e salva no sinal opcode
--O pipline: busca decodificação execucação é completo
--O processo "Opcode Decoder" ativa o sinal do componente (e.g.: adder) do opcode
--No caso em que o opocode for para a ULA/Adder o process da ULA faz a soma =D

