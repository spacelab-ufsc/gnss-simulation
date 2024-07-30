---------------------------------------------------------------
-- Testbench para o UAL32
---------------------------------------------------------------

Library ieee;
use ieee.std_logic_1164.all;	   
use ieee.std_logic_arith.all;
use work.all;

entity tb_CA is			-- entity declaration
end tb_CA;

----------------------------------------------------------------

architecture arq_tb of tb_CA is

component L1_CA_generator is

port(				
	clk : in std_logic;
	rst	: in std_logic;		
	PRN : out std_logic;			
	ENABLE : in std_logic;
	valid_out : out std_logic;
	epoch : out std_logic;
	epoch_advce : out std_logic;
	SAT : in integer range 0 to 31 -- 32 GPS
);
end component;

signal T_clk,T_rst : std_logic :='0';
signal T_PRN, T_valid, T_epoch, T_epoch_adv : std_logic;
constant T_SAT : integer := 1;

begin
	U1: L1_CA_generator port map(T_clk,T_rst,T_PRN,'1',T_valid,T_epoch,T_epoch_adv,T_SAT);
	
	T_clk <= not T_clk after 489 ns;		-- gera o sinal de clock
	T_rst <= '1','0' after 5 us;			-- gera o sinal de reset

	process
	begin
		wait for 5 ms;					
	end process;

end arq_tb;

