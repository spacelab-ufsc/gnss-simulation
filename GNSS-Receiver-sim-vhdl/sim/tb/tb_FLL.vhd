library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fll_tb is
end fll_tb;

architecture Behavioral of fll_tb is
    signal T_clk : std_logic := '0';
    signal T_reset : std_logic := '1';
    signal T_I_signal : std_logic := '1';
    signal T_previous_signal : std_logic := '0';
    signal T_freq_nco : std_logic_vector(15 downto 0);

    component fll
        Port ( clk             : in  STD_LOGIC;
               reset           : in  STD_LOGIC;
               I_signal        : in  STD_LOGIC;
               previous_signal : in  STD_LOGIC;
               freq_nco        : out STD_LOGIC_VECTOR(15 downto 0));
    end component;

begin
    uut: fll
        port map (
            clk => T_clk,
            reset => T_reset,
            I_signal => T_I_signal,
            previous_signal => T_previous_signal,
            freq_nco => T_freq_nco
        );

    T_clk <= not(clk) after 10 ns;
    T_reset <= '1','0' after 20 ns;
    T_I_signal <= not(T_I_signal) after 100 ns;
    T_previous_signal <= not(T_previous_signal) after 100 ns;

end Behavioral;
