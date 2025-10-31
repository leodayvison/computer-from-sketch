library IEEE;
use IEEE.std_logic_1164.all;
 
entity modu_tb is
-- empty
end modu_tb; 

architecture tb of modu_tb is

-- DUT component
component div is
port(
  a: in std_logic_vector(7 downto 0);
  b: in std_logic_vector(7 downto 0);
  f_m: out std_logic_vector(7 downto 0)
    );


end component;

signal a_in, b_in, f_m_out: std_logic_vector(7 downto 0);

begin

  -- Connect DUT
  DUT: div port map(a_in, b_in, f_m_out);

  process
  begin
    a_in <= "00000001";
    b_in <= "00000001";
    wait for 1 ns;
    assert(f_m_out ="00000000") report "Fail sem resto" severity error;
    
    a_in <= "00001101";
    b_in <= "00000100";
    wait for 1 ns;
    assert(f_m_out ="00000001") report "Fail com resto" severity error;
  
    

    -- Clear inputs
    a_in <= "00000000";
    b_in <= "00000000";

    assert false report "Test done." severity note;
    wait;
  end process;
end tb;