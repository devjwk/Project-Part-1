-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor
-- implementation.
-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- Integrated & Fixed by Assistant
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
    generic(N : integer := DATA_WIDTH);
    port(
        iCLK      : in std_logic;
        iRST      : in std_logic;
        iInstLd   : in std_logic;
        iInstAddr : in std_logic_vector(N-1 downto 0);
        iInstExt  : in std_logic_vector(N-1 downto 0);
        oALUOut   : out std_logic_vector(N-1 downto 0)
    );
end RISCV_Processor;

architecture structure of RISCV_Processor is

    -- [1] Required data memory signals (Skeleton Compliance)
    signal s_DMemWr   : std_logic; 
    signal s_DMemAddr : std_logic_vector(N-1 downto 0); 
    signal s_DMemData : std_logic_vector(N-1 downto 0); 
    signal s_DMemOut  : std_logic_vector(N-1 downto 0); 
    
    -- [2] Required register file signals (Skeleton Compliance)
    signal s_RegWr     : std_logic; 
    signal s_RegWrAddr : std_logic_vector(4 downto 0); 
    signal s_RegWrData : std_logic_vector(N-1 downto 0); 

    -- [3] Required instruction memory signals
    signal s_IMemAddr     : std_logic_vector(N-1 downto 0); 
    signal s_NextInstAddr : std_logic_vector(N-1 downto 0); 
    signal s_Inst         : std_logic_vector(N-1 downto 0); 

    -- IF/ID pipelined
    signal s_PC_ID       : std_logic_vector(31 downto 0); -- PC seen by ID
    signal s_Inst_ID     : std_logic_vector(N-1 downto 0); -- Instruction seen by ID

    -- [4] Required halt & overflow signals
    signal s_Halt : std_logic; 
    signal s_Ovfl : std_logic; 

    -- [5] Internal Control & Data Signals (User Logic)
    signal s_CurrentPC : std_logic_vector(31 downto 0);
    
    signal s_Funct3    : std_logic_vector(2 downto 0);
    signal s_Funct7    : std_logic_vector(6 downto 0);
    
    signal s_MemRead   : std_logic;
    -- s_MemWrite is mapped to s_DMemWr
    signal s_Branch    : std_logic;
    signal s_Jump      : std_logic_vector(1 downto 0);
    
    signal s_ALUSrcA   : std_logic;
    signal s_ALUSrcB   : std_logic;
    signal s_MemtoReg  : std_logic_vector(1 downto 0);
    signal s_ALUOp     : std_logic_vector(1 downto 0);
    signal s_ImmType   : std_logic_vector(2 downto 0);
    
    signal s_ReadData1 : std_logic_vector(31 downto 0);
    -- s_ReadData2 is mapped to s_DMemData
    
    signal s_Imm       : std_logic_vector(31 downto 0);
    signal s_ALUCtrl   : std_logic_vector(3 downto 0);
    
    signal s_ALUInputA : std_logic_vector(31 downto 0);
    signal s_ALUInputB : std_logic_vector(31 downto 0);
    signal s_ALUResult : std_logic_vector(31 downto 0); -- Internal ALU Result
    
    signal s_Zero      : std_logic;
    signal s_Sign      : std_logic;
    signal s_Cout      : std_logic;

    -- ID/EX pipeline signals
    signal s_ReadData2 : std_logic_vector(31 downto 0);
    signal s_LoadData : std_logic_vector(31 downto 0);
    signal s_ByteOffset : std_logic_vector(1 downto 0);

    signal s_PC_EX        : std_logic_vector(31 downto 0);
    signal s_ReadData1_EX : std_logic_vector(31 downto 0);
    signal s_ReadData2_EX : std_logic_vector(31 downto 0);
    signal s_Imm_EX       : std_logic_vector(31 downto 0);
    signal s_Funct3_EX    : std_logic_vector(2 downto 0);
    signal s_Funct7_EX    : std_logic_vector(6 downto 0);
    signal s_Rd_EX        : std_logic_vector(4 downto 0);

    signal s_MemRead_EX   : std_logic;
    signal s_MemWrite_EX  : std_logic;
    signal s_RegWrite_EX  : std_logic;
    signal s_MemtoReg_EX  : std_logic_vector(1 downto 0);
    signal s_ALUSrcA_EX   : std_logic;
    signal s_ALUSrcB_EX   : std_logic;
    signal s_ALUOp_EX     : std_logic_vector(1 downto 0);
    signal s_Branch_EX    : std_logic;
    signal s_Jump_EX      : std_logic_vector(1 downto 0);

    -- EX/MEM pipeline signals
    signal s_PC_MEM        : std_logic_vector(31 downto 0);
    signal s_ALUResult_MEM : std_logic_vector(31 downto 0);
    signal s_ReadData2_MEM : std_logic_vector(31 downto 0);  -- store data
    signal s_Funct3_MEM    : std_logic_vector(2 downto 0);
    signal s_Rd_MEM        : std_logic_vector(4 downto 0);

    signal s_MemRead_MEM   : std_logic;
    signal s_MemWrite_MEM  : std_logic;
    signal s_RegWrite_MEM  : std_logic;
    signal s_MemtoReg_MEM  : std_logic_vector(1 downto 0);
    signal s_Branch_MEM    : std_logic;                      -- actually not used in MEM much

    -- MEM/WB pipeline signals
    signal s_PC_WB        : std_logic_vector(31 downto 0);
    signal s_ALUResult_WB : std_logic_vector(31 downto 0);
    signal s_LoadData_WB  : std_logic_vector(31 downto 0);
    signal s_Imm_MEM      : std_logic_vector(31 downto 0); -- from EX/MEM 
    signal s_Imm_WB       : std_logic_vector(31 downto 0);
    signal s_Rd_WB        : std_logic_vector(4 downto 0);

    signal s_RegWrite_WB  : std_logic;
    signal s_MemtoReg_WB  : std_logic_vector(1 downto 0);

    --halt flags
    signal s_Halt_ID  : std_logic;
    signal s_Halt_EX  : std_logic;
    signal s_Halt_MEM : std_logic;
    signal s_Halt_WB  : std_logic;

    -- ======================================================================
    -- Component Declarations
    -- ======================================================================

    -- 1. Memory (Provided by Skeleton)
    component mem is
        generic(
            ADDR_WIDTH : integer;
            DATA_WIDTH : integer
        );
        port(
            clk  : in std_logic;
            addr : in std_logic_vector((ADDR_WIDTH-1) downto 0);
            data : in std_logic_vector((DATA_WIDTH-1) downto 0);
            we   : in std_logic := '1';
            q    : out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;

    -- 2. Control Unit
    component control_unit is
        port(
            i_Opcode   : in  std_logic_vector(6 downto 0);
            o_ALUSrc   : out std_logic;
            o_MemtoReg : out std_logic_vector(1 downto 0);
            o_RegWrite : out std_logic;
            o_MemRead  : out std_logic;
            o_MemWrite : out std_logic;
            o_Branch   : out std_logic;
            o_Jump     : out std_logic_vector(1 downto 0);
            o_ALUOp    : out std_logic_vector(1 downto 0);
            o_ImmType  : out std_logic_vector(2 downto 0);
            o_AUIPCSrc : out std_logic
        );
    end component;

    -- 3. Register File
    -- NOTE: Ensure your regfile.vhd entity name is 'regfile'
    component reg_file is
        port(
            i_CLK    : in  std_logic;
            i_RST    : in  std_logic;
            i_WE     : in  std_logic;
            i_WADDR  : in  std_logic_vector(4 downto 0);
            i_WDATA  : in  std_logic_vector(31 downto 0);
            i_RADDR1 : in  std_logic_vector(4 downto 0);
            i_RADDR2 : in  std_logic_vector(4 downto 0);
            o_RDATA1 : out std_logic_vector(31 downto 0);
            o_RDATA2 : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 4. ALU
    component alu is
        port(
            i_A        : in  std_logic_vector(31 downto 0);
            i_B        : in  std_logic_vector(31 downto 0);
            i_ALUCtrl  : in  std_logic_vector(3 downto 0); 
            o_Result   : out std_logic_vector(31 downto 0);
            o_Zero     : out std_logic;
            o_Sign     : out std_logic; 
            o_Cout     : out std_logic  
        );
    end component;

    -- 5. ALU Control
    component alu_control is
        port(
            i_ALUOp   : in  std_logic_vector(1 downto 0);
            i_Funct3  : in  std_logic_vector(2 downto 0);
            i_Funct7  : in  std_logic_vector(6 downto 0);
            o_ALUCtrl : out std_logic_vector(3 downto 0)
        );
    end component;

    -- 6. Fetch Logic
    component fetch_logic is
        generic(N : integer := 32);
        port(
            i_PC        : in std_logic_vector(N-1 downto 0); 
            i_Imm       : in std_logic_vector(N-1 downto 0); 
            i_RS1       : in std_logic_vector(N-1 downto 0); 
            i_Branch    : in std_logic;                      
            i_Jump      : in std_logic_vector(1 downto 0);   
            i_Funct3    : in std_logic_vector(2 downto 0);   
            i_ALUZero   : in std_logic;                      
            i_ALUSign   : in std_logic;                      
            i_ALUCout   : in std_logic;                      
            o_NextPC    : out std_logic_vector(N-1 downto 0) 
        );
    end component;

    -- 7. Immediate Generator
    component imm_gen is
        port(
            i_Inst    : in  std_logic_vector(31 downto 0);
            i_ImmType : in  std_logic_vector(2 downto 0);
            o_Imm     : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 8. PC Register
    component pc_reg is
        port(
            i_CLK    : in  std_logic;
            i_RST    : in  std_logic;
            i_WE     : in  std_logic;
            i_NextPC : in  std_logic_vector(31 downto 0);
            o_PC     : out std_logic_vector(31 downto 0)
        );
    end component;
    component load_extender is
    port(
        i_DMemOut : in  std_logic_vector(31 downto 0);
        i_Funct3  : in  std_logic_vector(2 downto 0);
        i_AddrLSB : in  std_logic_vector(1 downto 0);
        o_ReadData: out std_logic_vector(31 downto 0)
    );
    end component;
    -- 9. IF/ID pipeline register
    component if_id_reg is
    port(
        i_CLK  : in  std_logic;
        i_RST  : in  std_logic;
        i_PC   : in  std_logic_vector(31 downto 0);
        i_Inst : in  std_logic_vector(31 downto 0);
        o_PC   : out std_logic_vector(31 downto 0);
        o_Inst : out std_logic_vector(31 downto 0)
    );
    end component;
    -- 10. ID/EX pipeline register
    component id_ex_reg is
    port(
        i_CLK       : in  std_logic;
        i_RST       : in  std_logic;

        -- From ID stage
        i_PC        : in  std_logic_vector(31 downto 0);
        i_ReadData1 : in  std_logic_vector(31 downto 0);
        i_ReadData2 : in  std_logic_vector(31 downto 0);
        i_Imm       : in  std_logic_vector(31 downto 0);
        i_Funct3    : in  std_logic_vector(2 downto 0);
        i_Funct7    : in  std_logic_vector(6 downto 0);
        i_Rd        : in  std_logic_vector(4 downto 0);

        i_MemRead   : in  std_logic;
        i_MemWrite  : in  std_logic;
        i_RegWrite  : in  std_logic;
        i_MemtoReg  : in  std_logic_vector(1 downto 0);
        i_ALUSrcA   : in  std_logic;
        i_ALUSrcB   : in  std_logic;
        i_ALUOp     : in  std_logic_vector(1 downto 0);
        i_Branch    : in  std_logic;
        i_Jump      : in  std_logic_vector(1 downto 0);
        i_Halt      : in  std_logic;

        -- To EX stage
        o_PC        : out std_logic_vector(31 downto 0);
        o_ReadData1 : out std_logic_vector(31 downto 0);
        o_ReadData2 : out std_logic_vector(31 downto 0);
        o_Imm       : out std_logic_vector(31 downto 0);
        o_Funct3    : out std_logic_vector(2 downto 0);
        o_Funct7    : out std_logic_vector(6 downto 0);
        o_Rd        : out std_logic_vector(4 downto 0);

        o_MemRead   : out std_logic;
        o_MemWrite  : out std_logic;
        o_RegWrite  : out std_logic;
        o_MemtoReg  : out std_logic_vector(1 downto 0);
        o_ALUSrcA   : out std_logic;
        o_ALUSrcB   : out std_logic;
        o_ALUOp     : out std_logic_vector(1 downto 0);
        o_Branch    : out std_logic;
        o_Jump      : out std_logic_vector(1 downto 0);
        o_Halt      : out std_logic    
    );
    end component;
    -- 11. EX/MEM pipeline register
    component ex_mem_reg is
        port(
            i_CLK       : in  std_logic;
            i_RST       : in  std_logic;

            -- From EX stage
            i_PC        : in  std_logic_vector(31 downto 0);
            i_ALUResult : in  std_logic_vector(31 downto 0);
            i_ReadData2 : in  std_logic_vector(31 downto 0);
            i_Funct3    : in  std_logic_vector(2 downto 0);
            i_Rd        : in  std_logic_vector(4 downto 0);

            i_MemRead   : in  std_logic;
            i_MemWrite  : in  std_logic;
            i_RegWrite  : in  std_logic;
            i_MemtoReg  : in  std_logic_vector(1 downto 0);
            i_Imm       : in  std_logic_vector(31 downto 0);
            i_Halt      : in  std_logic;

            -- To MEM stage
            o_PC        : out std_logic_vector(31 downto 0);
            o_ALUResult : out std_logic_vector(31 downto 0);
            o_ReadData2 : out std_logic_vector(31 downto 0);
            o_Funct3    : out std_logic_vector(2 downto 0);
            o_Rd        : out std_logic_vector(4 downto 0);
            o_Imm       : out std_logic_vector(31 downto 0);

            o_MemRead   : out std_logic;
            o_MemWrite  : out std_logic;
            o_RegWrite  : out std_logic;
            o_MemtoReg  : out std_logic_vector(1 downto 0);
            o_Halt      : out  std_logic;
        );
    end component;
    -- 12. MEM/WB pipeline register
    component mem_wb_reg is
    port(
        i_CLK      : in  std_logic;
        i_RST      : in  std_logic;

        -- From MEM stage
        i_PC        : in  std_logic_vector(31 downto 0);
        i_ALUResult : in  std_logic_vector(31 downto 0);
        i_LoadData  : in  std_logic_vector(31 downto 0);
        i_Imm       : in  std_logic_vector(31 downto 0);
        i_Rd        : in  std_logic_vector(4 downto 0);

        i_RegWrite  : in  std_logic;
        i_MemtoReg  : in  std_logic_vector(1 downto 0);
        i_Halt      : in  std_logic;

        -- To WB stage
        o_PC        : out std_logic_vector(31 downto 0);
        o_ALUResult : out std_logic_vector(31 downto 0);
        o_LoadData  : out std_logic_vector(31 downto 0);
        o_Imm       : out std_logic_vector(31 downto 0);
        o_Rd        : out std_logic_vector(4 downto 0);

        o_RegWrite  : out std_logic;
        o_MemtoReg  : out std_logic_vector(1 downto 0);
        o_Halt      : out std_logic
    );
    end component;

begin

    -- ======================================================================
    -- Instruction Memory Interface(IF stage)
    -- ======================================================================
    with iInstLd select
        s_IMemAddr <= s_CurrentPC when '0',
                      iInstAddr      when others;

    IMem: mem
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => N
        )
        port map(
            clk  => iCLK,
            addr => s_IMemAddr(ADDR_WIDTH+1 downto 2), 
            data => iInstExt,
            we   => iInstLd,
            q    => s_Inst -- IF stage instruction
        );

    -- ======================================================================
    -- Data Memory Interface (MEM stage)
    -- ======================================================================
    DMem: mem
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => N
        )
        port map(
            clk  => iCLK,
            addr => s_ALUResult_MEM(ADDR_WIDTH+1 downto 2),
            data => s_ReadData2_MEM,
            we   => s_MemWrite_MEM,
            q    => s_DMemOut
        );

    -- Connect Skeleton Signals used for Output
    oALUOut <= s_DMemAddr; 

    -- ======================================================================
    -- IF/ID Pipeline Register
    --  - Latches PC and Instruction from IF to ID
    -- ======================================================================
    U_IF_ID : if_id_reg
        port map(
            i_CLK  => iCLK,
            i_RST  => iRST,
            i_PC   => s_CurrentPC,          -- PC from pc_reg (IF)
            i_Inst => s_Inst(31 downto 0),  -- Instruction from IMem (IF)
            o_PC   => s_PC_ID,              -- PC seen by ID stage
            o_Inst => s_Inst_ID             -- Instruction seen by ID stage
    );

    -- ======================================================================
    -- Control Unit(ID stage, driven by s-Inst_ID)
    -- ======================================================================
    s_Funct3 <= s_Inst_ID(14 downto 12);
    s_Funct7 <= s_Inst_ID(31 downto 25);

    s_Halt_ID <= '1' when s_Inst_ID(6 downto 0) = "0000000" else '0';

    U_CONTROL : control_unit
        port map(
            i_Opcode   => s_Inst_ID(6 downto 0),
            o_ALUSrc   => s_ALUSrcB,
            o_MemtoReg => s_MemtoReg,
            o_RegWrite => s_RegWr,       
            o_MemRead  => s_MemRead,
            o_MemWrite => s_DMemWr,      
            o_Branch   => s_Branch,
            o_Jump     => s_Jump,
            o_ALUOp    => s_ALUOp,
            o_ImmType  => s_ImmType,
            o_AUIPCSrc => s_ALUSrcA
        );

    -- ======================================================================
    -- PC & Fetch Logic(IF + branch/jump target)
    -- ======================================================================
    U_PC : pc_reg
        port map(
            i_CLK    => iCLK,
            i_RST    => iRST,
            i_WE     => '1',
            i_NextPC => s_NextInstAddr,
            o_PC     => s_CurrentPC
        );

    U_FETCH : fetch_logic
        port map(
            i_PC      => s_PC_EX,
            i_Imm     => s_Imm_EX,
            i_RS1     => s_ReadData1_EX,
            i_Branch  => s_Branch_EX,
            i_Jump    => s_Jump_EX,
            i_Funct3  => s_Funct3_EX,
            i_ALUZero => s_Zero,
            i_ALUSign => s_Sign,
            i_ALUCout => s_Cout,
            o_NextPC  => s_NextInstAddr
        );

    -- ======================================================================
    -- Register File(ID stage)
    -- ======================================================================
    s_RegWrAddr <= s_Inst_ID(11 downto 7);
    

    U_REGFILE : reg_file
        port map(
            i_CLK    => iCLK,
            i_RST    => iRST,
            i_WE     => s_RegWrite_WB, -- WB stage RegWrite
            i_WADDR  => s_Rd_WB, -- WB stage rd register
            i_WDATA  => s_RegWrData, -- WB MUX result
            i_RADDR1 => s_Inst_ID(19 downto 15),
            i_RADDR2 => s_Inst_ID(24 downto 20),
            o_RDATA1 => s_ReadData1,
            o_RDATA2 => s_ReadData2 
        );
        
    s_DMemData <= s_ReadData2_MEM; 

    -- ======================================================================
    -- Immediate Generator(ID stage)
    -- ======================================================================
    U_IMM_GEN : imm_gen
        port map(
            i_Inst    => s_Inst_ID,
            i_ImmType => s_ImmType,
            o_Imm     => s_Imm
        );

        -- ======================================================================
    -- ID/EX Pipeline Register
    --  - Latches ID outputs into EX stage
    -- ======================================================================
    U_ID_EX : id_ex_reg
        port map(
            i_CLK       => iCLK,
            i_RST       => iRST,

            -- From ID stage
            i_PC        => s_PC_ID,
            i_ReadData1 => s_ReadData1,
            i_ReadData2 => s_ReadData2,
            i_Imm       => s_Imm,
            i_Funct3    => s_Funct3,
            i_Funct7    => s_Funct7,
            i_Rd        => s_RegWrAddr,

            i_MemRead   => s_MemRead,
            i_MemWrite  => s_DMemWr,
            i_RegWrite  => s_RegWr,
            i_MemtoReg  => s_MemtoReg,
            i_ALUSrcA   => s_ALUSrcA,
            i_ALUSrcB   => s_ALUSrcB,
            i_ALUOp     => s_ALUOp,
            i_Branch    => s_Branch,
            i_Jump      => s_Jump,
            i_Halt      => s_Halt_ID,

            -- To EX stage
            o_PC        => s_PC_EX,
            o_ReadData1 => s_ReadData1_EX,
            o_ReadData2 => s_ReadData2_EX,
            o_Imm       => s_Imm_EX,
            o_Funct3    => s_Funct3_EX,
            o_Funct7    => s_Funct7_EX,
            o_Rd        => s_Rd_EX,

            o_MemRead   => s_MemRead_EX,
            o_MemWrite  => s_MemWrite_EX,
            o_RegWrite  => s_RegWrite_EX,
            o_MemtoReg  => s_MemtoReg_EX,
            o_ALUSrcA   => s_ALUSrcA_EX,
            o_ALUSrcB   => s_ALUSrcB_EX,
            o_ALUOp     => s_ALUOp_EX,
            o_Branch    => s_Branch_EX,
            o_Jump      => s_Jump_EX,
            o_Halt      => s_Halt_EX
    );

    -- ======================================================================
    -- ALU Section(EX stage)
    -- ======================================================================
    -- MUX A
    s_ALUInputA <= s_PC_EX      when s_ALUSrcA_EX = '1' else s_ReadData1_EX;
    
    -- MUX B
    s_ALUInputB <= s_Imm_EX     when s_ALUSrcB_EX = '1' else s_ReadData2_EX;

    U_ALUCTRL : alu_control
        port map(
            i_ALUOp   => s_ALUOp_EX,
            i_Funct3  => s_Funct3_EX,
            i_Funct7  => s_Funct7_EX,
            o_ALUCtrl => s_ALUCtrl
        );

    U_ALU : alu
        port map(
            i_A       => s_ALUInputA,
            i_B       => s_ALUInputB,
            i_ALUCtrl => s_ALUCtrl,
            o_Result  => s_ALUResult,
            o_Zero    => s_Zero,
            o_Sign    => s_Sign,
            o_Cout    => s_Cout
        );

    U_EX_MEM : ex_mem_reg 
        port map(
            i_CLK       => iCLK,
            i_RST       => iRST,

            -- From EX stage
            i_PC        => s_PC_EX,
            i_ALUResult => s_ALUResult,
            i_ReadData2 => s_ReadData2_EX,
            i_Funct3    => s_Funct3_EX,
            i_Rd        => s_Rd_EX,
            i_Imm       => s_Imm_EX,
            i_Halt      => s_Halt_EX,

            i_MemRead   => s_MemRead_EX,
            i_MemWrite  => s_MemWrite_EX,
            i_RegWrite  => s_RegWrite_EX,
            i_MemtoReg  => s_MemtoReg_EX,

            -- To MEM stage
            o_PC        => s_PC_MEM,
            o_ALUResult => s_ALUResult_MEM,
            o_ReadData2 => s_ReadData2_MEM,
            o_Funct3    => s_Funct3_MEM,
            o_Rd        => s_Rd_MEM,
            o_Imm       => s_Imm_MEM,

            o_MemRead   => s_MemRead_MEM,
            o_MemWrite  => s_MemWrite_MEM,
            o_RegWrite  => s_RegWrite_MEM,
            o_MemtoReg  => s_MemtoReg_MEM,
            o_Halt      => s_Halt_MEM

        );

    s_DMemAddr <= s_ALUResult_MEM; 
    s_ByteOffset <= s_ALUResult(1 downto 0);

    U_LOADEXT : load_extender
    port map(
        i_DMemOut  => s_DMemOut,       
        i_Funct3   => s_Funct3_MEM,        
        i_AddrLSB  => s_ALUResult_MEM(1 downto 0),   
        o_ReadData => s_LoadData       
    );
    
    U_MEM_WB : mem_wb_reg
    port map(
        i_CLK      => iCLK,
        i_RST      => iRST,

        -- From MEM stage
        i_PC        => s_PC_MEM,
        i_ALUResult => s_ALUResult_MEM,
        i_LoadData  => s_LoadData,
        i_Imm       => s_Imm_MEM,   -- from ex_mem_reg 
        i_Rd        => s_Rd_MEM,
        i_Halt      => s_Halt_MEM,

        i_RegWrite  => s_RegWrite_MEM,
        i_MemtoReg  => s_MemtoReg_MEM,

        -- To WB stage
        o_PC        => s_PC_WB,
        o_ALUResult => s_ALUResult_WB,
        o_LoadData  => s_LoadData_WB,
        o_Imm       => s_Imm_WB,
        o_Rd        => s_Rd_WB,

        o_RegWrite  => s_RegWrite_WB,
        o_MemtoReg  => s_MemtoReg_WB,
        o_Halt      => s_Halt_WB
    );

    -- ======================================================================
    -- Writeback MUX (WB stage)
    -- ======================================================================
    with s_MemtoReg_WB select
        s_RegWrData <= s_ALUResult_WB                                 when "00", -- ALU
                       s_LoadData_WB                                  when "01", -- Memory
                       std_logic_vector(unsigned(s_PC_WB) + 4)        when "10", -- PC+4
                       s_Imm_WB                                       when "11", -- Imm (LUI)
                       (others => '0')                                when others;

    -- ======================================================================
    -- Required Signals for Testbench
    -- ======================================================================
    
    -- 1. Overflow Signal (Placeholder as current ALU doesn't explicitly output overflow)
    s_Ovfl <= '0'; 

    -- 2. Halt Logic (FIXED: Prevents premature exit during reset)
    s_Halt <= s_Halt_WB;

end structure;