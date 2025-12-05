-------------------------------------------------------------------------
-- MEM/WB Pipeline Register
--  - Latches MEM stage results and control signals into WB stage
--  - Supports STALL and FLUSH (squash) for hazard control
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_wb_reg is
    port(
        i_CLK        : in  std_logic;                      -- Clock
        i_RST        : in  std_logic;                      -- Reset (High Active)

        -- New pipeline control signals
        i_Stall      : in  std_logic;                      -- 1 = hold current values
        i_Flush      : in  std_logic;                      -- 1 = insert bubble (NOP)

        -- From MEM stage (inputs)
        i_PC         : in  std_logic_vector(31 downto 0);  -- PC associated with this instruction
        i_ALUResult  : in  std_logic_vector(31 downto 0);  -- ALU result
        i_LoadData   : in  std_logic_vector(31 downto 0);  -- load_extender output
        i_Imm        : in  std_logic_vector(31 downto 0);  -- immediate (for LUI/AUIPC)
        i_Rd         : in  std_logic_vector(4 downto 0);   -- destination register

        i_Halt       : in  std_logic;

        -- Control signals from MEM (originated in ID)
        i_RegWrite   : in  std_logic;                      -- writeback enable
        i_MemtoReg   : in  std_logic_vector(1 downto 0);   -- WB mux select

        -- To WB stage (outputs)
        o_PC         : out std_logic_vector(31 downto 0);
        o_ALUResult  : out std_logic_vector(31 downto 0);
        o_LoadData   : out std_logic_vector(31 downto 0);
        o_Imm        : out std_logic_vector(31 downto 0);
        o_Rd         : out std_logic_vector(4 downto 0);

        o_RegWrite   : out std_logic;
        o_MemtoReg   : out std_logic_vector(1 downto 0);

        o_Halt       : out std_logic
    );
end mem_wb_reg;

architecture behavior of mem_wb_reg is

    -- Datapath registers
    signal s_PC_reg        : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ALUResult_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal s_LoadData_reg  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Imm_reg       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Rd_reg        : std_logic_vector(4 downto 0)  := (others => '0');

    -- Control registers
    signal s_RegWrite_reg  : std_logic := '0';
    signal s_MemtoReg_reg  : std_logic_vector(1 downto 0) := (others => '0');

    signal s_Halt_reg      : std_logic := '0';

begin

    process(i_CLK, i_RST)
    begin
        if (i_RST = '1') then
            -- Reset: clear everything to a "safe NOP" state
            s_PC_reg        <= (others => '0');
            s_ALUResult_reg <= (others => '0');
            s_LoadData_reg  <= (others => '0');
            s_Imm_reg       <= (others => '0');
            s_Rd_reg        <= (others => '0');

            s_RegWrite_reg  <= '0';
            s_MemtoReg_reg  <= (others => '0');

            s_Halt_reg      <= '0';

        elsif rising_edge(i_CLK) then
            -- Priority: FLUSH > STALL > NORMAL
            if (i_Flush = '1') then
                -- FLUSH: insert bubble so WB stage does nothing
                s_PC_reg        <= (others => '0');
                s_ALUResult_reg <= (others => '0');
                s_LoadData_reg  <= (others => '0');
                s_Imm_reg       <= (others => '0');
                s_Rd_reg        <= (others => '0');

                s_RegWrite_reg  <= '0';                  -- no writeback
                s_MemtoReg_reg  <= (others => '0');      -- don't-care, set 0

                s_Halt_reg      <= '0';

            elsif (i_Stall = '1') then
                -- STALL: hold current contents (do nothing)
                s_PC_reg        <= s_PC_reg;
                s_ALUResult_reg <= s_ALUResult_reg;
                s_LoadData_reg  <= s_LoadData_reg;
                s_Imm_reg       <= s_Imm_reg;
                s_Rd_reg        <= s_Rd_reg;

                s_RegWrite_reg  <= s_RegWrite_reg;
                s_MemtoReg_reg  <= s_MemtoReg_reg;

                s_Halt_reg      <= s_Halt_reg;

            else
                -- Normal pipeline flow: latch MEM outputs into MEM/WB register
                s_PC_reg        <= i_PC;
                s_ALUResult_reg <= i_ALUResult;
                s_LoadData_reg  <= i_LoadData;
                s_Imm_reg       <= i_Imm;
                s_Rd_reg        <= i_Rd;

                s_RegWrite_reg  <= i_RegWrite;
                s_MemtoReg_reg  <= i_MemtoReg;

                s_Halt_reg      <= i_Halt;
            end if;
        end if;
    end process;

    -- Drive outputs to WB stage
    o_PC        <= s_PC_reg;
    o_ALUResult <= s_ALUResult_reg;
    o_LoadData  <= s_LoadData_reg;
    o_Imm       <= s_Imm_reg;
    o_Rd        <= s_Rd_reg;

    o_RegWrite  <= s_RegWrite_reg;
    o_MemtoReg  <= s_MemtoReg_reg;

    o_Halt      <= s_Halt_reg;

end behavior;