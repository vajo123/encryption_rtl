library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BRAM_2READ_PORTS is
generic (
        RAM_WIDTH : integer := 8;
        RAM_DEPTH : integer := 214;
        ADDR_SIZE : integer := 8); --based on RAM_DEPTH   ADDR_SIZE = log2(RAM_DEPTH);
port (
        clk : in std_logic;
        en : in std_logic;
        we : in std_logic;
        addr_read1 : in std_logic_vector(ADDR_SIZE-1  downto 0);
        addr_read2 : in std_logic_vector(ADDR_SIZE-1  downto 0);
        addr_write : in std_logic_vector(ADDR_SIZE-1  downto 0);
        data_in : in std_logic_vector(RAM_WIDTH - 1 downto 0);
        data_out1 : out std_logic_vector(RAM_WIDTH - 1 downto 0);
        data_out2 : out std_logic_vector(RAM_WIDTH - 1 downto 0);
        data_out3 : out std_logic_vector(RAM_WIDTH - 1 downto 0)
  );
end BRAM_2READ_PORTS;

architecture Behavioral of BRAM_2READ_PORTS is
type ram_type is array (0 to RAM_DEPTH - 1) of std_logic_vector(RAM_WIDTH - 1 downto 0);
signal memory : ram_type;
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        if we = '1' then   
          memory(to_integer(unsigned(addr_write))) <= data_in;
        end if;
        data_out1 <= memory(to_integer(unsigned(addr_read1)));
        data_out2 <= memory(to_integer(unsigned(addr_read2)));
      end if;
    end if;
  end process;
end Behavioral;
