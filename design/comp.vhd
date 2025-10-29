library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity comp is
    port(
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        f   : out std_logic_vector(7 downto 0)
    );
end comp;

architecture compARCH of comp is
    signal res_sub: std_logic_vector(7 downto 0);


    component sub
        port(
            a   : in  std_logic_vector(7 downto 0);
            b   : in  std_logic_vector(7 downto 0);
            f   : out std_logic_vector(7 downto 0)
        );
    end component;


begin

  C1: sub port map(a => a, b => b, f => res_sub);

    process(a, b)
    begin
            case res_sub is
                when "00000000" => f <= "00000001"; -- dá 1 caso sejam enguais
                when others => f <= "00000000"; -- dá 0 caso sejam deferentes
            end case;
    end process;
end compARCH;