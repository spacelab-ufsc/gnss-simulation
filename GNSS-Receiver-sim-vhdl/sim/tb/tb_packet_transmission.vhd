---------------------------------------------------------------
-- Testbench para o UAL32
---------------------------------------------------------------

Library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.all;

entity tb_Transmission is			-- entity declaration
end tb_Transmission;

----------------------------------------------------------------

architecture arq_tb of tb_Transmission is

component transmitter is
    Port (
        clk                : in  STD_LOGIC;
        reset              : in  STD_LOGIC;
        enable             : in  STD_LOGIC;
        input_data         : in  STD_LOGIC; -- Single-bit input signal
        output_data	   : out STD_LOGIC; -- Example result width
	valid_output	   : out STD_LOGIC;	
	SAT : in integer range 0 to 31 -- 32 GPS
    );
end component;

component Acquisition is

    Port (
        clk                : in  STD_LOGIC;
        reset              : in  STD_LOGIC;
        enable             : in  STD_LOGIC;
        input_signal       : in  STD_LOGIC; -- Single-bit input signal
        correlation_result : out STD_LOGIC_VECTOR(11 downto 0); -- Example result width
	valid_output	   : out STD_LOGIC;	
	corr_valid	   : out std_logic;
	SAT 		   : in integer range 0 to 31 -- 32 GPS
    );
end component;

signal T_clk, T_rst, T_input: std_logic :='0';
signal T_data  : std_logic;
signal T_valid_in, T_valid_out, T_cvalid : std_logic;
signal T_result: std_logic_vector(11 downto 0);

constant T_SAT : integer := 1;

begin
	U1: transmitter port map(T_clk,T_rst,'1',T_input,T_data,T_valid_in,T_SAT);
	U2: Acquisition port map(T_clk,T_rst,'1',T_data,T_result,T_valid_out,T_cvalid,T_SAT);
	
	T_clk <= not T_clk after 489 ns;		-- gera o sinal de clock
	T_rst <= '1','0' after 5 us;			-- gera o sinal de reset
	T_input <= not T_input after 20 ms;

	process
	begin
		wait for 1000 ms;					
	end process;

end arq_tb;

