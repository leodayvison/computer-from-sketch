library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ulaEntity is
    port(
        a            : in  std_logic_vector(7 downto 0);
        b            : in  std_logic_vector(7 downto 0);
        f            : out std_logic_vector(7 downto 0);
        s            : in  std_logic_vector(3 downto 0);
        en           : in  std_logic;
        clk          : in  std_logic;
        z, cout, n, ovf : out std_logic -- flags
    );
end ulaEntity;

architecture ulaARCH of ulaEntity is
    signal carry_out: std_logic;
    signal res_sum, res_sub, res_mul, res_div, res_comp: std_logic_vector(7 downto 0);
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

    component comp
        port(
            a   : in  std_logic_vector(7 downto 0);
            b   : in  std_logic_vector(7 downto 0);
            f   : out std_logic_vector(7 downto 0)
        );
        end component;

begin
    U1: sum port map(a => a, b => b, f => res_sum, cin => '0', cout => carry_out);
    U2: sub port map(a => a, b => b, f => res_sub);
    U3: mul port map(a => a, b => b, f => res_mul, overflow_flag => ovf_mul);
    U4: div port map(a => a, b => b, f => res_div);
    U5: comp port map(a => a, b => b, f => res_comp);

    process(clk)
    variable tempres : std_logic_vector(7 downto 0);
    begin
        if rising_edge(clk) then
        if en = '1' then
                case s is
                    when "0000" => tempres := res_sum; ovf <= (a(7) = b(7) and res_sum(7) /= a(7));
                    when "0001" => tempres := res_sub; ovf <= (a(7) /= b(7) and res_sub(7) /= a(7));
                    when "0010" => tempres := res_mul; ovf <= ovf_mul;
                    when "0011" => tempres := res_div;
                    when "0100" => tempres := a xor b;
                    when "0101" => tempres := a or b;
                    when "0110" => tempres := a and b;
                    when "0111" => tempres := res_comp;
                    when "1000" => tempres := not(a and b);
                    wwhen "1001" => tempres := not(a or b);
                    when "1010" => tempres := not(a xor b);
                    when others => tempres := (others => '0');
                end case;
                f <= tempres;
                if tempres = "00000000" then
                    z <= '1';
                end if;


                --z <= '1' when tempres = "00000000" else '0';
                n <= tempres(7);
                cout <= carry_out;

        else
            f <= (others => '0');
            cout <= '0';
        end if;
    end if;
    end process;
end ulaARCH;
