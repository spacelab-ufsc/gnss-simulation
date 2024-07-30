library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo is
    Port ( 
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic;
        wr_en    : in  std_logic;
        rd_en    : in  std_logic;
        data_out : out  std_logic;
        empty    : out  std_logic;
        full     : out  std_logic
        );
end fifo;

architecture Behavioral of fifo is
    constant FIFO_DEPTH : integer := 1024;
    signal fifo_mem : std_logic_vector(FIFO_DEPTH-1 downto 0);
    signal wr_ptr : integer range 0 to FIFO_DEPTH-1 := 0;
    signal rd_ptr : integer range 0 to FIFO_DEPTH-1 := 0;
    signal count : integer range 0 to FIFO_DEPTH := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
        elsif clk'event and clk = '1' then
            if wr_en = '1' and count < FIFO_DEPTH then
                fifo_mem(wr_ptr) <= data_in;
                wr_ptr <= (wr_ptr + 1) mod FIFO_DEPTH;
                count <= count + 1;
            end if;
            if rd_en = '1' and count > 0 then
                data_out <= fifo_mem(rd_ptr);
                rd_ptr <= (rd_ptr + 1) mod FIFO_DEPTH;
                count <= count - 1;
            end if;
        end if;
    end process;

    empty <= '1' when count = 0 else '0';
    full <= '1' when count = FIFO_DEPTH else '0';
end Behavioral;
