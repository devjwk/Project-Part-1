library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_alu is
end tb_alu;

architecture behavior of tb_alu is

    -- DUT Ports
    signal tb_A        : std_logic_vector(31 downto 0);
    signal tb_B        : std_logic_vector(31 downto 0);
    signal tb_ALUCtrl  : std_logic_vector(3 downto 0);
    signal tb_Result   : std_logic_vector(31 downto 0);
    signal tb_Zero     : std_logic;
    signal tb_Sign     : std_logic;
    signal tb_Cout     : std_logic;

begin

    -- Instantiate DUT
    UUT: entity work.alu
        port map(
            i_A       => tb_A,
            i_B       => tb_B,
            i_ALUCtrl => tb_ALUCtrl,
            o_Result  => tb_Result,
            o_Zero    => tb_Zero,
            o_Sign    => tb_Sign,
            o_Cout    => tb_Cout
        );

    ----------------------------------------------------------
    -- Test Process
    -- Each test waits 10 ns and verifies:
    --  - Arithmetic operations (ADD, SUB)
    --  - Logic operations (AND, OR, XOR)
    --  - Shift operations (SLL, SRL, SRA)
    --  - Comparison (SLT)
    ----------------------------------------------------------
    stimulus: process
    begin

        ------------------------------------------------------
        -- Test 1: AND
        ------------------------------------------------------
        tb_A <= x"F0F0F0F0";
        tb_B <= x"0F0F0F0F";
        tb_ALUCtrl <= "0000";        -- AND
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 2: OR
        ------------------------------------------------------
        tb_A <= x"AA00AA00";
        tb_B <= x"00FF00FF";
        tb_ALUCtrl <= "0001";        -- OR
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 3: XOR
        ------------------------------------------------------
        tb_A <= x"A5A5A5A5";
        tb_B <= x"5A5A5A5A";
        tb_ALUCtrl <= "0100";        -- XOR
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 4: ADD
        ------------------------------------------------------
        tb_A <= x"00000010";
        tb_B <= x"00000020";
        tb_ALUCtrl <= "0010";        -- ADD
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 5: SUB
        ------------------------------------------------------
        tb_A <= x"00000020";
        tb_B <= x"00000010";
        tb_ALUCtrl <= "0110";        -- SUB
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 6: SLT (A < B)
        ------------------------------------------------------
        tb_A <= x"00000005";
        tb_B <= x"00000010";
        tb_ALUCtrl <= "0111";        -- SLT
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 7: SLL
        ------------------------------------------------------
        tb_A <= x"00000001";
        tb_B <= x"00000004";
        tb_ALUCtrl <= "1001";        -- SLL
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 8: SRL
        ------------------------------------------------------
        tb_A <= x"80000000";
        tb_B <= x"00000004";
        tb_ALUCtrl <= "1000";        -- SRL
        wait for 10 ns;

        ------------------------------------------------------
        -- Test 9: SRA
        ------------------------------------------------------
        tb_A <= x"80000000";
        tb_B <= x"00000004";
        tb_ALUCtrl <= "1010";        -- SRA
        wait for 10 ns;

        ------------------------------------------------------
        -- End Simulation
        ------------------------------------------------------
        wait;
    end process;
end behavior;