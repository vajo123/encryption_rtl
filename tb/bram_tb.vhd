library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram_tb is
generic (
        RAM_WIDTH : integer := 64;
        RAM_DEPTH : integer := 16384;
        ADDR_SIZE : integer := 14);
--  Port ( );
end bram_tb;

architecture Behavioral of bram_tb is
signal clk : std_logic;
signal we : std_logic;
signal en : std_logic;
signal addr_read : std_logic_vector(ADDR_SIZE - 1  downto 0);
signal addr_write : std_logic_vector(ADDR_SIZE-1  downto 0);         
signal data_in : std_logic_vector(RAM_WIDTH - 1 downto 0);  
signal data_out : std_logic_vector(RAM_WIDTH - 1 downto 0);

begin

bram_storage:entity work.BRAM 
    generic map(RAM_WIDTH=>RAM_WIDTH, RAM_DEPTH=>RAM_DEPTH, ADDR_SIZE=>ADDR_SIZE)
    port map(clk=>clk,
             en=>en, 
             we=>we,
             addr_read=>addr_read,
             addr_write=>addr_write,
             data_in=>data_in,
             data_out=>data_out);
             
clk_gen: process is
begin
    clk <= '0', '1' after 10 ns;
    wait for 20ns;
end process;

stim_gen: process is
begin
--inicijslizacija
addr_write <= (others => '0');
data_in <= (others => '0');
we <= '0';
en <= '0';

wait for 20 ns;

en <= '1';
we <= '1';

for i in 0 to 16383 
loop
    addr_write <= std_logic_vector(to_unsigned(i,ADDR_SIZE));
    data_in <= std_logic_vector(to_unsigned(i,RAM_WIDTH));
    wait for 20 ns;
end loop;

we <= '0';

wait for 20 ns;

for i in 0 to 16383
loop
    addr_read <= std_logic_vector(to_unsigned(i,ADDR_SIZE));
    wait for 20 ns;
end loop;
wait;

end process;

end Behavioral;
