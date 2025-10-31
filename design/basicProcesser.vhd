-- Imports
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all; 

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
begin
    if reset = '1' then
        state    <= loadOpcode;
        opcode   <= (others => '0');
        inputA   <= (others => '0');
        inputB   <= (others => '0');
        nextLine <= '0';
        regwe    <= '0';
        addr     <= (others => '0');
        data     <= (others => '0');
        ulaENABLE <= '0';

    elsif rising_edge(clk) then
        nextLine <= '0';  -- reset temporário

        case state is

            -----------------------------------
            when loadOpcode =>
                -- apenas armazena o opcode
                opcode <= mainInput;
                nextLine <= '1';
                state <= decodeOpcode;

            -----------------------------------
            when decodeOpcode =>
                -- decide o próximo estado baseado no opcode
                if opcode = "11100000" then
                    state <= loadInputAddr;
                else
                    state <= loadRegisterA;
                end if;

            -----------------------------------
            when loadInputAddr =>
                
                addr     <= unsigned(mainInput);
                aux_addr <= unsigned(mainInput);
                regwe    <= '1';
                nextLine <= '1';
                state    <= loadInputData;

            -----------------------------------
            when loadInputData =>
                data     <= mainInput;
                nextLine <= '1';
                state    <= doneAndExecute;

            -----------------------------------
            when loadRegisterA =>
                addr     <= unsigned(mainInput);
                aux_addr <= unsigned(mainInput);
                regwe    <= '0';
                inputA   <= data;
                nextLine <= '1';

                case opcode is
                    when "00000010" | "00000011" | "00000100" | "00000101" =>
                        state <= doneAndExecute;
                    when others =>
                        state <= loadRegisterB;
                end case;

            -----------------------------------
            when loadRegisterB =>
                addr     <= unsigned(mainInput);
                regwe    <= '0';
                inputB   <= data;
                nextLine <= '1';
                state    <= doneAndExecute;

            -----------------------------------
            when doneAndExecute =>
                ulaSEL    <= opcode;
                regwe     <= '1';
                ulaENABLE <= '1';
                addr      <= aux_addr;
                data      <= ULAoutput;
                nextLine  <= '1';
                state     <= loadOpcode;

        end case;
    end if;
end process;

end controlLogic;

--------------------------------------------------------------
----------------------------- ULA Entity
--------------------------------------------------------------

entity ulaEntity is
    port(
        a            : in  std_logic_vector(7 downto 0);
        b            : in  std_logic_vector(7 downto 0);
        f            : out std_logic_vector(7 downto 0);
        s            : in  std_logic_vector(7 downto 0);
        en           : in  std_logic;
        clk          : in  std_logic;
        z, cout, n, ovf : out std_logic -- flags
    );
end ulaEntity;

---------------------------------------------------------
--------------------------- ULA Architecture
---------------------------------------------------------

architecture ulaARCH of ulaEntity is
    signal carry_out: std_logic;
    signal res_sum, res_sub, res_mul, res_div, res_comp, res_inc, res_dec, res_mod, res_shl, res_shr: std_logic_vector(7 downto 0);
    signal ovf_mul: std_logic;
    signal cout_inc : std_logic;

    component sum
        port(
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            f    : out std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            cout : out std_logic
        );
    end component;

    component sub
        port(
            a   : in  std_logic_vector(7 downto 0);
            b   : in  std_logic_vector(7 downto 0);
            f   : out std_logic_vector(7 downto 0)
        );
    end component;

    component mul
        port(
            a            : in  std_logic_vector(7 downto 0);
            b            : in  std_logic_vector(7 downto 0);
            f            : out std_logic_vector(7 downto 0);
            overflow_flag: out std_logic
        );
    end component;

    component div
        port(
            a : in  std_logic_vector(7 downto 0);
            b : in  std_logic_vector(7 downto 0);
            f : out std_logic_vector(7 downto 0)
        );
    end component;

    component comp
        port(
            a          : in  std_logic_vector(7 downto 0);
            b          : in  std_logic_vector(7 downto 0);
            res_comp   : out std_logic_vector(7 downto 0)
        );
    end component;

    component modu
        port(
            a          : in  std_logic_vector(7 downto 0);
            b          : in  std_logic_vector(7 downto 0);
            f   : out std_logic_vector(7 downto 0)
        );
    end component;

    component bitshiftleft
        port(
            a : in std_logic_vector(7 downto 0);
            f : out std_logic_vector(7 downto 0)
        );
    end component;

    component bitshiftright
        port(
            a : in std_logic_vector(7 downto 0);
            f : out std_logic_vector(7 downto 0)
        );
    end component;
    

begin
    U1: sum port map(a => a, b => b, f => res_sum, cin => '0', cout => carry_out);
    U2: sub port map(a => a, b => b, f => res_sub);
    U3: mul port map(a => a, b => b, f => res_mul, overflow_flag => ovf_mul);
    U4: div port map(a => a, b => b, f => res_div);
    U5: comp port map(a => a, b => b, res_comp => res_comp);
    U6: sum port map(a => a, b => "00000001", f => res_inc, cin => '0', cout => cout_inc);
    U7: sub port map(a => a, b => "00000001", f => res_dec);
    U8: modu port map(a=> a, b=> b, f => res_mod);
    U9: bitshiftleft port map(a => a, f => res_shl);
    U10: bitshiftright port map(a => a, f => res_shr);



    process(clk)
    variable tempres : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk) then
            if en = '1' then
                case s is
                    when "00010000" => 
                        tempres := res_sum; 
                        if ((a(7) = b(7)) and (res_sum(7) /= a(7))) then
                          ovf <= '1';
                        else
                            ovf <= '0';
                        end if;
                    when "00100000" => 
                        tempres := res_sub; 
                        if ((a(7) /= b(7)) and (res_sub(7) /= a(7))) then
                            ovf <= '1';
                        else
                            ovf <= '0';
                        end if;
                    when "00110000" => 
                        tempres := res_mul; 
                        ovf <= ovf_mul;
                    when "01000000" => 
                        tempres := res_div;
                        ovf <= '0';
                    when "01010000" => 
                        tempres := res_mod;
                        ovf <= '0';
                    when "00000100" =>
                        tempres := res_shl;
                        ovf <= '0';
                    when "00000101" =>
                        tempres := res_shr;
                        ovf <= '0';
                    when "10000000" => 
                        tempres := a xor b;
                        ovf <= '0';
                    when "01110000" => 
                        tempres := a or b;
                        ovf <= '0';
                    when "01100000" => 
                        tempres := a and b;
                        ovf <= '0';
                    when "11000000" => 
                        tempres := res_comp;
                        ovf <= '0';
                    when "10010000" => 
                        tempres := not(a and b);
                        ovf <= '0';
                    when "10100000" => 
                        tempres := not(a or b);
                        ovf <= '0';
                    when "10110000" => 
                        tempres := not(a xor b);
                        ovf <= '0';
                    when "00000001" =>  -- INCREMENTO
                        tempres := res_inc; 
                       if (a = "01111111") then
                            ovf <= '1';
                        else
                            ovf <= '0';
                        end if;
                        cout <= cout_inc;
                    when "00000010" =>  -- DECREMENTO
                        tempres := res_dec;
                        -- 
                        if (a = "10000000") then
                            ovf <= '1';
                        else
                            ovf <= '0';
                        end if;
                        cout <= '0';
                    when "11100000" =>
                        tempres := a;
                        ovf <= '0';
                    when "11010000" =>
                        tempres := b;
                        ovf <= '0';
                    when others => 
                        tempres := (others => '0');
                        ovf <= '0';
                        cout <= '0';
                end case;
                
                f <= tempres;
                if tempres = "00000000" then
                    z <= '1';
                else
                    z <= '0';
                end if;
                n <= tempres(7);

            else
                f <= (others => '0');
                cout <= '0';
                z <= '0';
                n <= '0';
                ovf <= '0';
            end if;
        end if;
    end process;
end ulaARCH;

--------------------------------------------------------------
----------------------------- REGISTER BANK Entity
--------------------------------------------------------------

entity regfile is
port(
    clk   : IN std_logic;
    rst : IN std_logic; --Reset the register BANK
    --we    : IN std_logic; Choose the operator (write/read)
    addr  : IN unsigned(7 downto 0); --Choose the register
    data  : INOUT std_logic_vector(7 downto 0);
    
    r0    : INOUT std_logic_vector(7 downto 0); -- endereco 000
    r1    : INOUT std_logic_vector(7 downto 0); -- endereco 001
    r2    : INOUT std_logic_vector(7 downto 0); -- endereco 010
    r3    : INOUT std_logic_vector(7 downto 0); -- endereco 011
    flags : INOUT std_logic_vector(7 downto 0)  -- endereco 100
    -- FLAGS: zero (3), carry (2), negative (1), overflow (0)
    );
end regfile;

--------------------------------------------------------------
----------------------------- REGISTER BANK Architecture
--------------------------------------------------------------

architecture reg of regfile is
type reg_array is array(0 to 4) of std_logic_vector(7 downto 0); -- vetor (banco) de vetores (registradores)
signal regs  : reg_array := (others=>(others=>'0')); -- zera todos os registradores

begin
    
    process(clk) -- escrita, reset
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                regs <= (others=>(others=>'0'));
            elsif we = '1' then
                regs(to_integer(addr)) <= data; 
            end if;
        end if;
    end process;

    data <= regs(to_integer(addr)) when we = '0' else (others => 'Z');

end reg;

--------------------------------------------------------------
----------------------------- ADDER Entity
--------------------------------------------------------------

entity sum is
    port(
        a    : in  std_logic_vector(7 downto 0);
        b    : in  std_logic_vector(7 downto 0);
        f    : out std_logic_vector(7 downto 0);
        cin  : in  std_logic;
        cout : out std_logic
    );
end sum;

--------------------------------------------------------------
----------------------------- ADDER Architecture
--------------------------------------------------------------

architecture sumARCH of sum is

    begin
    process(a, b, cin)
        variable carry_v: std_logic_vector(8 downto 0);
    begin
        carry_v(0) := cin;

        
        for n in 0 to 7 loop
        
            f(n) <= carry_v(n) xor a(n) xor b(n);
            
        
        
            carry_v(n+1) := (a(n) and b(n)) or (carry_v(n) and (a(n) xor b(n)));
        end loop;

        
        cout <= carry_v(8);
    end process;
end sumARCH;

--------------------------------------------------------------
----------------------------- SUB Entity
--------------------------------------------------------------

entity sub is
    port(
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        f   : out std_logic_vector(7 downto 0)
    );
end sub;

--------------------------------------------------------------
----------------------------- SUB Architecture
--------------------------------------------------------------

architecture subARCH of sub is

    signal b_invertido: std_logic_vector(7 downto 0);
    signal saida_sum  : std_logic_vector(7 downto 0);
    -- O 'complemento' nem precisa ser um signal, pode ligar '1' direto

    component sum
        port(
            a    : in  std_logic_vector(7 downto 0);
            b    : in  std_logic_vector(7 downto 0);
            f    : out std_logic_vector(7 downto 0);
            cin  : in  std_logic;
            cout : out std_logic
        );
    end component;
    
begin
    b_invertido <= not b;

    U1: sum port map(
        a    => a,
        b    => b_invertido,
        f    => saida_sum,
        cin  => '1',         
        cout => open
    );

    f <= saida_sum;

end subARCH;

--------------------------------------------------------------
----------------------------- Multiplicação Entity
--------------------------------------------------------------

entity mul is
    port(
        a            : in  std_logic_vector(7 downto 0);
        b            : in  std_logic_vector(7 downto 0);
        f            : out std_logic_vector(7 downto 0);
        overflow_flag: out std_logic
    );
end mul;

--------------------------------------------------------------
----------------------------- Multiplicação Archtecture
--------------------------------------------------------------

architecture mulARCH of mul is
    signal highbits: std_logic_vector(7 downto 0);
    signal tempf: std_logic_vector(15 downto 0);
begin
    
    tempf <= std_logic_vector(to_signed(to_integer(signed(a)) * to_integer(signed(b)), 16));
    f <= tempf(7 downto 0);
    highbits <= (others => tempf(7));
    overflow_flag <= '1' when tempf(15 downto 8) /= highbits else '0';
end mulARCH;

--------------------------------------------------------------
----------------------------- Divisão ENtity
--------------------------------------------------------------

entity div is
    port(
        a : in  std_logic_vector(7 downto 0);
        b : in  std_logic_vector(7 downto 0);
        f : out std_logic_vector(7 downto 0)
    );
end div;

--------------------------------------------------------------
----------------------------- Divisão Archtecture
--------------------------------------------------------------

architecture divARCH of div is
begin
    process(a, b)
    begin
        if b /= "00000000" then
            f <= std_logic_vector(to_unsigned(to_integer(unsigned(a)) / to_integer(unsigned(b)), 8));
        else
            f <= (others => '0');  -- divisão segura: resultado = 0
        end if;
    end process;
end divARCH;

--------------------------------------------------------------
----------------------------- Resto da Divisão Entity
--------------------------------------------------------------

entity modu is
    port(
        a : in  std_logic_vector(7 downto 0);
        b : in  std_logic_vector(7 downto 0);
        f : out std_logic_vector(7 downto 0)
    );
end modu;

--------------------------------------------------------------
----------------------------- Resto da Divisão Architecture
--------------------------------------------------------------

architecture moduARCH of modu is
begin
    process(a, b)
    begin
        if b /= "00000000" then
            f <= std_logic_vector(unsigned(a) mod unsigned(b));
        else
            f <= (others => '0');
        end if;
    end process;

end moduARCH;

--------------------------------------------------------------
-----------------------------  Comparação Entity
--------------------------------------------------------------

entity comp is
    port(
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
      	res_comp: out std_logic_vector(7 downto 0)
    );
end comp;

--------------------------------------------------------------
----------------------------- Comparação Architecture
--------------------------------------------------------------

architecture compARCH of comp is
signal f : std_logic_vector(7 downto 0);

     component sub
        port(
            a   : in  std_logic_vector(7 downto 0);
            b   : in  std_logic_vector(7 downto 0);
            f   : out std_logic_vector(7 downto 0)
        );
    end component;

begin

  C1: sub port map(a => a, b => b, f => f);

    process(a, b, f)
    begin
                case f is
                  -- 1 pra quando é igual, sub = 0
                    when "00000000" => res_comp <=  "00000001";
                  -- 0 pra quando é dif,  sub =/ 0
                    when others => res_comp <= "00000000";
                end case;
    end process;
end compARCH;

--------------------------------------------------------------
-----------------------------  bit shift para esquerda Entity
--------------------------------------------------------------

entity bitshiftleft is
port(
  a: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0));
end bitshiftleft;

--------------------------------------------------------------
-----------------------------  bit shift para direita Entity
--------------------------------------------------------------

architecture rtl of bitshiftleft is
begin
  process(a) is
  begin
  	f(0) <= a(7);
    f(1) <= a(0);
    f(2) <= a(1);
    f(3) <= a(2);
    f(4) <= a(3);
    f(5) <= a(4);
    f(6) <= a(5);
    f(7) <= a(6);

  end process;
end rtl;

--------------------------------------------------------------
-----------------------------  bit shift para direita Entity
--------------------------------------------------------------

entity bitshiftright is
port(
  a: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0));
end bitshiftright;

--------------------------------------------------------------
-----------------------------  bit shift para direita Entity
--------------------------------------------------------------

entity bitshiftright is
port(
  a: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0));
end bitshiftright;