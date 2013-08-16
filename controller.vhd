--Aaditya Talwai and Sam Golini
--VHDL model for Recording/Playback controller


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port ( 
             playback_switch : in std_logic; -- Switch for Playback
             record_switch : in std_logic; -- Switch for record
        
             which_note : in std_logic_vector (2 downto 0); -- 3-bit representation of guitar note

             clk : in std_logic; 

				 wea : out std_logic_vector (0 downto 0);
            
             playback_en : out std_logic; -- playback mux selector
				  
				 address_out: out std_logic_vector(4 downto 0);				 
             
				 note_out : out std_logic_vector(7 downto 0) -- output 8-bit (note_time & note)
    );
end controller;

architecture behavior of controller is
    
    type statetype is 
	  (Init, Normal, Record_wait, Recording, Write, Playback_wait, Playback);
    signal current_state, next_state : statetype;
	
	 signal write_count_en : std_logic;
	 signal read_count_en : std_logic;
	
    signal clkdiv : integer; 
    signal clock_divider_value : integer := 5000000; --clock divider, for 5 Hz note timer
    signal slow_clk : std_logic := '0';
	 
	 signal timer_en : std_logic;
	 
	 signal wea_signal : std_logic;
	 
    signal timer_count: std_logic_vector (4 downto 0);
    signal read_count : std_logic_vector (4 downto 0);
    signal write_count : std_logic_vector (4 downto 0);

    signal note_curr : std_logic_vector (2 downto 0);
    
    signal readstop : std_logic_vector (4 downto 0) := "00000"; -- addr at which to stop reading

    --to add, actual BRAM component


    begin
        clock_divider: process(clk) is --process to divide clock by CLOCK_DIVIDER_VALUE
        begin
            if rising_edge(clk) then -- on fast clock tick, increment clkdiv until it reaches divider value, then invert ce
                if clkdiv = clock_divider_value - 1 then
                	slow_clk <= not(slow_clk);
                	clkdiv <= 0;
                else 
                	clkdiv <= clkdiv + 1;
                end if;
            end if; -- hence ce is enabled at a frequency of 200Hz
        end process clock_divider;
        
        read_count_tick: process (clk, read_count_en) is -- process to tick read count if enabled
        begin
            if rising_edge(clk) and read_count_en = '1' then
            	read_count <= std_logic_vector (unsigned(read_count) + 1);
            end if;
        end process;

        write_count_tick: process (clk, write_count_en) is --same as above for write count
        begin
            if rising_edge(clk) and write_count_en = '1' then
            	write_count <= std_logic_vector (unsigned(write_count) + 1);
            end if;
        end process;
        
        note_timer: process(slow_clk) is -- time counter to clock note duration
        begin
            if rising_edge(slow_clk) and timer_en = '1' then
            	timer_count <= std_logic_vector (unsigned(timer_count) + 1);
            end if;
        end process;
        
        load_BRAM : process(clk, wre) is -- process to load BRAM on record
		  begin
            if rising_edge(clk) and wre = '1' then
					 data_out <= timer_count & note_curr; -- TODO: replace with code to write to BRAM component
                readstop <= std_logic_vector (unsigned(readstop) + 1);
            end if;
        end process;
        
        read_BRAM : process(clk, playback_en) is -- process to read BRAM on playback
        begin    
				if rising_edge(clk) and playback_en = '1' then 
                note_out <= data_in; -- TODO: replace with code to read from BRAM component
            end if;
        end process;

        statereg: process(clk) is -- process to update state based on clock
        begin
            if rising_edge(clk) then
                current_state <= next_state;
            end if;
        end process;

        comblogic : process(clk) is -- state machine
        begin
            next_state <= current_state;
            case current_state is
                when Init =>
                    if record_switch = '1' and playback_switch = '0' then 
                       next_state <= Record_wait;
                    elsif playback_switch = '1' then
                       next_state <= Playback_wait;
                    elsif playback_switch = '0' and record_switch = '0' then
                       next_state <= Normal;
                    else null;  --if both switches are '1' do nothing
                    end if;

                when Normal =>
                    note_out <= "00000" & which_note; -- Don't bother writing to BRAM, just play
                    --TODO: figure out MUXing for playback/record
                    next_state <= Init;

                when Record_wait =>
                    if which_note /= "000" then    -- if some note is being played
                        note_curr <= which_note; 
                        timer_en <= '1';   --tick timer and write count
                        write_count_en <= '1';
                        next_state <= Recording;
                    else null;
                    end if;

                when Recording =>
                    write_count_en <= '0';
                    if which_note /= note_curr then -- if input note changes
                    	timer_en <= '0'; 
                    	wea_signal <= '1'; --write to BRAM
                    	next_state <= Write;
                    else null;
                    end if;

                when Write =>
                    wea_signal <= '0';
                    next_state <= Init;

                when Playback_wait =>
                    if readstop = "00000" then -- if no writes yet
                        next_state <= Init; -- go back and wait for write
                    else
                    	read_count_en <= '1'; -- tick read counter, enable playback
                        next_state <= Playback;
                        playback_en <= '1';  
						  end if;
						  
                when Playback =>
                    read_count_en <= '0';
                    if read_count < readstop then
                    	next_state <= Playback_wait;
                    else -- read all words in BRAM
                    	readstop <= "00000"; --reset all counts
                    	read_count <= "00000";
                    	write_count <= "00000";

                    	playback_en <= '0'; -- disable playback
                    	next_state <= Init;
						  end if;
                end case;
            end process;
    end behavior;


