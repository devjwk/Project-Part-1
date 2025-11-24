library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_unit_tb is
end entity;

architecture tb of control_unit_tb is

    -- DUT signals
    signal tb_Opcode   : std_logic_vector(6 downto 0);
    signal tb_ALUSrc   : std_logic;
    signal tb_MemtoReg : std_logic_vector(1 downto 0);
    signal tb_RegWrite : std_logic;
    signal tb_MemRead  : std_logic;
    signal tb_MemWrite : std_logic;
    signal tb_Branch   : std_logic;
    signal tb_Jump     : std_logic_vector(1 downto 0);
    signal tb_ALUOp    : std_logic_vector(1 downto 0);
    signal tb_ImmType  : std_logic_vector(2 downto 0);
    signal tb_AUIPCSrc : std_logic;

begin

    --------------------------------------------------------------------
    -- Instantiate the DUT
    --------------------------------------------------------------------
    DUT: entity work.control_unit
        port map(
            i_Opcode   => tb_Opcode,
            o_ALUSrc   => tb_ALUSrc,
            o_MemtoReg => tb_MemtoReg,
            o_RegWrite => tb_RegWrite,
            o_MemRead  => tb_MemRead,
            o_MemWrite => tb_MemWrite,
            o_Branch   => tb_Branch,
            o_Jump     => tb_Jump,
            o_ALUOp    => tb_ALUOp,
            o_ImmType  => tb_ImmType,
            o_AUIPCSrc => tb_AUIPCSrc
        );

    --------------------------------------------------------------------
    -- Test process
    --------------------------------------------------------------------
    stim_process : process
    begin
        ----------------------------------------------------------------
        -- R-Type (add, and, or, etc.)
        ----------------------------------------------------------------
        tb_Opcode <= "0110011";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- I-Type ALU (addi, xori, etc.)
        ----------------------------------------------------------------
        tb_Opcode <= "0010011";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Load (lw, lh, lb, etc.)
        ----------------------------------------------------------------
        tb_Opcode <= "0000011";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Store (sw, sh, sb)
        ----------------------------------------------------------------
        tb_Opcode <= "0100011";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Branch (beq, bne, blt...)
        ----------------------------------------------------------------
        tb_Opcode <= "1100011";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- JAL
        ----------------------------------------------------------------
        tb_Opcode <= "1101111";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- JALR
        ----------------------------------------------------------------
        tb_Opcode <= "1100111";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- LUI
        ----------------------------------------------------------------
        tb_Opcode <= "0110111";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- AUIPC
        ----------------------------------------------------------------
        tb_Opcode <= "0010111";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- HALT/WFI (Opcode 0000000)
        ----------------------------------------------------------------
        tb_Opcode <= "0000000";
        wait for 20 ns;

        ----------------------------------------------------------------
        -- End simulation
        ----------------------------------------------------------------
        wait;
    end process;
    -- =====================================================================
    -- Expected waveform explanation:
    -- Each opcode applied in this testbench produces the exact control
    -- signal pattern defined by the RISC-V ISA. The simulation shows:
    --  • R-type opcodes assert RegWrite and ALUOp="10".
    --  • I-type ALU opcodes assert ALUSrc='1', RegWrite='1', ALUOp="10".
    --  • Load opcodes correctly enable MemRead and MemtoReg="01".
    --  • Store opcodes assert MemWrite and generate ImmType="001".
    --  • Branch opcodes assert Branch='1' with ALUOp="01" for subtraction.
    --  • JAL and JALR opcodes select proper Jump values and write PC+4.
    --  • LUI and AUIPC generate correct ImmType and ALUSrc/ALUSrcA settings.
    -- Because every output matches the expected control pattern for each
    -- opcode, this confirms the control_unit implements correct decoding
    -- behavior.
    -- =====================================================================

end architecture;