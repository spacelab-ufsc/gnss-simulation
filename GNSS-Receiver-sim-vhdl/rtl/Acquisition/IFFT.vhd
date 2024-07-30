library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ifft is
    generic (
        N : integer := 8  -- IFFT length, must be a power of 2
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        start  : in  std_logic;
        x_real : in  std_logic_vector((N-1)*16 downto 0);
        x_imag : in  std_logic_vector((N-1)*16 downto 0);
        y_real : out std_logic_vector((N-1)*16 downto 0);
        y_imag : out std_logic_vector((N-1)*16 downto 0);
        done   : out std_logic
    );
end ifft;

architecture Behavioral of ifft is
    signal stage_real : std_logic_vector((N-1)*16 downto 0);
    signal stage_imag : std_logic_vector((N-1)*16 downto 0);
    signal W_real, W_imag : real_vector(0 to N/2-1);
    signal butterfly_real, butterfly_imag : std_logic_vector((N-1)*16 downto 0);
    signal done_int : std_logic := '0';

    function real2slv(x : real) return std_logic_vector is
        variable result : std_logic_vector(15 downto 0);
    begin
        result := std_logic_vector(to_signed(integer(x * 32768.0), 16));
        return result;
    end function;

    function slv2real(x : std_logic_vector) return real is
        variable result : real;
    begin
        result := real(to_integer(signed(x))) / 32768.0;
        return result;
    end function;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                stage_real <= (others => '0');
                stage_imag <= (others => '0');
                done_int <= '0';
            elsif start = '1' then
                -- Initialize W factors
                for k in 0 to N/2-1 loop
                    W_real(k) <= cos(2.0 * PI * real(k) / real(N));
                    W_imag(k) <= sin(2.0 * PI * real(k) / real(N));
                end loop;

                -- IFFT computation
                for s in 1 to integer(log2(real(N))) loop
                    for k in 0 to N/2-1 loop
                        butterfly_real(k*2) <= stage_real(k*2) + stage_real(k*2+1) * real2slv(W_real(k));
                        butterfly_imag(k*2) <= stage_imag(k*2) + stage_imag(k*2+1) * real2slv(W_imag(k));
                        butterfly_real(k*2+1) <= stage_real(k*2) - stage_real(k*2+1) * real2slv(W_real(k));
                        butterfly_imag(k*2+1) <= stage_imag(k*2) - stage_imag(k*2+1) * real2slv(W_imag(k));
                    end loop;

                    stage_real <= butterfly_real;
                    stage_imag <= butterfly_imag;
                end loop;

                done_int <= '1';
            end if;
        end if;
    end process;

    y_real <= stage_real;
    y_imag <= stage_imag;
    done <= done_int;
end Behavioral;
