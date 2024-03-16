library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
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
--  Port ( );
end top_tb;

architecture Behavioral of top_tb is
signal clk: std_logic;
signal command: std_logic_vector(7 downto 0);
signal axis_s_data_in:  std_logic_vector(AXI_WIDTH-1 downto 0);
signal axis_s_valid, axis_s_last, axis_s_ready: std_logic;
signal axim_s_data_out:  std_logic_vector(AXI_WIDTH-1 downto 0);
signal axim_s_valid, axim_s_last, axim_s_ready: std_logic;
signal end_command_interrupt: std_logic;

begin

tb: entity work.TOP
generic map(
             AXI_WIDTH=>AXI_WIDTH,
             PARRAY_RAM_WIDTH => PARRAY_RAM_WIDTH,
             PARRAY_RAM_DEPTH => PARRAY_RAM_DEPTH,
             PARRAY_ADDR_SIZE => PARRAY_ADDR_SIZE,
             SARRAY_RAM_WIDTH => SARRAY_RAM_WIDTH,
             SARRAY_RAM_DEPTH => SARRAY_RAM_DEPTH,
             SARRAY_ADDR_SIZE => SARRAY_ADDR_SIZE, 
             STORAGE_RAM_WIDTH => STORAGE_RAM_WIDTH,
             STORAGE_RAM_DEPTH => STORAGE_RAM_DEPTH,
             STORAGE_ADDR_SIZE => STORAGE_ADDR_SIZE)
 port map(
             clk => clk,
             command => command,
             axis_s_data_in => axis_s_data_in,
             axis_s_valid => axis_s_valid,
             axis_s_last => axis_s_last,
             axis_s_ready => axis_s_ready,
             axim_s_data_out => axim_s_data_out,
             axim_s_valid => axim_s_valid,
             axim_s_last => axim_s_last,
             axim_s_ready => axim_s_ready,
             end_command_interrupt => end_command_interrupt
 );
 
 clk_gen: process
 begin
    clk <= '0', '1' after 5 ns;
    wait for 10 ns;
 end process;
 
 
 stim_gen: process
 variable i : integer := 0;
 begin
    --reset   
    command <= "10000000";
    axis_s_data_in <= (others => '0');
    axis_s_valid <= '0';
    axis_s_last <= '0';
    wait for 100 ns;
   
     --PUNJENJE PARRAY
     command <= "00000001";
     while(i < 18) loop
        if(i = 17) then
            axis_s_last <= '1';
        end if;
        if(axis_s_ready = '1') then  
            axis_s_valid <= '1';  
            axis_s_data_in <= std_logic_vector(to_unsigned(i, AXI_WIDTH));
            i := i + 1;
        end if;
        wait for 10ns;
     end loop;
     
     wait until falling_edge(end_command_interrupt);
     command <= "00000000";
     axis_s_valid <= '0';
     axis_s_last <= '0';
     i := 0;
     wait for 100 ns;
     
    --PUNJENJE SARRAY
     command <= "00000010";
     while(i < 1024) loop
        if(i = 1023) then
            axis_s_last <= '1';
        end if;
        if(axis_s_ready = '1') then  
            axis_s_valid <= '1';  
            axis_s_data_in <= std_logic_vector(to_unsigned(i, AXI_WIDTH));
            i := i + 1;
        end if;
        wait for 10ns;
     end loop;
     
     wait until falling_edge(end_command_interrupt);
     command <= "00000000";
     axis_s_valid <= '0';
     axis_s_last <= '0';
     i := 0;
     wait for 100 ns;
     
     --PUNJENJE INPUT_DATA
     command <= "00000100";
     while(i < 8) loop
        if(i = 7) then
            axis_s_last <= '1';
        end if;
        if(axis_s_ready = '1') then 
            axis_s_valid <= '1';   
            axis_s_data_in <= std_logic_vector(to_unsigned((i+1)*1000000000+1+i, AXI_WIDTH));
            i := i + 1;
        end if;
        wait for 10ns;
     end loop;
     
     wait until falling_edge(end_command_interrupt);
     command <= "00000000";
     axis_s_valid <= '0';
     axis_s_last <= '0';
     i := 0;
     wait for 100 ns;
    
     command <= "00001000";
     wait until falling_edge(end_command_interrupt);
    
    
     command <= "00100000";
     axim_s_ready <= '0';
     wait for 50 ns;
     axim_s_ready <= '1';
    
     wait until falling_edge(end_command_interrupt);
     axim_s_ready <= '0';
    
     command <= "00000000";
     wait for 100 ns;
    
     command <= "00010000";
     wait until falling_edge(end_command_interrupt);
    
    
     command <= "00100000";
     axim_s_ready <= '0';
     wait for 50 ns;
     axim_s_ready <= '1';
    
     wait until falling_edge(end_command_interrupt);
     axim_s_ready <= '0';
     
     command <= "00000000";
     wait;
     
 end process;



end Behavioral;
