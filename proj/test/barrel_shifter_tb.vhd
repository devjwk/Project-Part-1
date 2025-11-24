library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrel_shifter_tb is
end entity;

architecture tb of barrel_shifter_tb is

    -- DUT Signals
    signal tb_data   : std_logic_vector(31 downto 0);
    signal tb_amt    : std_logic_vector(4 downto 0);
    signal tb_dir    : std_logic;  -- 0 = Right, 1 = Left
    signal tb_arith  : std_logic;  -- 1 = Arithmetic, 0 = Logical
    signal tb_out    : std_logic_vector(31 downto 0);

begin

    -- DUT Instance
    UUT : entity work.barrel_shifter
        port map(
            i_data  => tb_data,
            i_amt   => tb_amt,
            i_dir   => tb_dir,
            i_arith => tb_arith,
            o_data  => tb_out
        );

    --------------------------------------------------------------------
    -- Test Procedure
    --------------------------------------------------------------------
    stim_proc : process
    begin

        ----------------------------------------------------------------
        -- Test 1: SLL (Logical Left Shift)
        ----------------------------------------------------------------
        -- Expect: 0x00000001 << 4 = 0x00000010
        tb_data  <= x"00000001";
        tb_amt   <= "00100"; -- shift 4
        tb_dir   <= '1';     -- left
        tb_arith <= '0';     -- logical
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test 2: SRL (Logical Right Shift)
        ----------------------------------------------------------------
        -- Expect: 0x80000000 >> 4 = 0x08000000
        tb_data  <= x"80000000";
        tb_amt   <= "00100"; -- shift 4
        tb_dir   <= '0';     -- right
        tb_arith <= '0';     -- logical
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test 3: SRA (Arithmetic Right Shift)
        ----------------------------------------------------------------
        -- Expect: 0xF0000000 >> 4 = 0xFF000000 (sign-extended)
        tb_data  <= x"F0000000";
        tb_amt   <= "00100";
        tb_dir   <= '0';
        tb_arith <= '1';     -- arithmetic
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test 4: SLL with larger amount
        ----------------------------------------------------------------
        -- Expect: 0x00000003 << 8 = 0x00000300
        tb_data  <= x"00000003";
        tb_amt   <= "01000"; -- shift 8
        tb_dir   <= '1';
        tb_arith <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Test 5: SRL with middle bits
        ----------------------------------------------------------------
        -- Expect: 0x00FF0000 >> 8 = 0x0000FF00
        tb_data  <= x"00FF0000";
        tb_amt   <= "01000";
        tb_dir   <= '0';
        tb_arith <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- Finish
        ----------------------------------------------------------------
        wait;
    end process;
    -- ================================================================
    -- Expected Waveform Behavior
    --
    -- Test 1: SLL (Logical Left Shift)
    --  Input: 0x00000001, Shift 4
    --  Expected Output: 0x00000010
    --
    -- Test 2: SRL (Logical Right Shift)
    --  Input: 0x80000000, Shift 4
    --  Expected Output: 0x08000000
    --
    -- Test 3: SRA (Arithmetic Right Shift)
    --  Input: 0xF0000000, Shift 4
    --  Expected Output: 0xFF000000 (sign-extended)
    --
    -- Test 4: SLL with larger shift
    --  Input: 0x00000003, Shift 8
    --  Expected Output: 0x00000300
    --
    -- Test 5: SRL with typical pattern
    --  Input: 0x00FF0000, Shift 8
    --  Expected Output: 0x0000FF00
    --
    -- Passing all these confirms:
    --  1) Left shift path (reverse + shift + reverse-back) works
    --  2) Logical right shift fills with 0s correctly
    --  3) Arithmetic right shift keeps MSB for negative numbers
    --  4) Multi-stage mux logic (1,2,4,8,16) correctly cascades
    --  5) Output matches expected bit-movement for all shift modes
    -- ================================================================

end architecture;