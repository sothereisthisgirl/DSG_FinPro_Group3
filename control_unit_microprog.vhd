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

    constant MAX_PRICE : integer := 200;

    signal s_wash_duration : INTEGER range 0 to 100 := 30;
    signal s_dry_duration  : INTEGER range 0 to 100 := 20;
    signal s_cost          : INTEGER range 0 to 255 := 50;

    signal s_start_wash    : STD_LOGIC := '0';
    signal s_start_dry     : STD_LOGIC := '0';

    signal prev_mode       : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal reached_max     : STD_LOGIC := '0';

begin

    process(clk, reset)
        variable v_cost       : integer;
        variable base_cost    : integer;
        variable base_washdur : integer;
    begin
        if reset = '1' then
            s_cost          <= 50;
            s_wash_duration <= 30;
            s_dry_duration  <= 20;
            s_start_wash    <= '0';
            s_start_dry     <= '0';
            prev_mode       <= (others => '0');
            reached_max     <= '0';

        elsif rising_edge(clk) then

            case mode_select is
                when "000" => base_washdur := 30; base_cost := 50;
                when "001" => base_washdur := 15; base_cost := 30;
                when "010" => base_washdur := 45; base_cost := 60;
                when "011" => base_washdur := 25; base_cost := 40;
                when others => base_washdur := 30; base_cost := 50;
            end case;

            if mode_select /= prev_mode then
                s_wash_duration <= base_washdur;
                if drying_flag = '1' then
                    s_dry_duration <= 20;
                else
                    s_dry_duration <= 0;
                end if;
                s_cost <= base_cost;
                reached_max <= '0';
                prev_mode <= mode_select;
            else
                if drying_flag = '1' then
                    s_dry_duration <= 20;
                else
                    s_dry_duration <= 0;
                end if;

                if reached_max = '0' then
                    v_cost := s_cost;
                    if upgrade_flag = '1' then
                        v_cost := v_cost + 20;
                    end if;

                    if drying_flag = '1' then
                        v_cost := v_cost + 30;
                    end if;

                    if v_cost >= MAX_PRICE then
                        s_cost <= MAX_PRICE;
                        reached_max <= '1';
                    else
                        s_cost <= v_cost;
                    end if;
                else
                    s_cost <= s_cost;
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
