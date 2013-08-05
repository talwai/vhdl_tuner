library ieee;
use ieee.std_logic_1164.all;


entity music_box is
    port ( 
             e_switch_low : in std_logic;
             a_switch : in std_logic;
             d_switch : in std_logic;
             g_switch : in std_logic;
             b_switch : in std_logic;
             e_switch_high : in std_logic;
             
             clk : in std_logic;

             dds_in : out std_logic := '0'
        );
end music_box;

architecture behavior of music_box is
    signal note_playing : std_logic := '0';
    
    signal note_mux_sel : std_logic_vector (2 downto 0);
    signal clkdiv : integer;
    signal clock_divider_value : integer;

    begin
        note_select: process (e_switch_low, a_switch, d_switch, g_switch, b_switch, e_switch_high)
        begin
            note_playing = '1';
            if e_switch_low = '1' then
            	note_mux_sel <= "001";
            elsif a_switch = '1' then
                note_mux_sel <= "010";
            elsif d_switch = '1' then
                note_mux_sel <= "011";
            elsif g_switch = '1' then
                note_mux_sel <= "100";
            elsif b_switch = '1' then
                note_mux_sel <= "101";
            elsif e_switch_high = '1' then
                note_mux_sel <= "110";
            else
            	note_playing = '0';
            	note_mux_sel <= "000";
            end if;

        end process;
        
        -- Guitar note frequencies
        -- Low E : 82 Hz
        -- A : 110 Hz
        -- D : 147 Hz
        -- G : 196 Hz
        -- B : 247 Hz
        -- High E : 330 Hz

        clock_divider: process(clk) is --process to divide clock by CLOCK_DIVIDER_VALUE
        begin
            if rising_edge(clk) then -- on fast clock tick, increment clkdiv until it reaches divider value, then invert ce
                if clkdiv = clock_divider_value - 1 then
                	dds_in = not(dds_in);
                	clkdiv <= 0;
                else 
                	clkdiv <= clkdiv + 1;
                end if;
            end if; -- hence ce is enabled at a frequency of 200Hz
        end process clock_divider;
        
        muxer : process (note_mux_sel)
        begin
            case note_mux_sel is
                when "001" =>
                    clock_divider_value <= 304878;
                when "010" =>
                    clock_divider_value <= 227273;
                when "011" =>
                    clock_divider_value <= 170068;
                when "100" =>
                    clock_divider_value <= 127551;
                when "001" =>
                    clock_divider_value <= 101215;
                when "001" =>
                    clock_divider_value <= 75758;
                when "000" =>
                    clock_divider_value <= 2147483647; -- highest possible value for int
            end case;
        end process muxer;
end behavior;


