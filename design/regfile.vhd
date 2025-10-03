library IEEE;
use IEEE.std_logic_1164.all;
IEEE.numeric_std.all; 
-- NOTAS DE AULA:
-- Barramento data: ramo principal do banco de registradores
-- barramento q_i: barramento de cada registrador do banco
-- FIM DAS NOTAS DE AULA

-- registradores
entity regfile is
    port(
        clk: IN std_logic; -- quem vai gerar o clock é o testbench
        rst: IN std_logic;
        we: IN std_logic;
        addr: IN unsigned(1 downto 0); -- vai ser a quantidade de registradores do banco
        data: INOUT std_logic_vector(7 downto 0); -- barramento principal ligado a todos os registradores
        q_0: INOUT std_logic_vector(7 downto 0); -- registrador 0
        q_1: INOUT std_logic_vector(7 downto 0); -- registrador 1
        q_2: INOUT std_logic_vector(7 downto 0); -- ...
        q_3: INOUT std_logic_vector(7 downto 0)
    );
end regfile;

architecture reg of regfile is
begin
    type reg_array is array(0 to 3) of std_logic_vector(7 downto 0); -- vetor (banco) de vetores (registradores)
    signal regs  : reg_array := (others=>(others=>'0')); -- zera todos os registradores

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                regs <= (others=>(others=>'0'));
            elsif we = '1' then
                regs(to_integer(addr)) <= data; --TODO Codigo incompleto
            end if;
        end if;
    end process;
end reg;