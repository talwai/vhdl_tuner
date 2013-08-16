--Aaditya Talwai and Sam Golini
--VHDL model for music box: note-playing

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity music_box is
    port ( 
             e_switch_low : in std_logic;
             a_switch : in std_logic;
             d_switch : in std_logic;
             g_switch : in std_logic;
             b_switch : in std_logic;
             e_switch_high : in std_logic;
             
             clk_25MHz : in std_logic;

             dds_in : out std_logic_vector (11 downto 0)
        );
end music_box;

architecture behavior of music_box is
    signal note_playing : std_logic := '0';
    
    signal note_mux_sel : std_logic_vector (2 downto 0);
    
	 signal dds_signal : std_logic_vector(11 downto 0) := "000000000000";
	 
    begin
        note_select: process (e_switch_low, a_switch, d_switch, g_switch, b_switch, e_switch_high, note_mux_sel)
        begin
            note_playing <= '1';
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
            	note_playing <= '0';
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

        dds_clocked: process(clk_25MHz, dds_signal) is --process to divide clock by CLOCK_DIVIDER_VALUE
        begin
            if rising_edge(clk_25MHz) then -- on fast clock tick, increment clkdiv until it reaches divider value, then invert ce
                dds_in <= dds_signal;
            end if; -- hence ce is enabled at a frequency of 200Hz
        end process dds_clocked;
        
        muxer : process (note_mux_sel, dds_signal)
        begin
            case note_mux_sel is
                when "001" =>
                    dds_signal <= std_logic_vector(to_unsigned(82, dds_signal'length));
                when "010" =>
                    dds_signal <= std_logic_vector(to_unsigned(110, dds_signal'length));
                when "011" =>
                    dds_signal <= std_logic_vector(to_unsigned(147, dds_signal'length));
                when "100" =>
                    dds_signal <= std_logic_vector(to_unsigned(196, dds_signal'length));
                when "101" =>
                    dds_signal <= std_logic_vector(to_unsigned(247, dds_signal'length));
                when "110" =>
                    dds_signal <= std_logic_vector(to_unsigned(330, dds_signal'length));
                when "000" =>
                    dds_signal <= "000000000000"; -- zero input to DDS
					 when others =>
							null;
				end case;
        end process muxer;
end behavior;


