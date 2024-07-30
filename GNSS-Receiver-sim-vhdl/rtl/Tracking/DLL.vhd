library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dll is
    Port ( 
        clk        : in  std_logic;
        reset      : in  std_logic;
        I_signal   : in  std_logic;
        early_code : in  std_logic;
        prompt_code: in  std_logic;
        late_code  : in  std_logic;
        code_nco   : out std_logic_vector(15 downto 0)
        );
end dll;

architecture Behavioral of dll is
    signal early_corr, prompt_corr, late_corr : integer := 0;
    signal code_nco_internal : integer := 0;
    signal code_nco_accum : integer := 0;
    signal freq_err : integer := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            early_corr <= 0;
            prompt_corr <= 0;
            late_corr <= 0;
            code_nco_internal <= 0;
            code_nco_accum <= 0;
        elsif clk'event and clk = '1' then
            -- Early, Prompt, Late correlation
            if early_code = I_signal then
                early_corr <= early_corr + 1;
            else
                early_corr <= early_corr - 1;
            end if;
            
            if prompt_code = I_signal then
                prompt_corr <= prompt_corr + 1;
            else
                prompt_corr <= prompt_corr - 1;
            end if;

            if late_code = I_signal then
                late_corr <= late_corr + 1;
            else
                late_corr <= late_corr - 1;
            end if;

            -- Calculate frequency error
            freq_err <= early_corr - late_corr;

            -- Update code NCO
            code_nco_accum <= code_nco_accum + code_nco_internal + freq_err;
            code_nco_internal <= code_nco_accum / 256;  -- Simplified scaling
        end if;
    end process;

    code_nco <= std_logic_vector(to_signed(code_nco_internal, 16));
end Behavioral;
