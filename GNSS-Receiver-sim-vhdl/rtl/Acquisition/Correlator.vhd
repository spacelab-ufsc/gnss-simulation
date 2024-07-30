----------------------------------------------------------------
--  Correlator
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity corr is
port (
    clk : in std_logic;
    rst : in std_logic;
    d1  : in std_logic;
    d2  : in std_logic;
    flag: out std_logic;
    csum : out std_logic_vector(11 downto 0)
    );
end corr;

architecture corr_beh of corr is
    signal intsum : integer := 0;

    begin -- corr_beh
    process (clk, rst,d1, d2)

    begin -- process
        -- activities triggered by asynchronous reset (active low)
        if rst = '1' then
            intsum <= 0;
            -- activities triggered by rising edge of clock
        elsif clk'event and clk = '1' then
            if (d1 xor d2) = '1' then
                    intsum <= intsum + 1;
	    else
                    intsum <= intsum - 1;			
            end if;
        end if;
    end process;
    
    csum <= conv_std_logic_vector(intsum,csum'length);
    flag <= '0' when intsum < 1020 and intsum > -1020 else
            '1'; 
end corr_beh;
