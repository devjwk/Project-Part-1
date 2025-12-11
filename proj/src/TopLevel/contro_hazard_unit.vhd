library IEEE;
use IEEE.std_logic_1164.all;

entity control_hazard_unit is
    port(
        -- From EX stage
        i_Branch_EX    : in std_logic;
        i_Jump_EX      : in std_logic_vector(1 downto 0); -- 01=JAL, 10=JALR

        -- Branch condition evaluation inputs
        i_Funct3_EX    : in std_logic_vector(2 downto 0);
        i_ALUZero_EX   : in std_logic;
        i_ALUSign_EX   : in std_logic;
        i_ALUCout_EX   : in std_logic;

        -- Outputs to pipeline control
        o_IFID_Flush   : out std_logic;
        o_IDEX_Flush   : out std_logic;
        o_BranchTaken  : out std_logic
    );
end control_hazard_unit;

architecture rtl of control_hazard_unit is

    signal s_Taken : std_logic := '0';
    signal s_Flush : std_logic := '0';

begin

    --------------------------------------------------------------------------
    -- Branch decision logic (same truth table as your fetch_logic)
    --------------------------------------------------------------------------
    process(i_Branch_EX, i_Funct3_EX, i_ALUZero_EX, i_ALUSign_EX, i_ALUCout_EX)
    begin
        s_Taken <= '0';

        if i_Branch_EX = '1' then
            case i_Funct3_EX is
                when "000" =>  -- BEQ
                    s_Taken <= i_ALUZero_EX;

                when "001" =>  -- BNE
                    s_Taken <= not i_ALUZero_EX;

                when "100" =>  -- BLT (signed)
                    s_Taken <= i_ALUSign_EX;

                when "101" =>  -- BGE (signed)
                    s_Taken <= not i_ALUSign_EX;

                when "110" =>  -- BLTU (unsigned)
                    s_Taken <= not i_ALUCout_EX;

                when "111" =>  -- BGEU (unsigned)
                    s_Taken <= i_ALUCout_EX;

                when others =>
                    s_Taken <= '0';
            end case;
        end if;
    end process;

    --------------------------------------------------------------------------
    -- Flush logic for control hazards
    --   Flush when a branch is taken OR any jump (JAL/JALR) is in EX
    --------------------------------------------------------------------------
    s_Flush <= '1' when (s_Taken = '1' or i_Jump_EX /= "00") else '0';

    o_IFID_Flush  <= s_Flush;
    o_IDEX_Flush  <= s_Flush;

    -- Export branch_taken for PC logic if you want to use it
    o_BranchTaken <= s_Taken;

end rtl;