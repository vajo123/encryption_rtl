library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ENCRYPTION_LOGIC is
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
	  --input_size: in std_logic_vector(AXI_WIDTH - 1 downto 0);
      end_command_interrupt: out std_logic;
      --Parray
      en_parray, we_parray : out std_logic;
      addr_parray_write : out std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0); 
      addr_parray_read_1 : out std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0); 
	  addr_parray_read_2 : out std_logic_vector(PARRAY_ADDR_SIZE - 1 downto 0);
      data_parray_out : out std_logic_vector(PARRAY_RAM_WIDTH - 1 downto 0);
      data_parray_in_1 : in std_logic_vector(PARRAY_RAM_WIDTH - 1 downto 0);
	  data_parray_in_2 : in std_logic_vector(PARRAY_RAM_WIDTH - 1 downto 0);
      --Sarray
      en_sarray, we_sarray : out std_logic;
      addr_sarray_write : out std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0); 
      addr_sarray_read_1 : out std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0); 
	  addr_sarray_read_2 : out std_logic_vector(SARRAY_ADDR_SIZE - 1 downto 0); 
      data_sarray_out : out std_logic_vector(SARRAY_RAM_WIDTH - 1 downto 0);
      data_sarray_in_1 : in std_logic_vector(SARRAY_RAM_WIDTH - 1 downto 0);
	  data_sarray_in_2 : in std_logic_vector(SARRAY_RAM_WIDTH - 1 downto 0);
      --Storage
      en_storage, we_storage : out std_logic;
      addr_storage_write : out std_logic_vector(STORAGE_ADDR_SIZE - 1  downto 0); 
      addr_storage_read : out std_logic_vector(STORAGE_ADDR_SIZE - 1  downto 0); 
      data_storage_out : out std_logic_vector(STORAGE_RAM_WIDTH - 1 downto 0);
      data_storage_in : in std_logic_vector(STORAGE_RAM_WIDTH - 1 downto 0);
      --AXI_SLAVE_STREAM signals
      axis_s_data_in : in std_logic_vector(AXI_WIDTH - 1 downto 0);
      axis_s_valid : in std_logic;
      axis_s_last : in std_logic;
      axis_s_ready : out std_logic;
      --AXI_MASTER_STREAM signals
      axim_s_valid : out std_logic;
      axim_s_last : out std_logic;
      axim_s_ready : in std_logic);
end ENCRYPTION_LOGIC;

architecture Behavioral of ENCRYPTION_LOGIC is

--attribute use_dsp : string;
--attribute use_dsp of Behavioral : architecture is "yes";

type state is (IDLE, LOAD_DATA_INTO_BRAM, ENCRYPTION, DECRYPTION, ENCRYPT_DECRYPT_LOOP, F_STATE, END_LOOP_ENCRYPT, END_LOOP_DECRYPT, END_LOOP_2, SEND_DATA_FROM_BRAM, END_COMMAND);
signal state_reg, state_next: state;

signal addr_reg, addr_next : std_logic_vector(STORAGE_ADDR_SIZE - 1 downto 0);
signal input_size_reg, input_size_next : std_logic_vector(STORAGE_ADDR_SIZE - 1 downto 0);
signal i_reg, i_next : std_logic_vector(STORAGE_ADDR_SIZE downto 0);
signal left_reg, left_next : std_logic_vector(31 downto 0);
signal right_reg, right_next : std_logic_vector(31 downto 0);
signal i_en_de_reg, i_en_de_next : std_logic_vector(4 downto 0);
signal c_reg, c_next : std_logic_vector(7 downto 0);
signal d_reg, d_next : std_logic_vector(7 downto 0);
signal f_flag_reg, f_flag_next : std_logic;
signal f_result_reg, f_result_next : std_logic_vector(31 downto 0);
signal final_data_reg, final_data_next : std_logic_vector(63 downto 0);
--ovde dodati sve registre koji ti trebaju u kodu

--adder
signal en_adder_s: std_logic;
signal input1_adder_s: std_logic_vector(31 downto 0);
signal input2_adder_s: std_logic_vector(31 downto 0);
signal output_adder_s: std_logic_vector(32 downto 0);

constant N : integer := 16;
begin

process(clk)
begin
	if (rising_edge(clk)) then
		if (command = "10000000") then 
			state_reg <= IDLE;
			addr_reg <= (others => '0');
			input_size_reg <= (others => '0');
			i_reg <= (others => '0');
			left_reg <= (others => '0');
			right_reg <= (others => '0');
			i_en_de_reg <= (others => '0');
			c_reg <= (others => '0');
			d_reg <= (others => '0');
			f_flag_reg <= '0';
			f_result_reg <= (others => '0');
			final_data_reg <= (others => '0');
		
		else
			state_reg <= state_next;
			addr_reg <= addr_next;
			input_size_reg <= input_size_next;
			i_reg <= i_next;
			left_reg <= left_next;
			right_reg <= right_next;
			i_en_de_reg <= i_en_de_next;
			c_reg <= c_next;
			d_reg <= d_next;
			f_flag_reg <= f_flag_next;
			f_result_reg <= f_result_next;
			final_data_reg <= final_data_next;
			
		end if;
	end if;
end process;

process(state_reg, command, axis_s_data_in, axis_s_last, axis_s_valid, axim_s_ready, addr_reg, input_size_reg, i_reg, i_next, left_reg, left_next, right_reg, i_en_de_reg, i_en_de_next, data_parray_in_1, data_parray_in_2, data_sarray_in_1, data_sarray_in_2, data_storage_in, c_reg, d_reg, f_flag_reg, f_result_reg, final_data_reg, output_adder_s)
begin

	axis_s_ready <= '0';
	axim_s_valid <= '0';
	axim_s_last <= '0';
	
	end_command_interrupt <= '0';
	
	en_parray <= '0';
	we_parray <= '0';
	addr_parray_read_1 <= (others => '0');
	addr_parray_read_2 <= (others => '0');
	addr_parray_write <= (others => '0');
	
	en_sarray <= '0';
	we_sarray <= '0';
	addr_sarray_read_1 <= (others => '0');
	addr_sarray_read_2 <= (others => '0');
	addr_sarray_write <= (others => '0');
	
	en_storage <= '0';
	we_storage <= '0';
	addr_storage_read <= (others => '0');
	addr_storage_write <= (others => '0');
		
	--registri
	addr_next <= addr_reg;
	input_size_next <= input_size_reg;
	i_next <= i_reg;
	left_next <= left_reg;
	right_next <= right_reg;
	i_en_de_next <= i_en_de_reg;
	c_next <= c_reg;
	d_next <= d_reg;
	f_flag_next <= f_flag_reg;
	f_result_next <= f_result_reg;
	final_data_next <= final_data_reg;
	
	--adder
    en_adder_s <= '0';
    input1_adder_s <= (others => '0');
    input2_adder_s <= (others => '0');
	
	--treba da stoji ovde, jer jednom primamo podatke iz axi-a a drugi put upisujemo obradjene podatke
	data_storage_out <= axis_s_data_in(STORAGE_RAM_WIDTH - 1 downto 0);
	
	case state_reg is 
		when IDLE =>
			addr_next <= (others => '0');
			
			if(command(0) = '1' or command(1) = '1') then
				state_next <= LOAD_DATA_INTO_BRAM;
			
			elsif(command(2) = '1') then
				input_size_next <= (others => '0');
				state_next <= LOAD_DATA_INTO_BRAM;
				
			elsif(command(3) = '1') then
				i_next <= (others => '0');
				en_storage <= '1';
				addr_storage_read <= (others => '0');
				state_next <= ENCRYPTION;
				
			elsif(command(4) = '1') then
				i_next <= (others => '0');
				en_storage <= '1';
				addr_storage_read <= (others => '0');
				state_next <= DECRYPTION;
			
			elsif(command(5) = '1') then
				addr_next <= std_logic_vector(to_unsigned(1, STORAGE_ADDR_SIZE));
				state_next <= SEND_DATA_FROM_BRAM;
				
			else
				state_next <= IDLE;
				
			end if;
		
		when LOAD_DATA_INTO_BRAM =>
			axis_s_ready <= '1';
			
			if(axis_s_valid = '1') then
				if(axis_s_last = '0') then
					state_next <= LOAD_DATA_INTO_BRAM;
				else
					state_next <= END_COMMAND;
				end if;
				
				addr_next <= std_logic_vector(UNSIGNED(addr_reg) + to_unsigned(1, STORAGE_ADDR_SIZE));
				
				if(command(0) = '1') then
					en_parray <= '1';
					we_parray <= '1';
					addr_parray_write <= addr_reg(PARRAY_ADDR_SIZE - 1 downto 0);
				
				elsif(command(1) = '1') then
					en_sarray <= '1';
					we_sarray <= '1';
					addr_sarray_write <= addr_reg(SARRAY_ADDR_SIZE - 1 downto 0);
				
				elsif(command(2) = '1') then
					en_storage <= '1';
					we_storage <= '1';
					addr_storage_write <= addr_reg(STORAGE_ADDR_SIZE - 1 downto 0);
					
					input_size_next <= std_logic_vector(UNSIGNED(input_size_reg) + to_unsigned(1, STORAGE_ADDR_SIZE));
				end if;
			else
				state_next <= LOAD_DATA_INTO_BRAM;
			end if;
		
		when ENCRYPTION =>
			right_next <= data_storage_in(31 downto 0);
			left_next <= data_storage_in(63 downto 32);
			
			i_en_de_next <= (others => '0');
			en_parray <= '1';
			addr_parray_read_1 <= (others => '0');
			
			state_next <= ENCRYPT_DECRYPT_LOOP;
			
		when DECRYPTION =>
			right_next <= data_storage_in(31 downto 0);
			left_next <= data_storage_in(63 downto 32);
			
			i_en_de_next <= std_logic_vector(to_unsigned(N, 5) + to_unsigned(1, 5));
			en_parray <= '1';
			addr_parray_read_1 <= std_logic_vector(to_unsigned(N, 5) + to_unsigned(1, 5));
	
			state_next <= ENCRYPT_DECRYPT_LOOP;
			
		when ENCRYPT_DECRYPT_LOOP =>
			left_next <= left_reg xor data_parray_in_1;
			c_next <= left_next(15 downto 8);
			d_next <= left_next(7 downto 0);
			
			en_sarray <= '1';
			addr_sarray_read_1 <= "00" & left_next(31 downto 24);
			addr_sarray_read_2 <= std_logic_vector(to_unsigned(256, 10) + UNSIGNED(left_next(23 downto 16)));
			
			f_flag_next <= '0';
			state_next <= F_STATE;
				
		when F_STATE =>
			if(f_flag_reg = '0') then
			    en_adder_s <= '1';            
                input1_adder_s <= data_sarray_in_1;
                input2_adder_s <= data_sarray_in_2;            
                f_result_next <= output_adder_s(31 downto 0);
				--f_result_next <= std_logic_vector(unsigned(data_sarray_in_1) + unsigned(data_sarray_in_2));
			
				en_sarray <= '1';
				addr_sarray_read_1 <= std_logic_vector(to_unsigned(512, 10) + UNSIGNED(c_reg));
				addr_sarray_read_2 <= std_logic_vector(to_unsigned(768, 10) + UNSIGNED(d_reg));
				
				f_flag_next <= '1';
				state_next <= F_STATE;
			else
			    en_adder_s <= '1';            
                input1_adder_s <= f_result_reg xor data_sarray_in_1;
                input2_adder_s <= data_sarray_in_2;            
                f_result_next <= output_adder_s(31 downto 0);
				--f_result_next <= std_logic_vector(unsigned(f_result_reg xor data_sarray_in_1) + unsigned(data_sarray_in_2));
			
				f_flag_next <= '0';
				
				if (command(3) = '1') then
					state_next <= END_LOOP_ENCRYPT;
				else
					state_next <= END_LOOP_DECRYPT;
				end if;
			end if;
	
		when END_LOOP_ENCRYPT =>
			left_next <= f_result_reg xor right_reg;
			right_next <= left_reg;
			
			i_en_de_next <= std_logic_vector(unsigned(i_en_de_reg) + TO_UNSIGNED(1, 5));
			if(to_integer(unsigned(i_en_de_next)) = N) then
				state_next <= END_LOOP_2;
				en_parray <= '1';
				addr_parray_read_1 <= std_logic_vector(to_unsigned(16, 5));
				addr_parray_read_2 <= std_logic_vector(to_unsigned(17, 5));
			else
				state_next <= ENCRYPT_DECRYPT_LOOP;
				en_parray <= '1';
				addr_parray_read_1 <= i_en_de_next;
			end if;
				
		when END_LOOP_DECRYPT =>
			left_next <= f_result_reg xor right_reg;
			right_next <= left_reg;
			
			i_en_de_next <= std_logic_vector(unsigned(i_en_de_reg) - TO_UNSIGNED(1, 5));
			if(to_integer(unsigned(i_en_de_next)) = 1) then
				state_next <= END_LOOP_2;
				en_parray <= '1';
				addr_parray_read_1 <= std_logic_vector(to_unsigned(1, 5));
				addr_parray_read_2 <= std_logic_vector(to_unsigned(0, 5));
			else
				state_next <= ENCRYPT_DECRYPT_LOOP;
				en_parray <= '1';
				addr_parray_read_1 <= i_en_de_next;
			end if;
					
		when END_LOOP_2 =>
			en_storage <= '1';
			we_storage <= '1';
			addr_storage_write <= i_reg(STORAGE_ADDR_SIZE - 1  downto 0);
			data_storage_out <= (right_reg xor data_parray_in_2) & (left_reg xor data_parray_in_1);
			--right_next <= left_reg xor data_parray_in_1;
			--left_next <= right_reg xor data_parray_in_2;
			
			i_next <= std_logic_vector(unsigned(i_reg) + TO_UNSIGNED(1, STORAGE_ADDR_SIZE));
			if(unsigned(i_next) = unsigned(input_size_reg)) then
				state_next <= END_COMMAND;
			else
				if (command(3) = '1') then
					state_next <= ENCRYPTION;
				else
					state_next <= DECRYPTION;
				end if;
				en_storage <= '1';
				addr_storage_read <= i_next(STORAGE_ADDR_SIZE - 1  downto 0);
			end if;
	
		when SEND_DATA_FROM_BRAM =>
			if(unsigned(addr_reg) < unsigned(input_size_reg)) then
                state_next <= SEND_DATA_FROM_BRAM;
            else 
                state_next <= END_COMMAND;
                axim_s_last <= '1';                
            end if;
            
            axim_s_valid <= '1';
            
            if(axim_s_ready = '1') then
                en_storage <= '1';
                addr_storage_read <= addr_reg;
                addr_next <= std_logic_vector(UNSIGNED(addr_reg) + to_unsigned(1, STORAGE_ADDR_SIZE));
            else
                addr_next <= addr_reg;
                state_next <= SEND_DATA_FROM_BRAM;  
            end if;
			
		when END_COMMAND =>
            end_command_interrupt <= '1';           
            state_next <= IDLE;
		
	end case;	
	
	data_parray_out <= axis_s_data_in(PARRAY_RAM_WIDTH - 1 downto 0);
	data_sarray_out <= axis_s_data_in(SARRAY_RAM_WIDTH - 1 downto 0);
	
end process;

adder:entity work.adder
    generic map (WIDTH => 32)
    port map(
            en => en_adder_s,
            input_1 => input1_adder_s,
            input_2 => input2_adder_s,
            output => output_adder_s
            );


end Behavioral;
