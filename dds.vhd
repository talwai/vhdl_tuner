
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity dds is
    port ( 
             phase_in : in std_logic_vector(11 downto 0);

             clk : in std_logic;

             dds_out : out std_logic_vector(11 downto 0)
         );
end dds;

architecture behavior of dds is
    constant max_phase : integer := 2**12;
    signal count : unsigned(11 downto 0) := "000000000000";
    --signal LUT_in : std_logic_vector(11 downto 0);
    constant fclk: integer:=25000000;
    constant fsam: integer:=8000;
    constant k: integer:=fclk/fsam;
    signal clkdiv: integer;
    signal samplerate: std_logic;
    signal phase_in: std_logic_vector(11 downto 0);

begin

    clk_divider: process(clk)
    begin
        if rising_edge(clk) then -- on fast clock tick, increment clkdiv until it reaches divider value, then invert samplerate clock
            if clkdiv = k-1 then
                samplerate <= not(samplerate);
                clkdiv <= 0;
            else 
                clkdiv <= clkdiv + 1;
            end if;
        end if;
    end process clock_divider;

    phase_accumulator: process(phase_in, clk)
    begin
        if rising_edge(clk) then
            if samplerate='1' then
                count <= count + phase_in;
            end if;
        end if;
    end process phase_accumulator;

    dds_out<=count;

--TODO: lookup table interfacing with LUT Xilinx component
-- To convert from 2's complement (DDS output) to offset binary (DAC input)
-- invert MSB of DDS output
end behavior;
