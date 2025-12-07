library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity washing_machine_tb is
end washing_machine_tb;

architecture Behavioral of washing_machine_tb is

    component washing_machine_top is
        Port ( 
            clk               : in  STD_LOGIC;
            reset             : in  STD_LOGIC;
            mode_select       : in  STD_LOGIC_VECTOR(2 downto 0);
            upgrade_select    : in  STD_LOGIC;
            drying_select     : in  STD_LOGIC;
            price_display     : out STD_LOGIC_VECTOR(7 downto 0);
            cycle_complete    : out STD_LOGIC;
            door_locked       : out STD_LOGIC
        );
    end component;
    
    constant clk_period : time := 10 ns;
    signal clk            : STD_LOGIC := '0';
    signal reset          : STD_LOGIC := '0';
    signal mode_select    : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal upgrade_select : STD_LOGIC := '0';
    signal drying_select  : STD_LOGIC := '0';
    signal price_display  : STD_LOGIC_VECTOR(7 downto 0);
    signal cycle_complete : STD_LOGIC;
    signal door_locked    : STD_LOGIC;

begin

    uut: washing_machine_top
        port map ( 
            clk               => clk,
            reset             => reset,
            mode_select       => mode_select,
            upgrade_select    => upgrade_select,
            drying_select     => drying_select,
            price_display     => price_display,
            cycle_complete    => cycle_complete,
            door_locked       => door_locked
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    stimulus_process: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;
        
        mode_select <= "000";
        upgrade_select <= '0';
        drying_select <= '0';
        wait for 50 ns;

        mode_select <= "001";
        upgrade_select <= '1';
        drying_select <= '0';
        wait for 50 ns;

        mode_select <= "010";
        upgrade_select <= '0';
        drying_select <= '1';
        wait for 50 ns;

        mode_select <= "011";
        upgrade_select <= '1';
        drying_select <= '1';
        wait for 50 ns;

        wait;
    end process;

end Behavioral;