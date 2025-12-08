library IEEE;
use IEEE.std_logic_1164.all;

entity ex_alu_operand_mux is
    port(
        -- ID/EX 기본 값
        i_PC_EX        : in  std_logic_vector(31 downto 0);
        i_ReadData1_EX : in  std_logic_vector(31 downto 0);
        i_ReadData2_EX : in  std_logic_vector(31 downto 0);
        i_Imm_EX       : in  std_logic_vector(31 downto 0);

        -- Forward select
        i_ForwardA     : in  std_logic_vector(1 downto 0);
        i_ForwardB     : in  std_logic_vector(1 downto 0);

        -- Producer values
        i_ALUResult_MEM : in std_logic_vector(31 downto 0); -- EX/MEM → EX
        i_WBValue_WB    : in std_logic_vector(31 downto 0); -- MEM/WB → EX (최종 WB값)

        -- ALU source select
        -- 0=use forwarded rs1/rs2, 1=use PC/Imm
        i_ALUSrcA      : in  std_logic;
        i_ALUSrcB      : in  std_logic;

        -- Outputs to ALU
        o_ALUInA       : out std_logic_vector(31 downto 0);
        o_ALUInB       : out std_logic_vector(31 downto 0);

        -- (옵션) 디버깅/검증용: forward된 rs 값 뽑아주기
        o_Rs1_Fwd      : out std_logic_vector(31 downto 0);
        o_Rs2_Fwd      : out std_logic_vector(31 downto 0)
    );
end ex_alu_operand_mux;

architecture rtl of ex_alu_operand_mux is
    signal s_Rs1_Fwd : std_logic_vector(31 downto 0);
    signal s_Rs2_Fwd : std_logic_vector(31 downto 0);
begin

    -- Rs1 forward mux
    U_FWD_A : entity work.fwd_mux3
        generic map(N => 32)
        port map(
            i_Sel => i_ForwardA,
            i_D0  => i_ReadData1_EX,
            i_D1  => i_WBValue_WB,
            i_D2  => i_ALUResult_MEM,
            o_Y   => s_Rs1_Fwd
        );

    -- Rs2 forward mux
    U_FWD_B : entity work.fwd_mux3
        generic map(N => 32)
        port map(
            i_Sel => i_ForwardB,
            i_D0  => i_ReadData2_EX,
            i_D1  => i_WBValue_WB,
            i_D2  => i_ALUResult_MEM,
            o_Y   => s_Rs2_Fwd
        );

    -- ALU input A select
    o_ALUInA <= i_PC_EX when i_ALUSrcA = '1' else s_Rs1_Fwd;

    -- ALU input B select
    o_ALUInB <= i_Imm_EX when i_ALUSrcB = '1' else s_Rs2_Fwd;

    -- optional taps
    o_Rs1_Fwd <= s_Rs1_Fwd;
    o_Rs2_Fwd <= s_Rs2_Fwd;

end rtl;