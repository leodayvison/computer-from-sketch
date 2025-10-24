library IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;

entity ulaEntity is
port(
  a: IN std_logic_vector(7 downto 0);
  b: IN std_logic_vector(7 downto 0);
  f: OUT std_logic_vector(7 downto 0);
  s: IN std_logic_vector(2 downto 0);
  cout: OUT std_logic;
  en: IN std_logic
  );
end ulaEntity;


-- ARQUITETURA

architecture ulaARCH of ulaEntity is
signal carry_out: std_logic;
signal res_sum, res_sub, res_mul, res_div: std_logic_vector(7 downto 0);

  component sum is
    port(
      a: in std_logic_vector(7 downto 0);
      b: in std_logic_vector(7 downto 0);
      f: out std_logic_vector(7 downto 0);
      cin: in std_logic;
      cout: out std_logic
    );
  end component sum;

  component sub is
    port(
      a: in std_logic_vector(7 downto 0);
      b: in std_logic_vector(7 downto 0);
      f: out std_logic_vector(7 downto 0)
    );
  end component sub;

  component mul is
    port(
      a: in std_logic_vector(7 downto 0);
      b: in std_logic_vector(7 downto 0);
      f: out std_logic_vector(7 downto 0)
    );
  end component mul;

  component div is
    port(
      a: in std_logic_vector(7 downto 0);
      b: in std_logic_vector(7 downto 0);
      f: out std_logic_vector(7 downto 0)
    );
  end component div;

  U1: sum port map(a, b, res_sum, cin, carry_out);
  U2: sub port map(a, b, res_sub);
  U3: mul port map(a, b, res_mul);
  U4: div port map(a, b, res_div);


begin
  process(a, b, s, cin)
  begin
    if en = '1' then
      case s is -- usaremos o mesmo esquema do ci 74ls382
        when "000" => -- soma
          f <= res_sum;
        when "001" => -- A MINUS B
          f <= res_sub;
        when "010" =>
          f <= res_mul;
        when "011" =>
        f <= res_div;
        when "101" => --LOGIC OP: OR
        for n in 0 to 7 loop
          f(n) <= a(n) or b(n);
        end loop;
        when "110" => --LOGIC OP: AND
          for n in 0 to 7 loop
            f(n) <= a(n) and b(n);
          end loop;
        when "100" => --LOGIC OP: XOR
          for n in 0 to 7 loop
            f(n) <= a(n) xor b(n);
          end loop;
        when others =>
          f <= (others => '0');
      end case;
      cout <= carry_out;
    else f <= (others => '0'); 
    end if;
  end process;
end ulaARCH;

