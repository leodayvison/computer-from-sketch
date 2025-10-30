library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity compEntity is
    port(
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
      	res_comp: out std_logic_vector(7 downto 0)
    );
end compEntity;

architecture compARCH of compEntity is
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