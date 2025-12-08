library IEEE;
use IEEE.std_logic_1164.all;

entity forwarding_unit_all is
    port(
        -- =====================
        -- Consumers
        -- =====================
        -- EX-stage ALU consumers (ID/EX)
        i_Rs1Addr_EX    : in  std_logic_vector(4 downto 0);
        i_Rs2Addr_EX    : in  std_logic_vector(4 downto 0);

        -- =====================
        -- Producers
        -- =====================
        -- EX/MEM
        i_Rd_MEM        : in  std_logic_vector(4 downto 0);
        i_RegWrite_MEM  : in  std_logic;

        -- MEM/WB
        i_Rd_WB         : in  std_logic_vector(4 downto 0);
        i_RegWrite_WB   : in  std_logic;

        -- =====================
        -- Outputs
        -- =====================
        -- 00 = no fwd
        -- 10 = forward from EX/MEM
        -- 01 = forward from MEM/WB
        o_ForwardA      : out std_logic_vector(1 downto 0);
        o_ForwardB      : out std_logic_vector(1 downto 0);

        -- Store-data forwarding in EX stage
        -- (store가 EX에 있을 때 rs2 값 미리 보정)
        o_StoreFwd_EX   : out std_logic_vector(1 downto 0)
    );
end forwarding_unit_all;

architecture rtl of forwarding_unit_all is
    -- ALU operand A
    signal s_EX_MEM_A : std_logic;
    signal s_MEM_WB_A : std_logic;

    -- ALU operand B
    signal s_EX_MEM_B : std_logic;
    signal s_MEM_WB_B : std_logic;
begin

    -- =====================
    -- Match logic
    -- =====================
    s_EX_MEM_A <= '1' when (i_RegWrite_MEM = '1' and
                        i_Rd_MEM /= "00000" and
                        i_Rd_MEM = i_Rs1Addr_EX)
              else '0';

    s_MEM_WB_A <= '1' when (i_RegWrite_WB = '1' and
                            i_Rd_WB /= "00000" and
                            i_Rd_WB = i_Rs1Addr_EX)
                else '0';

    s_EX_MEM_B <= '1' when (i_RegWrite_MEM = '1' and
                            i_Rd_MEM /= "00000" and
                            i_Rd_MEM = i_Rs2Addr_EX)
                else '0';

    s_MEM_WB_B <= '1' when (i_RegWrite_WB = '1' and
                            i_Rd_WB /= "00000" and
                            i_Rd_WB = i_Rs2Addr_EX)
                else '0';

    -- =====================
    -- Priority: EX/MEM > MEM/WB
    -- =====================
    process(s_EX_MEM_A, s_MEM_WB_A)
    begin
        if s_EX_MEM_A = '1' then
            o_ForwardA <= "10";
        elsif s_MEM_WB_A = '1' then
            o_ForwardA <= "01";
        else
            o_ForwardA <= "00";
        end if;
    end process;

    process(s_EX_MEM_B, s_MEM_WB_B)
    begin
        if s_EX_MEM_B = '1' then
            o_ForwardB <= "10";
        elsif s_MEM_WB_B = '1' then
            o_ForwardB <= "01";
        else
            o_ForwardB <= "00";
        end if;
    end process;

    -- =====================
    -- Store-data forwarding in EX
    -- Store의 rs2도 결국 Rs2Addr_EX를 소비하니까
    -- ForwardB와 같은 조건을 그대로 재사용 가능
    -- =====================
    process(s_EX_MEM_B, s_MEM_WB_B)
    begin
        if s_EX_MEM_B = '1' then
            o_StoreFwd_EX <= "10";
        elsif s_MEM_WB_B = '1' then
            o_StoreFwd_EX <= "01";
        else
            o_StoreFwd_EX <= "00";
        end if;
    end process;

end rtl;