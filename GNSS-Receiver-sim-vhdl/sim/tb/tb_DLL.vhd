library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dll_tb is
end dll_tb;

architecture Behavioral of dll_tb is
    signal T_clk : std_logic := '0';
    signal T_reset : std_logic := '1';
    signal T_I_signal : std_logic := '0';
    signal T_early_code, T_prompt_code, T_late_code : std_logic := '0';
    signal T_code_nco : std_logic_vector(15 downto 0);

    component dll
        Port ( clk        : in  STD_LOGIC;
               reset      : in  STD_LOGIC;
               I_signal   : in  STD_LOGIC;
               early_code : in  STD_LOGIC;
               prompt_code: in  STD_LOGIC;
               late_code  : in  STD_LOGIC;
               code_nco   : out STD_LOGIC_VECTOR(15 downto 0));
    end component;

begin
    uut: dll
        port map (
            clk => T_clk,
            reset => T_reset,
            I_signal => T_I_signal,
            early_code => T_early_code,
            prompt_code => T_prompt_code,
            late_code => T_late_code,
            code_nco => T_code_nco
        );

    T_clk <= not(clk) after 10 ns;
    T_reset <= '1','0' after 20 ns;

    stimulus : process
    begin
       
        -- Apply test vectors
        T_I_signal <= '1';
        T_early_code <= '1';
        T_prompt_code <= '1';
        T_late_code <= '0';
        wait for 100 ns;
        
        T_I_signal <= '0';
        T_early_code <= '0';
        T_prompt_code <= '0';
        T_late_code <= '1';
        wait for 100 ns;
        
        -- Add more test vectors as needed
        
        wait;
    end process;
end Behavioral;
