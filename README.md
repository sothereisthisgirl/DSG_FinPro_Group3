# Digital Washing Machine Control System
**Group 3 Final Project**

* Muhammad Agib Anugrah Pratama    2406450415
* Hafizh Akbar Ghifarie Ramadhan   2406450384  
* Syifa Sarah Nuraini              2406368883
* Ryan Gazendra Irawan             2406368952

## Project Description
This project implements a complete digital washing machine control system using VHDL. The system features multiple washing modes, optional drying cycles, automatic price calculation, and safety door locking mechanisms. Designed with modular architecture, it demonstrates practical application of digital design principles in home appliance automation.

## Key Features
1. **Multi-mode Washing System**: 4 distinct washing modes with different durations
2. **Optional Drying Cycle**: Separate timer control for drying operations
3. **Automatic Price Calculation**: Real-time pricing based on selected features
4. **Safety Door Locking**: Automatic door lock during operation
5. **Finite State Machine Control**: Complete cycle management
6. **User Input Synchronization**: Clock-synchronized input handling
7. **Comprehensive Testing**: Full testbench with multiple test cases

## System Components
1. **Wash Cycle Unit**: Timer controller for washing duration
2. **Dry Cycle Unit**: Timer controller for drying duration  
3. **Control Unit Microprogram**: Main state machine controller
4. **Billing Unit**: Automatic price calculation module
5. **Door Lock Module**: Safety interlock mechanism
6. **User Input Unit**: Input synchronization and registration
7. **Washing Machine Top**: Complete system integration

## Design Architecture

### 1. wash_cycle_unit (Entity)
**Timer module for controlling washing cycle duration with countdown mechanism.**

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wash_cycle_unit is
    Port ( 
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        start_wash  : in  STD_LOGIC;
        duration_in : in  INTEGER range 0 to 100;
        wash_done   : out STD_LOGIC
    );
end wash_cycle_unit;

architecture Behavioral of wash_cycle_unit is
    signal wash_timer : INTEGER range 0 to 100 := 0;
    signal washing    : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            wash_timer <= 0;
            washing    <= '0';
            wash_done  <= '0';
        elsif rising_edge(clk) then
            wash_done <= '0';
            if start_wash = '1' and washing = '0' then
                wash_timer <= duration_in;
                washing    <= '1';
            end if;
            if washing = '1' then
                if wash_timer > 0 then
                    wash_timer <= wash_timer - 1;
                else
                    wash_done <= '1';
                    washing   <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
```

*Design Style: Behavioral with synchronous process*

*Function: Implements a synchronous countdown timer that activates upon receiving start_wash signal. The timer counts down from duration_in and generates a wash_done pulse when reaching zero, then returns to idle state.*

### 2. dry_cycle_unit (Entity)
**Timer controller for drying cycle operations.**

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dry_cycle_unit is
    Port ( 
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        start_dry   : in  STD_LOGIC;
        duration_in : in  INTEGER range 0 to 100;
        dry_done    : out STD_LOGIC
    );
end dry_cycle_unit;

architecture Behavioral of dry_cycle_unit is
    signal dry_timer : INTEGER range 0 to 100 := 0;
    signal drying    : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            dry_timer <= 0;
            drying    <= '0';
            dry_done  <= '0';
        elsif rising_edge(clk) then
            dry_done <= '0';
            if start_dry = '1' and drying = '0' then
                dry_timer <= duration_in;
                drying    <= '1';
            end if;
            if drying = '1' then
                if dry_timer > 0 then
                    dry_timer <= dry_timer - 1;
                else
                    dry_done <= '1';
                    drying   <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;
```

*Design Style: Behavioral with synchronous process*

*Function: Similar to wash_cycle_unit, this module controls the drying cycle timer with start_dry trigger and dry_done completion signal. It operates independently from the washing cycle.*

### 3. control_unit_microprog (Entity)
**Main finite state machine controlling the complete washing machine operation.**

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit_microprog is
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
end control_unit_microprog;

architecture Behavioral of control_unit_microprog is
    signal s_wash_duration : INTEGER range 0 to 100 := 30;
    signal s_dry_duration  : INTEGER range 0 to 100 := 20;
    signal s_cost          : INTEGER range 0 to 255 := 50;
    signal s_start_wash    : STD_LOGIC := '0';
    signal s_start_dry     : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            s_cost          <= 50;
            s_wash_duration <= 30;
            s_dry_duration  <= 20;
            s_start_wash    <= '0';
            s_start_dry     <= '0';
        elsif rising_edge(clk) then
            if wash_done_in = '0' and dry_done_in = '0' then
                case mode_select is
                    when "000" => s_wash_duration <= 30; s_cost <= 50;
                    when "001" => s_wash_duration <= 15; s_cost <= 30;
                    when "010" => s_wash_duration <= 45; s_cost <= 60;
                    when "011" => s_wash_duration <= 25; s_cost <= 40;
                    when others => s_wash_duration <= 30; s_cost <= 50;
                end case;
                if upgrade_flag = '1' then
                    s_wash_duration <= s_wash_duration + 10;
                    s_cost          <= s_cost + 20;
                end if;
                if drying_flag = '1' then
                    s_dry_duration  <= 20;
                    s_cost          <= s_cost + 30;
                else
                    s_dry_duration <= 0;
                end if;
            end if;
            if wash_done_in = '0' then
                s_start_wash <= '1';
            else
                s_start_wash <= '0';
            end if;
            if drying_flag = '1' and dry_done_in = '0' then
                s_start_dry <= '1';
            else
                s_start_dry <= '0';
            end if;
        end if;
    end process;
    price_out      <= STD_LOGIC_VECTOR(TO_UNSIGNED(s_cost, price_out'length));
    wash_duration  <= s_wash_duration;
    dry_duration   <= s_dry_duration;
    start_wash_out <= s_start_wash;
    start_dry_out  <= s_start_dry;
end Behavioral;
```

*Design Style: Finite State Machine (FSM)*

*Function: Central controller that manages transitions between washing modes, controls cycle timing, calculates durations based on user selections, and coordinates between washing and drying units. It also handles the price calculation logic.*

### 4. billing_unit (Entity)
**Automatic price calculation module based on selected features.**

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity billing_unit is
    Port ( 
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        mode_select   : in  STD_LOGIC_VECTOR(2 downto 0);
        upgrade_flag  : in  STD_LOGIC;
        drying_flag   : in  STD_LOGIC;
        price         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end billing_unit;

architecture Behavioral of billing_unit is
    signal cost : INTEGER range 0 to 255 := 50;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            cost <= 50;
        elsif rising_edge(clk) then
            case mode_select is
                when "000" => cost <= 50;
                when "001" => cost <= 30;
                when "010" => cost <= 60;
                when "011" => cost <= 40;
                when others => cost <= 50;
            end case;
            if upgrade_flag = '1' then
                cost <= cost + 20;
            end if;
            if drying_flag = '1' then
                cost <= cost + 30;
            end if;
        end if;
    end process;
    price <= STD_LOGIC_VECTOR(TO_UNSIGNED(cost, price'length));
end Behavioral;
```

*Design Style: Dataflow with arithmetic operations*

*Function: Calculates total price based on: (1) base washing mode (50/30/60/40), (2) duration upgrade (+20), and (3) drying feature (+30). Outputs 8-bit price display.*

### 5. door_lock_module (Entity)
**Safety interlock mechanism for door control.**

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity door_lock_module is
    Port ( 
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        wash_done    : in  STD_LOGIC;
        dry_done     : in  STD_LOGIC;
        door_status  : out STD_LOGIC
    );
end door_lock_module;

architecture Behavioral of door_lock_module is
    signal door_locked : STD_LOGIC;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            door_locked <= '1';
        elsif rising_edge(clk) then
            if wash_done = '1' and dry_done = '1' then
                door_locked <= '0';
            else
                door_locked <= '1';
            end if;
        end if;
    end process;
    door_status <= door_locked;
end Behavioral;
```

*Design Style: Behavioral with safety logic*

*Function: Automatically locks the door (door_status='1') during washing/drying operations and unlocks (door_status='0') only when both cycles are complete, ensuring user safety.*

### 6. user_input_unit (Entity)
**Input synchronization module for user interface.**

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity user_input_unit is
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
end user_input_unit;

architecture Behavioral of user_input_unit is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            user_input     <= "000";
            upgrade_flag   <= '0';
            drying_flag    <= '0';
        elsif rising_edge(clk) then
            user_input     <= mode_select;
            upgrade_flag   <= upgrade_select;
            drying_flag    <= drying_select;
        end if;
    end process;
end Behavioral;
```

*Design Style: Dataflow with register synchronization*

*Function: Synchronizes user inputs (mode_select, upgrade_select, drying_select) to the system clock domain to prevent metastability issues and ensure reliable operation.*

### 7. washing_machine_top (Top-Level Entity)
**Complete system integration and top-level module.**

```vhdl
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
```

*Design Style: Structural*

*Function: Top-level entity that integrates all modules using component instantiation and port mapping. Defines the complete system interface and interconnects all subsystems.*

### Washing Modes
| Mode Code | Description | Base Duration | Base Price |
|-----------|-------------|---------------|------------|
| 000       | Normal Wash | 30 cycles     | 50         |
| 001       | Quick Wash  | 15 cycles     | 30         |
| 010       | Heavy Wash  | 45 cycles     | 60         |
| 011       | Delicate    | 25 cycles     | 40         |

**Additional Features:**

* Duration Upgrade: +10 cycles, +20 price
* Drying Cycle: +20 cycles, +30 price
* Usage Instructions
* Select washing mode using 3-bit input (000-011)
* Choose duration upgrade if needed (1-bit)
* Select drying feature if needed (1-bit)
* System calculates and displays price automatically
* Door locks during operation
* Door unlocks and cycle complete signal activates when finished

**Testbench**
*The system includes comprehensive testbench (washing_machine_tb.vhd) that verifies:*

* All washing mode operations
* Price calculations for each combination
* Door lock behavior
* Reset functionality
* Cycle completion signals

**Team Contributions**
* Muhammad Agib Anugrah Pratama: Dry cycle unit, Door lock module, Bug fixes and synchronization improvements
* Hafizh Akbar Ghifarie Ramadhan: Wash cycle unit, Top-level system integration, Complete documentation
* Syifa Sarah Nuraini: Control unit microprogram, User input unit, State machine design
* Ryan Gazendra Irawan: Billing unit, Testbench development, System verification

**Project Timeline**
*10 commits distributed over 4 development phases:*

* Foundation Phase: Basic module implementations
* Control Logic Phase: State machine and control units
* Integration Phase: System assembly and initial testing
* Refinement Phase: Bug fixes and finalization (Current Timeline)

**Simulation Results**
*All modules successfully simulate with correct:*

* Timing behavior and cycle durations
* Accurate price calculations
* Proper state transitions
* Expected I/O responses
* Safety interlock functionality

**Files Included**
* wash_cycle_unit.vhd - Washing timer module
* dry_cycle_unit.vhd - Drying timer module
* user_input_unit.vhd - Input synchronization
* control_unit_microprog.vhd - Main controller
* billing_unit.vhd - Price calculation
* door_lock_module.vhd - Safety lock
* washing_machine_top.vhd - Complete system
* washing_machine_tb.vhd - Testbench
