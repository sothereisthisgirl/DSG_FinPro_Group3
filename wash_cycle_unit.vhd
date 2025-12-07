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