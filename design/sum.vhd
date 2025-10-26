library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sum is
    port(
        a    : in  std_logic_vector(7 downto 0);
        b    : in  std_logic_vector(7 downto 0);
        f    : out std_logic_vector(7 downto 0);
        cin  : in  std_logic;
        cout : out std_logic
    );
end sum;

architecture sumARCH of sum is
    -- O 'carry' não precisa ser um sinal (signal) aqui
begin
    process(a, b, cin)
        -- Declare o carry como uma VARIÁVEL dentro do process
        variable carry_v: std_logic_vector(8 downto 0);
    begin
        -- 1. Use atribuição de variável (:=)
        carry_v(0) := cin;

        -- 2. Loop para o ripple-carry
        for n in 0 to 7 loop
            -- A saída 'f' (um sinal) ainda usa '<='
            f(n) <= carry_v(n) xor a(n) xor b(n);
            
            -- O 'carry_v' (uma variável) usa ':='
            -- Esta atualização acontece IMEDIATAMENTE.
            carry_v(n+1) := (a(n) and b(n)) or (carry_v(n) and (a(n) xor b(n)));
        end loop;

        -- 3. A saída 'cout' (sinal) recebe o valor final da variável
        cout <= carry_v(8);
    end process;
end sumARCH;