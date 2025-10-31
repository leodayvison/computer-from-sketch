library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity InstructionROM is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        addr     : in  std_logic_vector(6 downto 0); -- endereco (7 bits = 128 posições)
        data_out : out std_logic_vector(7 downto 0)  -- saida de dados (8 bits)
    );
end entity InstructionROM;

architecture Behavioral of InstructionROM is

    
    constant ROM_DEPTH : integer := 128; -- MIN_BINARY_LINES
    constant ROM_WIDTH : integer := 8;   -- WORD_SIZE
    
    type rom_type is array (0 to ROM_DEPTH - 1) of std_logic_vector(ROM_WIDTH - 1 downto 0);

    
    impure function init_rom_from_file(filename : string) return rom_type is
        file bin_file : TEXT;
        variable file_line : line;
        variable rom_data  : rom_type;
        variable temp_bv   : std_logic_vector(ROM_WIDTH - 1 downto 0);
    begin
        
        file_open(bin_file, filename, READ_MODE);

        for i in 0 to ROM_DEPTH - 1 
        loop
            if not endfile(bin_file) then
                readline(bin_file, file_line);
                read(file_line, temp_bv); 
                rom_data(i) := temp_bv;
            else
                
                rom_data(i) := (others => '0');
            end if;   
        end loop;
        
        file_close(bin_file);
        return rom_data;
        
    end function init_rom_from_file;


    constant ROM : rom_type := init_rom_from_file("../sim/instructions.txt");

begin

    
    process(clk, rst)
    begin
        
        if rst = '0' then
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            data_out <= ROM(to_integer(unsigned(addr)));
        end if;
    end process;

end architecture Behavioral;