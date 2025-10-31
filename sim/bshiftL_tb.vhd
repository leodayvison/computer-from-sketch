library IEEE;
use IEEE.std_logic_1164.all;
 
entity bitshiftleft_tb is
-- empty
end bitshiftleft_tb; 

architecture tb of bitshiftleft_tb is

-- DUT component
component bitshiftleft is
port(
  a: IN std_logic_vector(7 downto 0);
  s: OUT std_logic_vector(7 downto 0));
end component;

signal a_in: std_logic_vector(7 downto 0);
signal s_out: std_logic_vector(7 downto 0);

begin

  -- Connect DUT
  DUT: bitshiftleft port map(a_in, s_out);

  process
  begin
    a_in <= "00000001";
    wait for 1 ns;
    assert(s_out="00000010") report "Fail 0/0/0" severity error;
  
    

    -- Clear inputs
    a_in <= "00000000";

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;