library IEEE;
use IEEE.std_logic_1164.all;

entity fwd_mux3 is
    generic(N : integer := 32);
    port(
        i_Sel  : in  std_logic_vector(1 downto 0);
        i_D0   : in  std_logic_vector(N-1 downto 0); -- 00: original
        i_D1   : in  std_logic_vector(N-1 downto 0); -- 01: MEM/WB
        i_D2   : in  std_logic_vector(N-1 downto 0); -- 10: EX/MEM
        o_Y    : out std_logic_vector(N-1 downto 0)
    );
end fwd_mux3;

architecture rtl of fwd_mux3 is
begin
    process(i_Sel, i_D0, i_D1, i_D2)
    begin
        case i_Sel is
            when "10" => o_Y <= i_D2; -- EX/MEM
            when "01" => o_Y <= i_D1; -- MEM/WB
            when others => o_Y <= i_D0; -- 00
        end case;
    end process;
end rtl;