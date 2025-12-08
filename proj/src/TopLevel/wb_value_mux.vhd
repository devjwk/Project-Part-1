library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity wb_value_mux is
    port(
        i_PC_WB        : in  std_logic_vector(31 downto 0);
        i_ALUResult_WB : in  std_logic_vector(31 downto 0);
        i_LoadData_WB  : in  std_logic_vector(31 downto 0);
        i_Imm_WB       : in  std_logic_vector(31 downto 0);
        i_MemtoReg_WB  : in  std_logic_vector(1 downto 0);

        o_WBValue_WB   : out std_logic_vector(31 downto 0)
    );
end wb_value_mux;

architecture rtl of wb_value_mux is
    signal s_PCPlus4_WB : std_logic_vector(31 downto 0);
begin
    -- PC+4 계산 (너 mem_wb_reg가 PC만 들고 있으니까 이렇게 만드는 게 현실적)
    s_PCPlus4_WB <= std_logic_vector(unsigned(i_PC_WB) + 4);

    process(i_MemtoReg_WB, i_ALUResult_WB, i_LoadData_WB, s_PCPlus4_WB, i_Imm_WB)
    begin
        case i_MemtoReg_WB is
            when "00" => o_WBValue_WB <= i_ALUResult_WB;
            when "01" => o_WBValue_WB <= i_LoadData_WB;
            when "10" => o_WBValue_WB <= s_PCPlus4_WB;
            when "11" => o_WBValue_WB <= i_Imm_WB;
            when others => o_WBValue_WB <= i_ALUResult_WB;
        end case;
    end process;
end rtl;