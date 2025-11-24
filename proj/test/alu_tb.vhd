library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture sim of alu_tb is
  
    signal tb_A      : std_logic_vector(31 downto 0);
    signal tb_B      : std_logic_vector(31 downto 0);
    signal tb_ALUCtrl: std_logic_vector(3 downto 0);

    signal tb_Result : std_logic_vector(31 downto 0);
    signal tb_Zero   : std_logic;
    signal tb_Sign   : std_logic;
    signal tb_Cout   : std_logic;

begin

    -- Device Under Test
    DUT : entity work.alu
        port map(
            i_A       => tb_A,
            i_B       => tb_B,
            i_ALUCtrl => tb_ALUCtrl,
            o_Result  => tb_Result,
            o_Zero    => tb_Zero,
            o_Sign    => tb_Sign,
            o_Cout    => tb_Cout
        );


    -------------------------------------------------------------------------
    -- STIMULUS
    -------------------------------------------------------------------------
    process
    begin
        ---------------------------------------------------------------------
        -- 1. LOGIC UNIT TESTS
        ---------------------------------------------------------------------
        
        -- AND
        tb_A <= x"F0F0F0F0";
        tb_B <= x"0F0F0F0F";
        tb_ALUCtrl <= "0000";        -- AND
        wait for 10 ns;

        -- OR
        tb_ALUCtrl <= "0001";        -- OR
        wait for 10 ns;

        -- XOR
        tb_ALUCtrl <= "0100";        -- XOR
        wait for 10 ns;


        ---------------------------------------------------------------------
        -- 2. ADDER/SUBTRACTOR TESTS
        ---------------------------------------------------------------------

        -- ADD simple
        tb_A <= x"00000010";
        tb_B <= x"00000020";
        tb_ALUCtrl <= "0010";        -- ADD
        wait for 10 ns;

        -- ADD overflow
        tb_A <= x"FFFFFFFF";
        tb_B <= x"00000001";
        tb_ALUCtrl <= "0010";        -- ADD
        wait for 10 ns;

        -- SUB no borrow
        tb_A <= x"00000010";
        tb_B <= x"00000001";
        tb_ALUCtrl <= "0110";        -- SUB
        wait for 10 ns;

        -- SUB with borrow
        tb_A <= x"00000000";
        tb_B <= x"00000001";
        tb_ALUCtrl <= "0110";        -- SUB
        wait for 10 ns;


        ---------------------------------------------------------------------
        -- 3. SLT TESTS
        ---------------------------------------------------------------------

        -- A < B (negative result → SLT = 1)
        tb_A <= x"FFFFFFF0";   -- -16
        tb_B <= x"00000002";   -- +2
        tb_ALUCtrl <= "0111";  -- SLT
        wait for 10 ns;

        -- A > B (positive result → SLT = 0)
        tb_A <= x"00000010";
        tb_B <= x"00000002";
        tb_ALUCtrl <= "0111";
        wait for 10 ns;


        ---------------------------------------------------------------------
        -- 4. SHIFT UNIT TESTS
        ---------------------------------------------------------------------

        -- SRL: Logical Right
        tb_A <= x"80000000";
        tb_B <= x"00000004";
        tb_ALUCtrl <= "1000";     
        wait for 10 ns;

        -- SLL: Logical Left
        tb_A <= x"00000001";
        tb_B <= x"00000004";
        tb_ALUCtrl <= "1001";     
        wait for 10 ns;

        -- SRA: Arithmetic Right
        tb_A <= x"F0000000";       -- negative, sign should extend
        tb_B <= x"00000004";
        tb_ALUCtrl <= "1010";  
        wait for 10 ns;

        -- SHIFT edge-case: shamt = 0
        tb_A <= x"A5A5A5A5";
        tb_B <= x"00000000";
        tb_ALUCtrl <= "1001";      -- SLL
        wait for 10 ns;

        -- SHIFT edge-case: shamt = 31
        tb_A <= x"80000001";
        tb_B <= x"0000001F";
        tb_ALUCtrl <= "1000";      -- SRL
        wait for 10 ns;


        ---------------------------------------------------------------------
        -- 5. ZERO, SIGN FLAG TESTS
        ---------------------------------------------------------------------

        -- Zero = 1
        tb_A <= x"00000000";
        tb_B <= x"00000000";
        tb_ALUCtrl <= "0010";       -- ADD
        wait for 10 ns;

        -- Sign = 1
        tb_A <= x"FFFFFFFF";        -- negative
        tb_B <= x"00000001";
        tb_ALUCtrl <= "0010";       -- ADD overflow → 0x00000000 + carry
        wait for 10 ns;


        ---------------------------------------------------------------------
        -- END SIMULATION
        ---------------------------------------------------------------------
        report "32-bit ALU comprehensive testbench completed.";
        wait;

    end process;

end sim;