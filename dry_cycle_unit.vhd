library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dry_cycle_unit is
    Port ( clk          : in  STD_LOGIC;
           reset        : in  STD_LOGIC;
           start_dry    : in  STD_LOGIC;
           duration_in  : in  INTEGER range 0 to 100;
           dry_done     : out STD_LOGIC
           );
end dry_cycle_unit;

architecture Behavioral of dry_cycle_unit is
    signal dry_timer   : INTEGER range 0 to 100 := 0;
    signal drying      : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            dry_timer <= 0;
            drying <= '0';
            dry_done <= '0';
        elsif rising_edge(clk) then
            dry_done <= '0';

            if start_dry = '1' and drying = '0' then
                dry_timer <= duration_in;
                drying <= '1';
            end if;

            if drying = '1' then
                if dry_timer > 0 then
                    dry_timer <= dry_timer - 1;
                else
                    dry_done <= '1';
                    drying <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;