library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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

architecture ulaARCH of ulaEntity is
    signal carry_out: std_logic;
    signal res_sum, res_sub, res_mul, res_div, res_comp, res_inc, res_dec: std_logic_vector(7 downto 0);
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

begin
    U1: sum port map(a => a, b => b, f => res_sum, cin => '0', cout => carry_out);
    U2: sub port map(a => a, b => b, f => res_sub);
    U3: mul port map(a => a, b => b, f => res_mul, overflow_flag => ovf_mul);
    U4: div port map(a => a, b => b, f => res_div);
    U5: comp port map(a => a, b => b, res_comp => res_comp);
    U6: sum port map(a => a, b => "00000001", f => res_inc, cin => '0', cout => cout_inc);
    U7: sub port map(a => a, b => "00000001", f => res_dec);

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