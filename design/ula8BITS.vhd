library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ulaEntity is
    port(
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        f   : out std_logic_vector(7 downto 0);
        s   : in  std_logic_vector(2 downto 0);
        cout: out std_logic;
        en  : in  std_logic;
        clk : in  std_logic
    );
end ulaEntity;

architecture ulaARCH of ulaEntity is
    signal carry_out: std_logic;
    signal res_sum, res_sub, res_mul, res_div: std_logic_vector(7 downto 0);
    signal ovf_mul: std_logic;
    

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

begin
    U1: sum port map(a => a, b => b, f => res_sum, cin => '0', cout => carry_out);
    U2: sub port map(a => a, b => b, f => res_sub);
    U3: mul port map(a => a, b => b, f => res_mul, overflow_flag => ovf_mul);
    U4: div port map(a => a, b => b, f => res_div);

    process(clk)
    begin
        if rising_edge(clk) then
        if en = '1' then
                case s is
                    when "000" => f <= res_sum;
                    when "001" => f <= res_sub;
                    when "010" => f <= res_mul;
                    when "011" => f <= res_div;
                    when "100" => f <= a xor b;
                    when "101" => f <= a or b;
                    when "110" => f <= a and b;
                    when others => f <= (others => '0');
                end case;
                cout <= carry_out;
        else
            f <= (others => '0');
            cout <= '0';
        end if;
    end if;
    end process;
end ulaARCH;
