library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity washing_machine_top is
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
end washing_machine_top;

architecture Behavioral of washing_machine_top is
    signal user_input       : STD_LOGIC_VECTOR(2 downto 0);
    signal upgrade_flag     : STD_LOGIC;
    signal drying_flag      : STD_LOGIC;
    signal wash_done_s      : STD_LOGIC := '0';
    signal dry_done_s       : STD_LOGIC := '0';
    signal start_wash_s     : STD_LOGIC;
    signal start_dry_s      : STD_LOGIC;
    signal price_s          : STD_LOGIC_VECTOR(7 downto 0);
    signal wash_duration_s  : INTEGER range 0 to 100;
    signal dry_duration_s   : INTEGER range 0 to 100;

    component user_input_unit is
        Port ( 
            clk            : in  STD_LOGIC;
            reset          : in  STD_LOGIC;
            mode_select    : in  STD_LOGIC_VECTOR(2 downto 0);
            upgrade_select : in  STD_LOGIC;
            drying_select  : in  STD_LOGIC;
            user_input     : out STD_LOGIC_VECTOR(2 downto 0);
            upgrade_flag   : out STD_LOGIC;
            drying_flag    : out STD_LOGIC
        );
    end component;

    component control_unit_microprog is
        Port ( 
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            mode_select     : in  STD_LOGIC_VECTOR(2 downto 0);
            upgrade_flag    : in  STD_LOGIC;
            drying_flag     : in  STD_LOGIC;
            wash_done_in    : in  STD_LOGIC;
            dry_done_in     : in  STD_LOGIC;
            start_wash_out  : out STD_LOGIC;
            start_dry_out   : out STD_LOGIC;
            price_out       : out STD_LOGIC_VECTOR(7 downto 0);
            wash_duration   : out INTEGER range 0 to 100;
            dry_duration    : out INTEGER range 0 to 100
        );
    end component;

    component wash_cycle_unit is
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            start_wash   : in  STD_LOGIC;
            duration_in  : in  INTEGER range 0 to 100;
            wash_done    : out STD_LOGIC
        );
    end component;

    component dry_cycle_unit is
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            start_dry    : in  STD_LOGIC;
            duration_in  : in  INTEGER range 0 to 100;
            dry_done     : out STD_LOGIC
        );
    end component;

    component door_lock_module is
        Port ( 
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            wash_done    : in  STD_LOGIC;
            dry_done     : in  STD_LOGIC;
            door_status  : out STD_LOGIC
        );
    end component;
    
begin
    user_input_inst : user_input_unit
        port map ( 
            clk            => clk,
            reset          => reset,
            mode_select    => mode_select,
            upgrade_select => upgrade_select,
            drying_select  => drying_select,
            user_input     => user_input,
            upgrade_flag   => upgrade_flag,
            drying_flag    => drying_flag
        );

    control_unit_inst : control_unit_microprog
        port map ( 
            clk            => clk,
            reset          => reset,
            mode_select    => user_input,
            upgrade_flag   => upgrade_flag,
            drying_flag    => drying_flag,
            wash_done_in   => wash_done_s,
            dry_done_in    => dry_done_s,
            start_wash_out => start_wash_s,
            start_dry_out  => start_dry_s,
            price_out      => price_s,
            wash_duration  => wash_duration_s,
            dry_duration   => dry_duration_s
        );

    wash_cycle_inst : wash_cycle_unit
        port map ( 
            clk         => clk,
            reset       => reset,
            start_wash  => start_wash_s,
            duration_in => wash_duration_s,
            wash_done   => wash_done_s
        );

    dry_cycle_inst : dry_cycle_unit
        port map ( 
            clk         => clk,
            reset       => reset,
            start_dry   => start_dry_s,
            duration_in => dry_duration_s,
            dry_done    => dry_done_s
        );

    door_lock_inst : door_lock_module
        port map ( 
            clk         => clk,
            reset       => reset,
            wash_done   => wash_done_s,
            dry_done    => dry_done_s,
            door_status => door_locked
        );

    price_display  <= price_s;
    cycle_complete <= wash_done_s AND dry_done_s;

end Behavioral;