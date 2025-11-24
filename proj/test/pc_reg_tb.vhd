library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pc_reg_tb is
end pc_reg_tb;

architecture behavior of pc_reg_tb is

    -- DUT component declaration
    component pc_reg 
        generic(N : integer := 32);
        port(
            i_CLK    : in std_logic;
            i_RST    : in std_logic;
            i_WE     : in std_logic;
            i_NextPC : in std_logic_vector(N-1 downto 0);
            o_PC     : out std_logic_vector(N-1 downto 0)
        );
    end component;

    -- Testbench signals
    signal tb_CLK    : std_logic := '0';
    signal tb_RST    : std_logic := '0';
    signal tb_WE     : std_logic := '1';
    signal tb_NextPC : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_PC     : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- Clock generation (50 MHz equivalent)
    --------------------------------------------------------------------
    clk_process : process
    begin
        tb_CLK <= '0';
        wait for CLK_PERIOD/2;
        tb_CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    --------------------------------------------------------------------
    -- Instantiate the DUT
    --------------------------------------------------------------------
    DUT_PC : pc_reg 
        port map(
            i_CLK    => tb_CLK,
            i_RST    => tb_RST,
            i_WE     => tb_WE,
            i_NextPC => tb_NextPC,
            o_PC     => tb_PC
        );

    --------------------------------------------------------------------
    -- Test sequence
    --------------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- Test 1: Apply reset, PC should become 0
        ----------------------------------------------------------------
        tb_RST <= '1';
        tb_NextPC <= x"00000020";
        wait for 2*CLK_PERIOD;

        tb_RST <= '0';
        wait for CLK_PERIOD;

        ----------------------------------------------------------------
        -- Test 2: Normal PC update
        ----------------------------------------------------------------
        tb_NextPC <= x"00000004";
        wait for CLK_PERIOD;

        tb_NextPC <= x"00000008";
        wait for CLK_PERIOD;

        tb_NextPC <= x"0000000C";
        wait for CLK_PERIOD;

        ----------------------------------------------------------------
        -- Test 3: Write Enable OFF — PC should hold previous value
        ----------------------------------------------------------------
        tb_WE <= '0';
        tb_NextPC <= x"00000020";
        wait for CLK_PERIOD;

        ----------------------------------------------------------------
        -- Test 4: Enable Write again
        ----------------------------------------------------------------
        tb_WE <= '1';
        tb_NextPC <= x"00000040";
        wait for CLK_PERIOD;

        ----------------------------------------------------------------
        -- End simulation
        ----------------------------------------------------------------
        wait for 50 ns;
        assert false report "Simulation finished." severity failure;
    end process;
        -- Expected Behavior Explanation
        -- 
        -- During RESET = '1', the PC output must immediately become 0x00000000,
        -- regardless of the clock. This confirms the asynchronous reset logic works.
        --
        -- After RESET goes low and WE = '1', the PC must update to i_NextPC only on
        -- rising edges of the clock. This verifies the synchronous write behavior.
        --
        -- In this test scenario, i_NextPC increases by 4 every cycle (0x0, 0x4, 0x8, ...).
        -- Therefore, PC should show 0x00000000 during reset, and after reset is
        -- released, PC should update sequentially to 0x00000004, 0x00000008,
        -- 0x0000000C, ... at each rising clock edge.
        --
        -- If the waveform matches these expected transitions, it confirms that:
        -- 1) Asynchronous reset is functioning correctly.
        -- 2) PC updates only on rising edges (synchronous write).
        -- 3) Write enable correctly allows updates.
        --
        -- Therefore, matching this waveform demonstrates that pc_reg.vhd works correctly.

end behavior;