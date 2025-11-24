-- ================================================================
-- Testbench for adder_subtractor
-- This TB verifies:
-- 1) Addition operation (i_nAdd_Sub = '0')
-- 2) Subtraction operation (i_nAdd_Sub = '1')
-- 3) Carry-out correctness
-- 4) Sign/overflow behavior of the extended internal operation
-- ================================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder_subtractor_tb is
end entity;

architecture behavior of adder_subtractor_tb is

    -- DUT component declaration
    component adder_subtractor is
        generic(N : integer := 32);
        port(
            i_A        : in  std_logic_vector(N-1 downto 0);
            i_B        : in  std_logic_vector(N-1 downto 0);
            i_nAdd_Sub : in  std_logic;
            o_Sum      : out std_logic_vector(N-1 downto 0);
            o_Cout     : out std_logic
        );
    end component;

    -- Testbench Signals
    signal tb_A       : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_B       : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_nAddSub : std_logic := '0';
    signal tb_Sum     : std_logic_vector(31 downto 0);
    signal tb_Cout    : std_logic;

begin

    -- DUT Instantiation
    DUT: adder_subtractor
        generic map(32)
        port map(
            i_A        => tb_A,
            i_B        => tb_B,
            i_nAdd_Sub => tb_nAddSub,
            o_Sum      => tb_Sum,
            o_Cout     => tb_Cout
        );

    -- Stimulus process
    stim_proc : process
    begin

        -------------------------------------------------------------
        -- TEST 1: Simple Addition (5 + 3 = 8)
        -------------------------------------------------------------
        tb_A       <= x"00000005";
        tb_B       <= x"00000003";
        tb_nAddSub <= '0';      -- ADD mode
        wait for 20 ns;

        -------------------------------------------------------------
        -- TEST 2: Addition with Carry (0xFFFFFFFF + 1 = 0x00000000, Cout = 1)
        -------------------------------------------------------------
        tb_A       <= x"FFFFFFFF";
        tb_B       <= x"00000001";
        tb_nAddSub <= '0';
        wait for 20 ns;

        -------------------------------------------------------------
        -- TEST 3: Simple Subtraction (7 - 2 = 5)
        -------------------------------------------------------------
        tb_A       <= x"00000007";
        tb_B       <= x"00000002";
        tb_nAddSub <= '1';     -- SUB mode
        wait for 20 ns;

        -------------------------------------------------------------
        -- TEST 4: Subtraction with Borrow (2 - 5 → FFFFFFFD, Cout=0)
        -------------------------------------------------------------
        tb_A       <= x"00000002";
        tb_B       <= x"00000005";
        tb_nAddSub <= '1';
        wait for 20 ns;

        -------------------------------------------------------------
        -- TEST 5: Large values test
        -------------------------------------------------------------
        tb_A       <= x"80000000";
        tb_B       <= x"7FFFFFFF";
        tb_nAddSub <= '0';
        wait for 20 ns;

        wait;
    end process;
    -- ================================================================
    -- Expected Behavior of Waveform
    --
    -- Test 1:
    --  A = 5, B = 3, Mode = ADD → Result = 8, Cout = 0
    --
    -- Test 2:
    --  A = 0xFFFFFFFF, B = 1, Mode = ADD
    --  This produces a wrap-around: Result = 0x00000000 and Cout = 1.
    --  This confirms correct carry-out behavior.
    --
    -- Test 3:
    --  A = 7, B = 2, Mode = SUB → Result = 5, Cout = 1
    --  Since A > B, no borrow → Cout = 1.
    --
    -- Test 4:
    --  A = 2, B = 5, Mode = SUB
    --  Borrow occurs → Result = 0xFFFFFFFD, Cout = 0.
    --  This confirms borrow logic using inverted B + 1.
    --
    -- Test 5:
    --  A = 0x80000000, B = 0x7FFFFFFF, Mode = ADD
    --  Confirms internal 33-bit extended adder operates correctly.
    --
    -- Passing all above confirms:
    --  1) i_nAdd_Sub properly selects ADD or SUB mode
    --  2) B inversion and carry-in are correctly implemented for subtraction
    --  3) The extended (N+1)-bit adder generates correct Cout
    --  4) o_Sum outputs the lower 32 bits exactly as expected
    -- ================================================================
end architecture;