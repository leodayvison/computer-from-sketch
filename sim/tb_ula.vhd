library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ula is
end tb_ula;

architecture sim of tb_ula is
   
    signal a, b : std_logic_vector(7 downto 0) := (others => '1');
    signal s    : std_logic_vector(7 downto 0) := (others => '0');
    signal en   : std_logic := '0';
    signal clk  : std_logic := '0';


    signal f    : std_logic_vector(7 downto 0) := (others => '0');
    signal z, n, ovf, cout : std_logic;

    constant clk_period : time := 10 ns;

begin
   
    UUT: entity work.ulaEntity
        port map(
            a    => a,
            b    => b,
            f    => f,
            s    => s,
            cout => cout,
            z => z,
            n => n,
            ovf => ovf,
            en   => en,
            clk  => clk
        );

   
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;


    stim_proc: process
    begin
        
        en <= '1';
        wait until rising_edge(clk);

        -- sum
        a <= "00000001"; b <= "00000101"; s <= "00010000";  -- 3+5
        wait for 1 ns;
        wait until rising_edge(clk);
        wait on f;
        assert (f="00000110") report "Fail sum" severity error;

        -- sub
        a <= "00001010"; b <= "00000101"; s <= "00100000";  -- 10-5
        wait until rising_edge(clk);
        wait on f;
        assert (f="00000101") report "Fail sub" severity error;

        -- mult
        a <= "00000110"; b <= "00000101"; s <= "00110000";  -- 6*5mpres :=
        wait until rising_edge(clk);
        wait on f;
        assert (f="00011110") report "Fail mul" severity error;
        
        -- inc - b recebe 0 pq ja ta cm 1 na arch
         a <= "00000111"; b <= "00000000"; s <= "00000001";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00001000") report "Fail inc: expected 00001000, got " severity error;

        -- dec
        a <= "00001000"; b <= "00000000"; s <= "00000010";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000111") report "Fail dec: expected 00000111, got "  severity error;


        a <= "00001101";
        b <= "00000100";
        s <= "01010000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert(f_m_out ="00000001") report "Fail com resto" severity error;
       

        -- xor
        a <= "10101010"; b <= "11001100"; s <= "10000000";
        wait until rising_edge(clk);

        -- or
        s <= "01110000";
        wait until rising_edge(clk);

        -- and
        s <= "01100000";
        wait until rising_edge(clk);

        
        en <= '0';
        a <= (others => '0');
        s <= (others => '0');
        wait until rising_edge(clk);

       
        wait;
    end process;

end sim;