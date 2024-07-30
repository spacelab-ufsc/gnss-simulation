library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pll is
    Port ( 
        clk             : in  std_logic;
        reset           : in  std_logic;
        I_signal        : in  std_logic;
        previous_signal : in  std_logic;
        phase_nco       : out std_logic_vector(15 downto 0)
        );
end pll;

architecture Behavioral of pll is
    signal phase_err : integer := 0;
    signal phase_nco_internal : integer := 0;
    signal phase_nco_accum : integer := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            phase_err <= 0;
            phase_nco_internal <= 0;
            phase_nco_accum <= 0;
        elsif clk'event and clk = '1' then
            -- Calculate phase error
            if I_signal = previous_signal then
                phase_err <= phase_err + 1;
            else
                phase_err <= phase_err - 1;
            end if;

            -- Update phase NCO
            phase_nco_accum <= phase_nco_accum + phase_nco_internal + phase_err;
            phase_nco_internal <= phase_nco_accum / 256;  -- Simplified scaling
        end if;
    end process;

    phase_nco <= std_logic_vector(to_signed(phase_nco_internal, 16));
end Behavioral;
