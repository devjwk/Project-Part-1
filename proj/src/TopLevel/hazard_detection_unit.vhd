library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detection_unit is
    port(
        -- ID stage instruction (consumer side)
        i_Inst_ID      : in  std_logic_vector(31 downto 0);

        i_MemRead_EX   : in  std_logic;
        i_Rd_EX        : in  std_logic_vector(4 downto 0);

        -- Outputs (classic control)
        o_PCWrite      : out std_logic;  -- 1 = allow PC update
        o_IFID_Write   : out std_logic;  -- 1 = allow IF/ID reg write
        o_IDEX_Flush   : out std_logic;  -- 1 = insert bubble into ID/EX

        o_DataHazard   : out std_logic
    );
end hazard_detection_unit;

architecture rtl of hazard_detection_unit is

    -- Extracted fields from i_Inst_ID
    signal s_Opcode_ID  : std_logic_vector(6 downto 0);
    signal s_Rs1Addr_ID : std_logic_vector(4 downto 0);
    signal s_Rs2Addr_ID : std_logic_vector(4 downto 0);

    -- Use flags (generalized form)
    signal s_UseRs1_ID  : std_logic;
    signal s_UseRs2_ID  : std_logic;
    
    signal s_DataHaz    : std_logic;

begin

    -- Opcode / rs fields
    s_Opcode_ID  <= i_Inst_ID(6 downto 0);
    s_Rs1Addr_ID <= i_Inst_ID(19 downto 15);
    s_Rs2Addr_ID <= i_Inst_ID(24 downto 20);

    -------------------------------------------------------------------------
    -- UseRs1_ID / UseRs2_ID (based on supported RV32I subset)
    --
    -- UseRs1_ID = 1 for:
    --   R-type ALU(0110011), I-type ALU(0010011),
    --   Loads(0000011), Stores(0100011),
    --   Branches(1100011), JALR(1100111)
    --
    -- UseRs2_ID = 1 for:
    --   R-type ALU(0110011), Stores(0100011), Branches(1100011)
    --
    -- Both 0 for:
    --   LUI(0110111), AUIPC(0010111), JAL(1101111),
    --   SYSTEM(1110011) 등(과제에서 HALT/WFI로 쓰는 경우)
    -------------------------------------------------------------------------
    process(s_Opcode_ID)
    begin
        -- default
        s_UseRs1_ID <= '0';
        s_UseRs2_ID <= '0';

        case s_Opcode_ID is
            when "0110011" =>  -- R-type ALU
                s_UseRs1_ID <= '1';
                s_UseRs2_ID <= '1';

            when "0010011" =>  -- I-type ALU
                s_UseRs1_ID <= '1';
                

            when "0000011" =>  -- LOAD
                s_UseRs1_ID <= '1';
                

            when "0100011" =>  -- STORE
                s_UseRs1_ID <= '1';
                s_UseRs2_ID <= '1';

            when "1100011" =>  -- BRANCH
                s_UseRs1_ID <= '1';
                s_UseRs2_ID <= '1';

            when "1100111" =>  -- JALR
                s_UseRs1_ID <= '1';
                

            when others =>
                null;
        end case;
    end process;

    -------------------------------------------------------------------------
    -- Generalized Load-Use Hazard
    --
    -- LoadUse =
    --   MemRead_EX and Rd_EX != 0 and
    --   ((UseRs1_ID and Rd_EX = Rs1Addr_ID) or
    --    (UseRs2_ID and Rd_EX = Rs2Addr_ID))
    -------------------------------------------------------------------------
    -- Load-use only
    s_DataHaz <= '1' when (
        i_MemRead_EX = '1' and
        i_Rd_EX /= "00000" and
        (
            (s_UseRs1_ID = '1' and i_Rd_EX = s_Rs1Addr_ID) or
            (s_UseRs2_ID = '1' and i_Rd_EX = s_Rs2Addr_ID)
        )
    ) else '0';
    -------------------------------------------------------------------------
    -- Classic stall control outputs
    -------------------------------------------------------------------------
    o_PCWrite    <= not s_DataHaz;
    o_IFID_Write <= not s_DataHaz;
    o_IDEX_Flush <= s_DataHaz;

    o_DataHazard    <= s_DataHaz;

end rtl;