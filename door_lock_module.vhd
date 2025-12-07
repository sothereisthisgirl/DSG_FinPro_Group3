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