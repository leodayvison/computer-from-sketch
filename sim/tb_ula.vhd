library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ula is
end tb_ula;

architecture sim of tb_ula is

    -- helper: converte std_logic_vector para string (VHDL-93)
    function slv_to_string(v : std_logic_vector) return string is
        variable s : string(1 to v'length);
        variable idx : integer := 1;
    begin
        for i in v'reverse_range loop
            if v(i) = '1' then
                s(idx) := '1';
            else
                s(idx) := '0';
            end if;
            idx := idx + 1;
        end loop;
        return s;
    end function;

    -- sinais do DUT
    signal a, b : std_logic_vector(7 downto 0) := (others => '0');
    signal s    : std_logic_vector(7 downto 0) := (others => '0');
    signal en   : std_logic := '0';
    signal clk  : std_logic := '0';

    signal f    : std_logic_vector(7 downto 0) := (others => '0');
    signal z, n, ovf, cout : std_logic;

    constant clk_period : time := 10 ns;

begin

    -- Instancia a ULA (DUT)
    UUT: entity work.ulaEntity
        port map(
            a    => a,
            b    => b,
            f    => f,
            s    => s,
            en   => en,
            clk  => clk,
            z    => z,
            cout => cout,
            n    => n,
            ovf  => ovf
        );

    -- clock
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- estímulos e checagens
    stim_proc: process
    begin
        -- habilita ULA
        en <= '1';
        wait for clk_period; -- espera estabilizar

        ----------------------------------------------------------------
        -- SUM: opcode "00010000" -> 1 + 5 = 6
        ----------------------------------------------------------------
        a <= "00000001"; b <= "00000101"; s <= "00010000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000110")
            report "FAIL SUM: expected 00000110, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- SUB: opcode "00100000" -> 10 - 5 = 5
        ----------------------------------------------------------------
        a <= "00001010"; b <= "00000101"; s <= "00100000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000101")
            report "FAIL SUB: expected 00000101, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- MUL: opcode "00110000" -> 6 * 5 = 30 (00011110)
        ----------------------------------------------------------------
        a <= "00000110"; b <= "00000101"; s <= "00110000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00011110")
            report "FAIL MUL: expected 00011110, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- DIV: opcode "01000000" -> 15 / 3 = 5
        ----------------------------------------------------------------
        a <= "00001111"; b <= "00000011"; s <= "01000000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000101")
            report "FAIL DIV: expected 00000101, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- MOD: opcode "01010000" -> 13 mod 4 = 1
        ----------------------------------------------------------------
        a <= "00001101"; b <= "00000100"; s <= "01010000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000001")
            report "FAIL MOD: expected 00000001, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- SHL: opcode "00000100" -> shift left (ex: 00000011 << = 00000110)
        ----------------------------------------------------------------
        a <= "00000011"; b <= (others => '0'); s <= "00000100";
        wait until rising_edge(clk);
        wait for 1 ns;
        -- ajuste esperado conforme sua implementação de shift left
        assert (f = "00000110")
            report "FAIL SHL: expected 00000110, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- SHR: opcode "00000101" -> shift right (ex: 00000110 >> = 00000011)
        ----------------------------------------------------------------
        a <= "00000110"; b <= (others => '0'); s <= "00000101";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000011")
            report "FAIL SHR: expected 00000011, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- XOR: opcode "10000000"
        ----------------------------------------------------------------
        a <= "10101010"; b <= "11001100"; s <= "10000000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "01100110")
            report "FAIL XOR: expected 01100110, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- OR: opcode "01110000"
        ----------------------------------------------------------------
        a <= "10100010"; b <= "01001100"; s <= "01110000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "11101110")
            report "FAIL OR: expected 11101110, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- AND: opcode "01100000"
        ----------------------------------------------------------------
        a <= "10101010"; b <= "11001100"; s <= "01100000";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "10001000")
            report "FAIL AND: expected 10001000, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- COMP: opcode "11000000" (se a sua comp retorna algo específico ajuste o esperado)
        -- Aqui assumimos que comp retorna (a - b) ou um indicador; ajuste conforme sua comp.
        ----------------------------------------------------------------
        a <= "00001010"; b <= "00000011"; s <= "11000000";
        wait until rising_edge(clk);
        wait for 1 ns;
        -- ajuste esperado para sua implementação de 'comp'
        -- por enquanto apenas checamos se não dá zero (exemplo)
        assert not (f = "00000000")
            report "WARN COMP: result is zero (check expected behavior). f=" & slv_to_string(f) severity warning;

        ----------------------------------------------------------------
        -- NOT (NAND/NOR/XNOR): "10010000" "10100000" "10110000" - vamos testar NAND
        ----------------------------------------------------------------
        a <= "00001111"; b <= "11110000"; s <= "10010000"; -- nand
        wait until rising_edge(clk);
        wait for 1 ns;
        -- NAND de 00001111 e 11110000 = not(00001111 and 11110000) = not(00000000)=11111111
        assert (f = "11111111")
            report "FAIL NAND: expected 11111111, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- INCREMENTO: "00000001"
        ----------------------------------------------------------------
        a <= "00000111"; b <= (others => '0'); s <= "00000001";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00001000")
            report "FAIL INC: expected 00001000, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- DECREMENTO: "00000010"
        ----------------------------------------------------------------
        a <= "00001000"; b <= (others => '0'); s <= "00000010";
        wait until rising_edge(clk);
        wait for 1 ns;
        assert (f = "00000111")
            report "FAIL DEC: expected 00000111, got " & slv_to_string(f) severity error;

        ----------------------------------------------------------------
        -- Finaliza: desabilita e para
        ----------------------------------------------------------------
        en <= '0';
        wait for clk_period;
        report "All ULA tests finished." severity note;
        wait;
    end process;

end sim;
