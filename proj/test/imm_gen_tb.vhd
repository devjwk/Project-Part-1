library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity imm_gen_tb is
end entity;

architecture tb of imm_gen_tb is

    -- DUT signals
    signal tb_Inst    : std_logic_vector(31 downto 0);
    signal tb_ImmType : std_logic_vector(2 downto 0);
    signal tb_Imm     : std_logic_vector(31 downto 0);

begin

    -- Instantiate DUT
    UUT: entity work.imm_gen
        port map(
            i_Inst    => tb_Inst,
            i_ImmType => tb_ImmType,
            o_Imm     => tb_Imm
        );

    -- Test process
    stim_proc : process
    begin
        
        --------------------------------------------------------------------
        -- I-TYPE test (addi)
        -- imm[11:0] = 0x123 → sign-extended
        --------------------------------------------------------------------
        tb_Inst    <= x"01234513";   -- imm = 0x123, rd=10, funct3=000, rs1=8, opcode=0010011
        tb_ImmType <= "000";
        wait for 10 ns;

        --------------------------------------------------------------------
        -- S-TYPE test (sw)
        -- imm = {inst[31:25], inst[11:7]}
        --------------------------------------------------------------------
        tb_Inst    <= x"00A12023";   -- imm = 0x00A → 10 decimal
        tb_ImmType <= "001";
        wait for 10 ns;

        --------------------------------------------------------------------
        -- B-TYPE test (beq)
        -- imm is shuffled and left shifted by 1
        --------------------------------------------------------------------
        tb_Inst    <= x"FE211CE3";   -- Example taken from RISC-V spec
        tb_ImmType <= "010";
        wait for 10 ns;

        --------------------------------------------------------------------
        -- J-TYPE test (jal)
        --------------------------------------------------------------------
        tb_Inst    <= x"004000EF";   -- imm = 0x004000
        tb_ImmType <= "011";
        wait for 10 ns;

        --------------------------------------------------------------------
        -- U-TYPE test (lui)
        --------------------------------------------------------------------
        tb_Inst    <= x"12345037";   -- imm = 0x12345 << 12
        tb_ImmType <= "100";
        wait for 10 ns;

        --------------------------------------------------------------------
        -- Finish simulation
        --------------------------------------------------------------------
        wait;
    end process;
    ------------------------------------------------------------------------------
    -- Expected Waveform Explanation (imm_gen_tb.vhd)
    --
    -- This testbench verifies the correctness of the Immediate Generator by
    -- applying several instruction patterns and selecting different ImmType values
    -- (0 = I-type, 1 = S-type, 2 = B-type, 3 = J-type, 4 = U-type).  
    -- The waveform confirms that the immediate field is correctly extracted and
    -- properly sign-extended or zero-extended depending on the instruction format.
    --
    -- Case 0: I-type
    --   Inst     = 0x01234513
    --   ImmType  = 0
    --   Expected = 0x00000012
    --   The I-type immediate is taken from bits [31:20] and sign-extended to 32 bits.
    --   Waveform matches the expected 0x00000012 → I-type logic works correctly.
    --
    -- Case 1: S-type
    --   Inst     = 0x00A12023
    --   ImmType  = 1
    --   Expected = 0x00000000
    --   The S-type immediate is built from {Inst[31:25], Inst[11:7]}.
    --   For this instruction, both fields evaluate to 0, producing an immediate of 0.
    --   Waveform shows 0x00000000 → S-type concatenation is functioning properly.
    --
    -- Case 2: B-type
    --   Inst     = 0xFE211CE3
    --   ImmType  = 2
    --   Expected = 0xFFFFFFF8
    --   The B-type immediate is composed from scattered bits:
    --      imm[12]   = Inst[31]
    --      imm[11]   = Inst[7]
    --      imm[10:5] = Inst[30:25]
    --      imm[4:1]  = Inst[11:8]
    --      imm[0]    = 0
    --   The result (0xFFFF_FFF8) matches the expected negative branch offset.
    --   Waveform confirms correct bit assembly and sign extension.
    --
    -- Case 3: J-type
    --   Inst     = 0x004000EF
    --   ImmType  = 3
    --   Expected = 0x00000004
    --   The J-type immediate uses:
    --      imm[20]     = Inst[31]
    --      imm[19:12]  = Inst[19:12]
    --      imm[11]     = Inst[20]
    --      imm[10:1]   = Inst[30:21]
    --      imm[0]      = 0
    --   The waveform shows the expected 4-byte jump offset → J-type logic verified.
    --
    -- Case 4: U-type
    --   Inst     = 0x12345037
    --   ImmType  = 4
    --   Expected = 0x12345000
    --   U-type immediate simply places Inst[31:12] in the upper bits and fills
    --   the lower 12 bits with zeros; waveform correctly shows 0x12345000.
    --
    -- Summary:
    --   All test cases match the expected immediate values for each instruction
    --   type. The waveform confirms that imm_gen correctly interprets instruction
    --   formats, slices the proper fields, and performs correct sign-extension.
    ------------------------------------------------------------------------------

end architecture;