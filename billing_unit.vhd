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