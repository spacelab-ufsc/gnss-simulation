-- acquisition.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity transmitter is
    Port (
        clk                : in  std_logic;
        reset              : in  std_logic;
        enable             : in  std_logic;
        input_data         : in  std_logic; -- Single-bit input signal
        output_data	       : out std_logic; -- Example result width
        valid_output	   : out std_logic;	
        SAT : in integer range 0 to 31 -- 32 GPS
    );
end transmitter;

architecture Behavioral of transmitter is
    -- Signals for the C/A code generator
    signal prn_code : std_logic;

begin
    -- Instantiate the C/A code generator
    ca_gen_inst: entity work.L1_CA_generator        
    port map (
            clk => clk,
            rst	=> reset,	
            PRN => prn_code,			
            ENABLE => enable,
            valid_out => valid_output,
            epoch => open,
            epoch_advce => open,
            SAT => SAT
        );

    	output_data <= not(input_data xor prn_code);	
end Behavioral;
