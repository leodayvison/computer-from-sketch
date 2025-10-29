entity regfile is
port(
    clk   : IN std_logic;
    reset : IN std_logic; --Reset the register BANK
    we    : IN std_logic; --Choose the operator (write/read)
    addr  : IN unsigned(2 downto 0); --Choose the register
    data  : INOUT std_logic_vector(7 downto 0);
    
    r0    : INOUT std_logic_vector(7 downto 0); -- endereco 000
    r1    : INOUT std_logic_vector(7 downto 0); -- endereco 001
    r2    : INOUT std_logic_vector(7 downto 0); -- endereco 010
    r3    : INOUT std_logic_vector(7 downto 0); -- endereco 011
    flags : INOUT std_logic_vector(2 downto 0) -- endereco 100
    -- FLAGS: zero (2), overflow (1), carry (0)
    );
end regfile;

architecture reg of regfile is
begin

    type reg_array is array(0 to 3) of std_logic_vector(7 downto 0); -- vetor (banco) de vetores (registradores)
    signal regs  : reg_array := (others=>(others=>'0')); -- zera todos os registradores

    process(clk) -- escrita, reset
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                regs <= (others=>(others=>'0'));
            elsif we = '1' then
                regs(to_integer(addr)) <= data; 
            end if;
        end if;
    end process;

    data <= regs(to_integer(addr)) when we = '0' else (others => 'Z');

end reg;