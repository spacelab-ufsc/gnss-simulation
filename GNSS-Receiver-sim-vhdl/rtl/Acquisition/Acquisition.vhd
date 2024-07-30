-- acquisition.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity acquisition is
    Port (
        clk                : in  std_logic;
        reset              : in  std_logic;
        enable             : in  std_logic;
        input_signal       : in  std_logic; -- Single-bit input signal
        correlation_result : out std_logic_vector(11 downto 0); -- Example result width
		valid_output	   : out std_logic;	
		corr_valid  	   : out std_logic;
		SAT : in integer range 0 to 31 -- 32 GPS
    );
end acquisition;

architecture Behavioral of acquisition is
    -- Signals for the C/A code generator
    signal prn_code  : std_logic;
    signal epoch_rst : std_logic;
    signal corr_rst  : std_logic;

    -- Declare the correlation process variables
    signal correlation_value : integer := 0;

begin
    -- Instantiate the C/A code generator
    ca_gen_inst: entity work.L1_CA_generator        
    port map (
			clk => clk,
			rst	=> reset,	
			PRN => prn_code,			
			ENABLE => enable,
			valid_out => valid_output,
			epoch => epoch_rst,
			epoch_advce => open,
			SAT => SAT
        );

	correlator: entity work.corr
	port map(
			clk  => clk,
			rst  => corr_rst,
			d1   => input_signal,
			d2   => prn_code,
			flag => corr_valid,
			csum =>correlation_result
	    );

    corr_rst <= reset or epoch_rst;
end Behavioral;
