--Imports

library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity readBIN is 
port(
    clk: IN std_logic;
    rst: IN std_logic;
    instructionOut: OUT std_logic_vector(7 downto 0)
);
end readBIN;

architecture readBINarch of readBIN is

   signal mainInput : std_logic_vector(7 downto 0) :=  (others => '0');    

    file queueFile : text open read_mode is "queue.txt";
    signal fileReady : boolean := false;

    instructionLoader : process
        variable inline : line;
        variable c : character;
        variable tmp_vec: std_logic_vector(7 downto 0);

    begin

        wait until rst = '0';

        while not endfile(queueFile) loop
            readline(queueFile, inline);
        
            for bit in 0 to 7 loop
                read(inline, c);
                if c = '1' then
                    tmp_vec(7 - bit) := '1';
                else
                    tmp_vec(7 - bit) := '0';
                end if;
            end loop;

            mainInput <= tmp_vec;
            fileReady <= true;

            report "Read value (bin): " & std_logic_vector'image(mainInput);

            wait until rising_edge(clk);
        end loop;

        wait;
    end process;


end readBINarch;
