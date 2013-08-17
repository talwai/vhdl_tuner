--Aaditya Talwai and Sam Golini
--VHDL model for Direct Digital Synthesis

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
signal count : std_logic_vector(11 downto 0) := "000000000000"

begin
    phase_accumulator: process(phase_in, clk)
    begin
        if rising_edge(clk) then
            	count <= count + phase_in;
            end if;
        end if;
    end process phase_accumulator;

    --TODO: lookup table interfacing with LUT Xilinx component
    -- To convert from 2's complement (DDS output) to offset binary (DAC input)
    -- invert MSB of DDS output
end behavior;


