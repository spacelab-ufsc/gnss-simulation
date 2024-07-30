---------------------------------------------------------------
-- Testbench para o UAL32
---------------------------------------------------------------

Library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.all;

entity tb_Acquisition is			-- entity declaration
end tb_Acquisition;

----------------------------------------------------------------

architecture arq_tb of tb_Acquisition is

component Acquisition is

    Port (
        clk                : in  STD_LOGIC;
        reset              : in  STD_LOGIC;
        enable             : in  STD_LOGIC;
        input_signal       : in  STD_LOGIC; -- Single-bit input signal
        correlation_result : out STD_LOGIC_VECTOR(15 downto 0); -- Example result width
	valid_output	   : out STD_LOGIC;	
	SAT 		   : in integer range 0 to 31 -- 32 GPS
    );
end component;

signal T_clk, T_rst, T_input: std_logic :='0';
signal T_valid : std_logic;
signal T_result: std_logic_vector(15 downto 0);

constant T_SAT : integer := 1;

begin
	U1: Acquisition port map(T_clk,T_rst,'1',T_input,T_result,T_valid,T_SAT);
	
	T_clk <= not T_clk after 489 ns;		-- gera o sinal de clock
	T_rst <= '1','0' after 5 us;			-- gera o sinal de reset
	T_input <= not T_input after 1 us;

	process
	begin
		wait for 1000 ms;					
	end process;

end arq_tb;

