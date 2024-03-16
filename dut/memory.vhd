library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MEMORY_BRAM is
generic (           
        --saljemo 64-bitne podatke, ali za s_array i p_array koristimo samo 32 donja bita           
        AXI_WIDTH: integer := 64;     
        --Parray   
        PARRAY_RAM_WIDTH : integer := 32;
        PARRAY_RAM_DEPTH : integer := 18;
        PARRAY_ADDR_SIZE : integer := 5;
        --Sarray    
        SARRAY_RAM_WIDTH : integer := 32;
        SARRAY_RAM_DEPTH : integer := 1024;
        SARRAY_ADDR_SIZE : integer := 10;
        --Storage    
        STORAGE_RAM_WIDTH : integer := 64;
        STORAGE_RAM_DEPTH : integer := 16384;
        STORAGE_ADDR_SIZE : integer := 14);
     
Port ( 
        clk: in std_logic;    
        --Parray
        en_parray, we_parray: in  std_logic;
        addr_parray_write: in  std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0);
        addr_parray_read_1:in  std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0);
        addr_parray_read_2:in  std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0);
        data_parray_in: in  std_logic_vector(PARRAY_RAM_WIDTH - 1  downto 0);
        data_parray_out_1: out  std_logic_vector(PARRAY_RAM_WIDTH - 1  downto 0);
        data_parray_out_2: out  std_logic_vector(PARRAY_RAM_WIDTH - 1  downto 0);
        --Sarray
        en_sarray, we_sarray: in  std_logic;
        addr_sarray_write: in  std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0);
        addr_sarray_read_1:in  std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0);
        addr_sarray_read_2:in  std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0);
        data_sarray_in: in  std_logic_vector(SARRAY_RAM_WIDTH - 1  downto 0);
        data_sarray_out_1: out  std_logic_vector(SARRAY_RAM_WIDTH - 1  downto 0); 
        data_sarray_out_2: out  std_logic_vector(SARRAY_RAM_WIDTH - 1  downto 0);
        --Storage
        en_storage, we_storage: in  std_logic;
        addr_storage_write: in  std_logic_vector(STORAGE_ADDR_SIZE - 1 downto 0);
        addr_storage_read:in  std_logic_vector(STORAGE_ADDR_SIZE - 1 downto 0);
        data_storage_in: in  std_logic_vector(STORAGE_RAM_WIDTH - 1  downto 0);
        data_storage_out: out  std_logic_vector(STORAGE_RAM_WIDTH - 1  downto 0)
     );
end MEMORY_BRAM;

architecture Behavioral of MEMORY_BRAM is
begin
bram_parray: entity work.BRAM_2READ_PORTS
generic map(RAM_WIDTH => PARRAY_RAM_WIDTH, RAM_DEPTH => PARRAY_RAM_DEPTH, ADDR_SIZE => PARRAY_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_parray,                                     
         we => we_parray,                                     
         addr_read1 => addr_parray_read_1,
		 addr_read2 => addr_parray_read_2, 
         addr_write => addr_parray_write,      
         data_in => data_parray_in, 
         data_out1 => data_parray_out_1,
		 data_out2 => data_parray_out_2);

bram_sarray: entity work.BRAM_2READ_PORTS
generic map(RAM_WIDTH => SARRAY_RAM_WIDTH, RAM_DEPTH => SARRAY_RAM_DEPTH, ADDR_SIZE => SARRAY_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_sarray,                                     
         we => we_sarray,                                     
         addr_read1 => addr_sarray_read_1,
		 addr_read2 => addr_sarray_read_2,		 
         addr_write => addr_sarray_write,      
         data_in => data_sarray_in, 
         data_out1 => data_sarray_out_1,
		 data_out2 => data_sarray_out_2);
		 
bram_storage: entity work.BRAM
generic map(RAM_WIDTH => STORAGE_RAM_WIDTH, RAM_DEPTH => STORAGE_RAM_DEPTH, ADDR_SIZE => STORAGE_ADDR_SIZE)
port map(clk => clk,                                     
         en => en_storage,                                     
         we => we_storage,                                     
         addr_read => addr_storage_read,                
         addr_write => addr_storage_write,      
         data_in => data_storage_in, 
         data_out => data_storage_out);

end Behavioral;
