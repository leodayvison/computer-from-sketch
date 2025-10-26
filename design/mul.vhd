library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mul is
    port(
        a            : in  std_logic_vector(7 downto 0);
        b            : in  std_logic_vector(7 downto 0);
        f            : out std_logic_vector(7 downto 0);
        overflow_flag: out std_logic
    );
end mul;

architecture mulARCH of mul is
    signal highbits: std_logic_vector(7 downto 0);
    signal tempf: std_logic_vector(15 downto 0);
begin
    
    tempf <= std_logic_vector(to_signed(to_integer(signed(a)) * to_integer(signed(b)), 16));
    f <= tempf(7 downto 0);
    highbits <= (others => tempf(7));
    overflow_flag <= '1' when tempf(15 downto 8) /= highbits else '0';
end mulARCH;
