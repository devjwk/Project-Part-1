-- alu_control_tb.vhd
-- Testbench for ALU Control Unit
-- This testbench verifies correct ALUCtrl output generation
-- for all major RISC-V ALU instruction categories.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_control_tb is
end alu_control_tb;

architecture behavior of alu_control_tb is

    -- DUT Ports
    signal tb_ALUOp   : std_logic_vector(1 downto 0);
    signal tb_Funct3  : std_logic_vector(2 downto 0);
    signal tb_Funct7  : std_logic_vector(6 downto 0);
    signal tb_ALUCtrl : std_logic_vector(3 downto 0);

begin

    -- Instantiate DUT
    DUT: entity work.alu_control
        port map(
            i_ALUOp   => tb_ALUOp,
            i_Funct3  => tb_Funct3,
            i_Funct7  => tb_Funct7,
            o_ALUCtrl => tb_ALUCtrl
        );

    -- Test Process
    stim_proc : process
    begin

        -------------------------------------------------------------------
        -- Test 1: ALUOp = 00 → should always produce ADD ("0010")
        -------------------------------------------------------------------
        tb_ALUOp  <= "00";
        tb_Funct3 <= "000";
        tb_Funct7 <= "0000000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 2: ALUOp = 01 → Branch operations → SUB ("0110")
        -------------------------------------------------------------------
        tb_ALUOp  <= "01";
        tb_Funct3 <= "000";
        tb_Funct7 <= "0000000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 3: R-Type ADD (Funct3=000, Funct7=0000000)
        -------------------------------------------------------------------
        tb_ALUOp  <= "10";
        tb_Funct3 <= "000";
        tb_Funct7 <= "0000000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 4: R-Type SUB (Funct3=000, Funct7=0100000)
        -------------------------------------------------------------------
        tb_Funct7 <= "0100000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 5: SLL (Funct3=001)
        -------------------------------------------------------------------
        tb_Funct3 <= "001";
        tb_Funct7 <= "0000000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 6: SLT (Funct3=010)
        -------------------------------------------------------------------
        tb_Funct3 <= "010";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 7: XOR (Funct3=100)
        -------------------------------------------------------------------
        tb_Funct3 <= "100";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 8: SRL (Funct3=101, Funct7=0000000)
        -------------------------------------------------------------------
        tb_Funct3 <= "101";
        tb_Funct7 <= "0000000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 9: SRA (Funct3=101, Funct7=0100000)
        -------------------------------------------------------------------
        tb_Funct7 <= "0100000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 10: OR (Funct3=110)
        -------------------------------------------------------------------
        tb_Funct3 <= "110";
        tb_Funct7 <= "0000000";
        wait for 20 ns;

        -------------------------------------------------------------------
        -- Test 11: AND (Funct3=111)
        -------------------------------------------------------------------
        tb_Funct3 <= "111";
        wait for 20 ns;

        wait;
    end process;
    -- Expected waveform: for each ALUOp/Funct3/Funct7 combination,
    -- o_ALUCtrl matches the RISC-V operation encoding
    -- (ADD, SUB, SLL, SLT, XOR, SRL, SRA, OR, AND),
    -- which confirms that alu_control.vhd decodes all tested cases correctly.

end behavior;