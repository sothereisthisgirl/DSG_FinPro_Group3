library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity user_input_unit is
    Port ( clk            : in  STD_LOGIC;
           reset          : in  STD_LOGIC;
           mode_select    : in  STD_LOGIC_VECTOR(2 downto 0);
           upgrade_select : in  STD_LOGIC;
           drying_select  : in  STD_LOGIC;
           user_input     : out STD_LOGIC_VECTOR(2 downto 0);
           upgrade_flag   : out STD_LOGIC;
           drying_flag    : out STD_LOGIC );
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