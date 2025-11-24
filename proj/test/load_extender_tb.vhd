library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity load_extender_tb is
end entity;

architecture tb of load_extender_tb is

    -- DUT inputs
    signal tb_DMemOut  : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_Funct3   : std_logic_vector(2 downto 0)  := (others => '0');
    signal tb_AddrLSB  : std_logic_vector(1 downto 0)  := (others => '0');

    -- DUT output
    signal tb_ReadData : std_logic_vector(31 downto 0);

begin
    -- Instantiate DUT
    DUT: entity work.load_extender
        port map (
            i_DMemOut  => tb_DMemOut,
            i_Funct3   => tb_Funct3,
            i_AddrLSB  => tb_AddrLSB,
            o_ReadData => tb_ReadData
        );

    process
    begin
        ---------------------------------------------------------
        -- Test 1: LB (signed byte)
        ---------------------------------------------------------
        tb_DMemOut <= x"12345680";     -- lowest byte = 0x80 (signed negative)
        tb_Funct3  <= "000";           -- LB
        tb_AddrLSB <= "00";
        wait for 10 ns;                -- Expect: 0xFFFFFF80

        ---------------------------------------------------------
        -- Test 2: LBU (unsigned byte)
        ---------------------------------------------------------
        tb_Funct3  <= "100";           -- LBU
        wait for 10 ns;                -- Expect: 0x00000080

        ---------------------------------------------------------
        -- Test 3: LH (signed halfword)
        ---------------------------------------------------------
        tb_DMemOut <= x"80011234";     -- lower half = 0x1234, upper = 0x8001
        tb_Funct3  <= "001";           -- LH
        tb_AddrLSB <= "10";            -- select upper halfword (0x8001)
        wait for 10 ns;                -- Expect: 0xFFFF8001

        ---------------------------------------------------------
        -- Test 4: LHU (unsigned halfword)
        ---------------------------------------------------------
        tb_Funct3  <= "101";           -- LHU
        wait for 10 ns;                -- Expect: 0x00008001

        ---------------------------------------------------------
        -- Test 5: LW (load full word)
        ---------------------------------------------------------
        tb_DMemOut <= x"DEADBEEF";
        tb_Funct3  <= "010";           -- LW
        tb_AddrLSB <= "00";
        wait for 10 ns;                -- Expect: 0xDEADBEEF

        ---------------------------------------------------------
        -- End simulation
        ---------------------------------------------------------
        wait;
    end process;

end architecture;