library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity modu is
    port(
        a : in  std_logic_vector(7 downto 0);
        b : in  std_logic_vector(7 downto 0);
        f_m : out std_logic_vector(7 downto 0) 
    );
end modu;

architecture moduARCH of modu is
    component div
        port(
            a   : in  std_logic_vector(7 downto 0);
            b   : in  std_logic_vector(7 downto 0);
            f   : out std_logic_vector(7 downto 0)
        );
    end component;
              
    signal f : std_logic_vector(7 downto 0);

begin
    M1: div port map(a => a, b => b, f => f);
  
    process(a, b, f)
    begin
    	if b/= "00000000" then
            f_m <= std_logic_vector(unsigned(a) - (unsigned(b) * unsigned(f)));
        else
            f_m <= (others => '0');
        end if;
    end process;
end moduARCH;