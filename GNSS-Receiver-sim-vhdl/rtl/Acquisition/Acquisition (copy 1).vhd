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
            epoch => open,
            epoch_advce => c_rst,
            SAT => SAT
        );

    -- Correlate input_signal with generated_prn_code
    process(clk, reset , enable)
    begin
        if clk'event and clk = '1' then
            if reset = '1' or epoch_rst = '1' then
                correlation_value <= 0;
            elsif enable = '1' then
                -- Simple correlation: accumulate if input_signal matches generated_prn_code
                if (input_signal xor prn_code) = '1' then
                    correlation_value <= correlation_value + 1;
		else
                    correlation_value <= correlation_value - 1;			
                end if;
            end if;
        end if;
    end process;

    correlation_result <= conv_std_logic_vector((correlation_value),correlation_result'length);
    corr_valid <= '0' when correlation_value < 1020 and correlation_value > -1020 else
		  '1'; 
end Behavioral;
