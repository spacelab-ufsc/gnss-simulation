library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fll is
    Port ( 
        clk             : in  std_logic;
        reset           : in  std_logic;
        I_signal        : in  std_logic;
        previous_signal : in  std_logic;
        freq_nco        : out std_logic_vector(15 downto 0)
        );
end fll;

architecture Behavioral of fll is
    signal freq_err : integer := 0;
    signal freq_nco_internal : integer := 0;
    signal freq_nco_accum : integer := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            freq_err <= 0;
            freq_nco_internal <= 0;
            freq_nco_accum <= 0;
        elsif clk'event and clk = '1' then
            -- Calculate frequency error
            if I_signal /= previous_signal then
                freq_err <= freq_err + 1;
            else
                freq_err <= freq_err - 1;
            end if;

            -- Update frequency NCO
            freq_nco_accum <= freq_nco_accum + freq_nco_internal + freq_err;
            freq_nco_internal <= freq_nco_accum / 256;  -- Simplified scaling
        end if;
    end process;

    freq_nco <= std_logic_vector(to_signed(freq_nco_internal, 16));
end Behavioral;
