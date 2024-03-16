library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP is
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
      command: in std_logic_vector(7 downto 0);
      end_command_interrupt: out std_logic;
      --axi slave
      axis_s_data_in: in std_logic_vector(AXI_WIDTH-1 downto 0);
      axis_s_valid: in std_logic;
      axis_s_last: in std_logic;
      axis_s_ready: out std_logic;
      --axi master
      axim_s_data_out: out std_logic_vector(AXI_WIDTH - 1 downto 0);
      axim_s_valid: out std_logic;
      axim_s_last: out std_logic;
      axim_s_ready: in std_logic
      );
end TOP;

architecture Behavioral of TOP is
signal en_parray_s, we_parray_s: std_logic;
signal addr_parray_write_s : std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0); 
signal addr_parray_read_1_s : std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0); 
signal addr_parray_read_2_s : std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0);
signal data_parray_out_s : std_logic_vector(PARRAY_RAM_WIDTH - 1 downto 0);
signal data_parray_in_1_s : std_logic_vector(PARRAY_RAM_WIDTH - 1 downto 0);
signal data_parray_in_2_s : std_logic_vector(PARRAY_RAM_WIDTH - 1 downto 0);
--Sarray
signal en_sarray_s, we_sarray_s: std_logic;
signal addr_sarray_write_s : std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0); 
signal addr_sarray_read_1_s : std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0); 
signal addr_sarray_read_2_s : std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0); 
signal data_sarray_out_s : std_logic_vector(SARRAY_RAM_WIDTH - 1 downto 0);
signal data_sarray_in_1_s : std_logic_vector(SARRAY_RAM_WIDTH - 1 downto 0);
signal data_sarray_in_2_s : std_logic_vector(SARRAY_RAM_WIDTH - 1 downto 0);
--Storage
signal en_storage_s, we_storage_s: std_logic;
signal addr_storage_write_s : std_logic_vector(STORAGE_ADDR_SIZE - 1  downto 0); 
signal addr_storage_read_s : std_logic_vector(STORAGE_ADDR_SIZE - 1  downto 0); 
signal data_storage_out_s : std_logic_vector(STORAGE_RAM_WIDTH - 1 downto 0);
signal data_storage_in_s : std_logic_vector(STORAGE_RAM_WIDTH - 1 downto 0);

begin
encryption_logic: entity work.ENCRYPTION_LOGIC
generic map(AXI_WIDTH => AXI_WIDTH,
            PARRAY_RAM_WIDTH => PARRAY_RAM_WIDTH,
            PARRAY_RAM_DEPTH => PARRAY_RAM_DEPTH,
            PARRAY_ADDR_SIZE => PARRAY_ADDR_SIZE,
            SARRAY_RAM_WIDTH => SARRAY_RAM_WIDTH,
            SARRAY_RAM_DEPTH => SARRAY_RAM_DEPTH,
            SARRAY_ADDR_SIZE => SARRAY_ADDR_SIZE, 
            STORAGE_RAM_WIDTH => STORAGE_RAM_WIDTH,
            STORAGE_RAM_DEPTH => STORAGE_RAM_DEPTH,
            STORAGE_ADDR_SIZE => STORAGE_ADDR_SIZE
            )
port map(clk => clk,
      command => command,
      end_command_interrupt => end_command_interrupt,
      en_parray => en_parray_s,
      we_parray => we_parray_s,
      addr_parray_write => addr_parray_write_s,
      addr_parray_read_1 => addr_parray_read_1_s,
	  addr_parray_read_2 => addr_parray_read_2_s,
      data_parray_out => data_parray_out_s,
      data_parray_in_1 => data_parray_in_1_s,
	  data_parray_in_2 => data_parray_in_2_s,
      en_sarray => en_sarray_s,
      we_sarray => we_sarray_s,
      addr_sarray_write => addr_sarray_write_s,
      addr_sarray_read_1 => addr_sarray_read_1_s,
	  addr_sarray_read_2 => addr_sarray_read_2_s,
      data_sarray_out => data_sarray_out_s,
      data_sarray_in_1 => data_sarray_in_1_s,
	  data_sarray_in_2 => data_sarray_in_2_s,
      en_storage => en_storage_s,
      we_storage => we_storage_s,
      addr_storage_write => addr_storage_write_s,
      addr_storage_read => addr_storage_read_s,
      data_storage_out => data_storage_out_s,
      data_storage_in => data_storage_in_s,
      axis_s_data_in => axis_s_data_in,
      axis_s_valid => axis_s_valid,
      axis_s_last => axis_s_last,
      axis_s_ready => axis_s_ready,
      axim_s_valid => axim_s_valid,
      axim_s_last => axim_s_last,
      axim_s_ready => axim_s_ready);
      
memory: entity work.MEMORY_BRAM
generic map(AXI_WIDTH => AXI_WIDTH,
            PARRAY_RAM_WIDTH => PARRAY_RAM_WIDTH,
            PARRAY_RAM_DEPTH => PARRAY_RAM_DEPTH,
            PARRAY_ADDR_SIZE => PARRAY_ADDR_SIZE,
            SARRAY_RAM_WIDTH => SARRAY_RAM_WIDTH,
            SARRAY_RAM_DEPTH => SARRAY_RAM_DEPTH,
            SARRAY_ADDR_SIZE => SARRAY_ADDR_SIZE, 
            STORAGE_RAM_WIDTH => STORAGE_RAM_WIDTH,
            STORAGE_RAM_DEPTH => STORAGE_RAM_DEPTH,
            STORAGE_ADDR_SIZE => STORAGE_ADDR_SIZE
            )
port map (clk => clk,
      en_parray => en_parray_s,
      we_parray => we_parray_s,
      addr_parray_write => addr_parray_write_s,
      addr_parray_read_1 => addr_parray_read_1_s,
	  addr_parray_read_2 => addr_parray_read_2_s,
      data_parray_in => data_parray_out_s,
      data_parray_out_1 => data_parray_in_1_s,
	  data_parray_out_2 => data_parray_in_2_s,
      en_sarray => en_sarray_s,
      we_sarray => we_sarray_s,
      addr_sarray_write => addr_sarray_write_s,
      addr_sarray_read_1 => addr_sarray_read_1_s,
	  addr_sarray_read_2 => addr_sarray_read_2_s,
      data_sarray_in => data_sarray_out_s,
      data_sarray_out_1 => data_sarray_in_1_s,
	  data_sarray_out_2 => data_sarray_in_2_s,
      en_storage => en_storage_s,
      we_storage => we_storage_s,
      addr_storage_write => addr_storage_write_s,
      addr_storage_read => addr_storage_read_s,
      data_storage_in => data_storage_out_s,
      data_storage_out => data_storage_in_s);

axim_s_data_out <= data_storage_in_s;
end Behavioral;
