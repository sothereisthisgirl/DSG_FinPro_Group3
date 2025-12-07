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