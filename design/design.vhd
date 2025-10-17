library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;


entity ulaEntity is
port(
  a: IN std_logic_vector(7 downto 0);
  b: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0);
  s: IN std_logic_vector(2 downto 0);
  cin: IN std_logic;
  cout: OUT std_logic
  );
end ulaEntity;

architecture ulaARCH of ulaEntity is
signal carry: std_logic;

begin
    


  process(a, b, s, cin)
  begin
    case s is -- usaremos o mesmo esquema do ci 74ls382
      when "011" => -- soma
        carry <= cin;
        for n in 0 to 7 loop
          f(n) <= ((carry XOR a(n)) XOR b(n));
          carry <= ((a(n) and b(n)) or (carry and (a(n) or b(n))));
        end loop;
        cout <= carry;
      when "010" => -- A MINUS B
        carry <= '1';
        for n in 0 to 7 loop
          f(n) <= ((carry XOR a(n)) XOR (not b(n)));
          carry <= ((a(n) and (not b(n))) or (carry and (a(n) or (not b(n)))));
        end loop;
        cout <= carry;
      when "101" => --LOGIC OP: OR
     	for n in 0 to 7 loop
     		f(n) <= a(n) or b(n);
     	end loop;
      when "110" => --LOGIC OP: AND
      	for n in 0 to 7 loop
        	f(n) <= a(n) and b(n);
        end loop;
      when "100" => --LOGIC OP: XOR
      	for n in 0 to 7 loop
        	f(n) <= a(n) xor b(n);
        end loop;
    end case;
  end process;
end ulaARCH;


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


entity uc is
    port(
        entrada: in std_logic_vector (7 downto 0);
        saida: out std_logic_vector (7 downto 0)
    );
end uc;

architecture ucARCH of uc is
    begin
        ula.inst: entity work.ulaEntity



        with entrada select -- decoder
            saida <= "00000000" when "00000000",
            "00000001" when "00000001",
            "11111111" when "11111111";
    end ucARCH;




