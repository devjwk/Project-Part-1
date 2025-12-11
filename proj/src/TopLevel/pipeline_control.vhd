pipeline control:


library IEEE;
use IEEE.std_logic_1164.all;

entity pipeline_control is
    port(
        ----------------------------------------------------------------
        -- From hazard_detection_unit (load-use)
        ----------------------------------------------------------------
        i_PCWrite_LU    : in std_logic;  -- from o_PCWrite
        i_IFID_Write_LU : in std_logic;  -- from o_IFID_Write
        i_IDEX_Flush_LU : in std_logic;  -- from o_IDEX_Flush

        ----------------------------------------------------------------
        -- From control_hazard_unit (branches / jumps)
        ----------------------------------------------------------------
        i_IFID_Flush_CH : in std_logic;
        i_IDEX_Flush_CH : in std_logic;

        ----------------------------------------------------------------
        -- Final outputs to datapath
        ----------------------------------------------------------------
        o_PCWrite       : out std_logic; -- connect to pc_reg.i_WE
        o_IFID_Stall    : out std_logic; -- connect to if_id_reg.i_Stall
        o_IFID_Flush    : out std_logic; -- connect to if_id_reg.i_Flush
        o_IDEX_Flush    : out std_logic  -- connect to id_ex_reg.i_Flush
    );
end pipeline_control;

architecture rtl of pipeline_control is
begin

    ----------------------------------------------------------------
    -- PC write:
    -- Only load-use hazards stall PC. Control hazards should NOT
    -- freeze PC; PC is already set to the correct target.
    ----------------------------------------------------------------
    o_PCWrite <= i_PCWrite_LU;

    ----------------------------------------------------------------
    -- IF/ID write (stall):
    -- Only load-use hazards stall IF/ID. Control hazards use flush,
    -- not stall.
    ----------------------------------------------------------------
    o_IFID_Stall <= not i_IFID_Write_LU;  -- 1 = hold IF/ID reg

    ----------------------------------------------------------------
    -- IF/ID flush:
    -- Only control hazards flush the instruction in ID.
    ----------------------------------------------------------------
    o_IFID_Flush <= i_IFID_Flush_CH;

    ----------------------------------------------------------------
    -- ID/EX flush:
    -- Either a load-use hazard OR a control hazard should turn the
    -- instruction in EX into a bubble.
    ----------------------------------------------------------------
    o_IDEX_Flush <= i_IDEX_Flush_LU or i_IDEX_Flush_CH;

end rtl;






pipeline control testbench:


library IEEE;
use IEEE.std_logic_1164.all;

entity tb_pipeline_control is
end tb_pipeline_control;

architecture sim of tb_pipeline_control is

    -- Inputs from hazard_detection_unit (load-use)
    signal i_PCWrite_LU    : std_logic := '1';
    signal i_IFID_Write_LU : std_logic := '1';
    signal i_IDEX_Flush_LU : std_logic := '0';

    -- Inputs from control_hazard_unit (branches/jumps)
    signal i_IFID_Flush_CH : std_logic := '0';
    signal i_IDEX_Flush_CH : std_logic := '0';

    -- Outputs to datapath
    signal o_PCWrite    : std_logic;
    signal o_IFID_Stall : std_logic;
    signal o_IFID_Flush : std_logic;
    signal o_IDEX_Flush : std_logic;

begin

    --------------------------------------------------------------------
    -- DUT instance
    --------------------------------------------------------------------
    DUT : entity work.pipeline_control
        port map(
            i_PCWrite_LU    => i_PCWrite_LU,
            i_IFID_Write_LU => i_IFID_Write_LU,
            i_IDEX_Flush_LU => i_IDEX_Flush_LU,
            i_IFID_Flush_CH => i_IFID_Flush_CH,
            i_IDEX_Flush_CH => i_IDEX_Flush_CH,
            o_PCWrite       => o_PCWrite,
            o_IFID_Stall    => o_IFID_Stall,
            o_IFID_Flush    => o_IFID_Flush,
            o_IDEX_Flush    => o_IDEX_Flush
        );

    --------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- Case 1: No hazards
        --  - load-use: none  (PCWrite_LU=1, IFID_Write_LU=1, IDEX_Flush_LU=0)
        --  - control: none   (IFID_Flush_CH=0, IDEX_Flush_CH=0)
        ----------------------------------------------------------------
        i_PCWrite_LU    <= '1';
        i_IFID_Write_LU <= '1';
        i_IDEX_Flush_LU <= '0';
        i_IFID_Flush_CH <= '0';
        i_IDEX_Flush_CH <= '0';
        wait for 20 ns;
        -- Expect: o_PCWrite=1, o_IFID_Stall=0, o_IFID_Flush=0, o_IDEX_Flush=0

        ----------------------------------------------------------------
        -- Case 2: Load-use hazard only
        --  - stall PC and IF/ID, flush ID/EX
        ----------------------------------------------------------------
        i_PCWrite_LU    <= '0';  -- stall PC
        i_IFID_Write_LU <= '0';  -- stall IF/ID
        i_IDEX_Flush_LU <= '1';  -- bubble in EX
        i_IFID_Flush_CH <= '0';
        i_IDEX_Flush_CH <= '0';
        wait for 20 ns;
        -- Expect: o_PCWrite=0, o_IFID_Stall=1, o_IFID_Flush=0, o_IDEX_Flush=1

        ----------------------------------------------------------------
        -- Case 3: Control hazard only (taken branch / jump)
        --  - no stall, but flush IF/ID and ID/EX
        ----------------------------------------------------------------
        i_PCWrite_LU    <= '1';
        i_IFID_Write_LU <= '1';
        i_IDEX_Flush_LU <= '0';
        i_IFID_Flush_CH <= '1';
        i_IDEX_Flush_CH <= '1';
        wait for 20 ns;
        -- Expect: o_PCWrite=1, o_IFID_Stall=0, o_IFID_Flush=1, o_IDEX_Flush=1

        ----------------------------------------------------------------
        -- Case 4: Both load-use and control hazard simultaneously
        --  - stall PC + IF/ID (from load-use)
        --  - ID/EX flush because of either
        --  - IF/ID flush asserted from control hazard
        ----------------------------------------------------------------
        i_PCWrite_LU    <= '0';
        i_IFID_Write_LU <= '0';
        i_IDEX_Flush_LU <= '1';
        i_IFID_Flush_CH <= '1';
        i_IDEX_Flush_CH <= '1';
        wait for 20 ns;
        -- Expect: o_PCWrite=0, o_IFID_Stall=1, o_IFID_Flush=1, o_IDEX_Flush=1

        wait;
    end process;

end sim;