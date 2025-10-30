-- Imports
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

--------------------------------------------------------------

------- Main Decoder Entity:
--Note that we work with 8-bit words

entity controlDecoderEntity is
port(
	clk: IN std_logic;
    reset: IN std_logic;
    mainInput: IN std_logic_vector(7 downto 0); --Words for Instruction Queue
    decoderOutput: OUT std_logic_vector(7 downto 0) --Main output (e.g.: adder A + B)
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
signal IR, data       : std_logic_vector(7 downto 0); -- Instruction Register
signal regrst, regwe : std_logic;
signal addr            : unsigned(2 downto 0);
signal flags           : std_logic_vector(1 downto 0);



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
    addr  : IN unsigned(2 downto 0); --Choose the register
    data  : INOUT std_logic_vector(7 downto 0);
    
    r0    : INOUT std_logic_vector(7 downto 0); -- endereco 000
    r1    : INOUT std_logic_vector(7 downto 0); -- endereco 001
    r2    : INOUT std_logic_vector(7 downto 0); -- endereco 010
    r3    : INOUT std_logic_vector(7 downto 0); -- endereco 011
    flags : INOUT std_logic_vector(2 downto 0)
    -- FLAGS: zero (2), overflow (1), carry (0)
);
end component;



--------------- SIGNALS ---------------
--Decoder signals:
signal opcode    : std_logic_vector(7 downto 0) := (others => '0');
signal inputA    : std_logic_vector(7 downto 0) := (others => '0');
signal inputB    : std_logic_vector(7 downto 0) := (others => '0');
--Adder signals:
signal ULAoutput : std_logic_vector(7 downto 0);
signal ULAenable : std_logic;
signal ulaSEL    : std_logic_vector(2 downto 0);



--------------- COMPONENT INSTANCIATION ---------------
ULA: ulaEntity port map(
    	a    => inputA,
        b    => inputB,
        f    => ULAoutput,
        s    => ulaSEL,
        en   => ULAenable,
        clk  => clk
        z    => flags(3);
        cout => flags(2);
        n    => flags(1);
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
        	case state is
                when loadOpcode =>
                	opcode <= mainInput;
                    state <= loadInputA;
                when loadInputA =>
                	addr   <= to_unsigned(mainInput); -- coloca o endereço desejado no banco de registradores e pega o valor armazenado
                    regwe  <= '0';
                    inputA <= data;
                    state  <= loadInputB;
                when loadInputB =>
                    addr   <= to_unsigned(mainInput);
                    regwe  <= '0';
                	inputB <= data;
                    state <= doneAndExecute;
                
                when doneAndExecute =>
                	state <= loadOpcode;
    		end case;
    	end if;
    end process;
    

    
	--Opcode decoder
    process(opcode, state)
    begin
    	
        ULAenable <= '0';
        
        if state = doneAndExecute then
        	case opcode is
            	when "00000000" =>
                	ULAenable <= '1';
                when others =>
                	ula_enable <= '0';
            end case;
       	end if;        
    end process;  


	process(ULAoutput, ULAenable)
    begin
        output <= ULAoutput;
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

