-- acquisition.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity acquisition is
    Port (
        clk                : in  STD_LOGIC;
        reset              : in  STD_LOGIC;
        enable             : in  STD_LOGIC;
        input_signal       : in  STD_LOGIC; -- Single-bit input signal
        correlation_result : out STD_LOGIC_VECTOR(15 downto 0) -- Example result width
    );
end acquisition;

architecture Behavioral of acquisition is
    -- Signals for the C/A code generator
    signal prn_code : std_logic;

    -- Declare the correlation process variables
    signal correlation_value : std_logic_vector(15 downto 0) := (others => '0');

    -- Generic for G2 delay (to be set for each satellite)
    constant G2_DELAY : integer := 5; -- Example delay for a specific satellite

    -- Component declaration for the C/A code generator
    component ca_code_generator
        generic (
            G2_DELAY : integer := 2  -- Default delay for a specific satellite
        );
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            enable    : in  STD_LOGIC;
            prn_code  : out STD_LOGIC
        );
    end component;

begin
    -- Instantiate the C/A code generator
    ca_gen_inst: ca_code_generator
        generic map (G2_DELAY => G2_DELAY)
        port map (
            clk       => clk,
            reset     => reset,
            enable    => enable,
            prn_code  => prn_code
        );

    -- Correlate input_signal with generated_prn_code
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                correlation_value <= (others => '0');
            elsif enable = '1' then
                -- Simple correlation: accumulate if input_signal matches generated_prn_code
                if (input_signal = '0' and prn_code = '1') or (input_signal = '1' and prn_code = '0') then
                    correlation_value <= correlation_value + 1;
                end if;
            end if;
        end if;
    end process;

    correlation_result <= correlation_value;
end Behavioral;
