-- Imports
library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

--------------------------------------------------------------

-------Main Decoder Entity:
--Note that we work with 8-bit words

entity controlDecoderEntity is
port(
	clk: IN std_logic;
    reset: IN std_logic;
    mainInput: IN std_logic_vector(7 downto 0); --Words for Instruction Queue
    output: OUT std_logic_vector(7 downto 0); --Main output (e.g.: adder A + B)
	);
end controlDecoderEntity;


--------------------------------------------------------------



-------Bank Register Entity:

entity registerBankEntity is
port(
    clk: IN std_logic;
    reset: IN std_logic; --Reset the register BANK
    WE: IN std_logic; --Choose the operator (write/read)
    address: IN unsigned(1 downto 0); --Choose the register
    data: INOUT std_logic_vector(7 downto 0);
    
    r0: INOUT std_logic_vector(7 downto 0);
    r1: INOUT std_logic_vector(7 downto 0);
    r2: INOUT std_logic_vector(7 downto 0);
    r3: INOUT std_logic_vector(7 downto 0)
    );
end registerBankEntity;


--------------------------------------------------------------

-------Main Decoder Architecture

architecture controlLogic of controlDecoderEntity is

--Instruction Queue Defined
--Here we created a non-specific type called stateType with 4 values (3 loarders and 1 execute); Then we create a status signal that starts with the status of the opcode;
type stateType is (loadOpcode, loadInputA, loadInputB, doneAndExecute)
signal state    : stateType := loadOpcode;

--Components
--ALU component:
component ula8BITS is
port(
  inputA: IN std_logic_vector(7 downto 0);
  inputB: IN std_logic_vector(7 downto 0);
  outputQ: OUT std_logic_vector(7 downto 0);
  selector: in std_logic_vector(2 downto 0);
  carryOut: OUT std_logic;
  enable: IN std_logic
    );
end component;

--Signals
--Decoder signals:
signal opcode : std_logic_vector(7 downto 0) := (others => '0');
signal inputA   : std_logic_vector(7 downto 0) := (others => '0');
signal inputB   : std_logic_vector(7 downto 0) := (others => '0');
--Adder signals:
signal ULAoutput: std_logic_vector(7 downto 0);
signal ULAenable: std_logic;
signal carry    : std_logic;
signal ulaSEL   : std_logic_vector(2 downto 0);

    
begin

--Decoder process

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
                	inputA <= mainInput;
                    state <= loadInputB;
                when loadInputB =>
                	inputB <= mainInput;
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
   
--ULA process
ULA: ulaEntity port map(
    	inputA   => inputA,
        inputB   => inputB,
        outputQ  => ULAoutput,
        selector => ulaSEL,
        carryOut => carry,
        enable   => ULAenable
);

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

