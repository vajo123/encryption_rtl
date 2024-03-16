library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ENCRYPTION_IP_v1_0 is
	generic (
		-- Users to add parameters here
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
        STORAGE_ADDR_SIZE : integer := 14; 
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        end_command_interrupt: out std_logic;
        --AXI STREAM SLAVE SIGNALS
        axis_s_data_in: in std_logic_vector(AXI_WIDTH-1 downto 0);
        axis_s_valid:in std_logic;
        axis_s_last:in std_logic;
        axis_s_ready:out std_logic;
        --AXI STREAM MASTER SIGNALS
        axim_s_valid:out std_logic;
        axim_s_last:out std_logic;
        axim_s_ready:in std_logic;
        axim_s_data_out: out std_logic_vector(AXI_WIDTH-1 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line

        
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end ENCRYPTION_IP_v1_0;

architecture arch_imp of ENCRYPTION_IP_v1_0 is

	-- component declaration
	component ENCRYPTION_IP_v1_0_S00_AXI
		generic (
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
	       );
		
		port (
		command: out std_logic_vector(7 downto 0);
		end_command_interrupt: in std_logic;
		 
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component;
	
component TOP
            generic (
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
				STORAGE_ADDR_SIZE : integer := 14
                );
            Port(
				clk: in std_logic; 
                --AXI_SLAVE_STREAM signals
                axis_s_data_in:in std_logic_vector(AXI_WIDTH-1 downto 0);
                axis_s_valid:in std_logic;
                axis_s_last:in std_logic;
                axis_s_ready:out std_logic;
                
                command: in std_logic_vector(7 downto 0);
                
                --interrupt
                end_command_interrupt: out std_logic;
              
				--AXI_MASTER_STREAM  signals
                axim_s_valid:out std_logic;
                axim_s_last:out std_logic;
                axim_s_ready:in std_logic;
                axim_s_data_out:out std_logic_vector(AXI_WIDTH-1 downto 0)
                );
    end component;
    signal command_s: std_logic_vector(7 downto 0);
    signal end_command_s: std_logic;
begin

-- Instantiation of Axi Bus Interface S00_AXI
ENCRYPTION_IP_v1_0_S00_AXI_inst : ENCRYPTION_IP_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    command => command_s,
	    end_command_interrupt => end_command_s,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	TOP_inst: TOP
    generic map(
				AXI_WIDTH => AXI_WIDTH ,        
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
			clk=> s00_axi_aclk, 
            --AXI_SLAVE_STREAM signals
            axis_s_data_in => axis_s_data_in,
            axis_s_valid=>axis_s_valid ,
            axis_s_last=>axis_s_last ,
            axis_s_ready=>axis_s_ready ,
            
            command=>command_s ,
            
            --interrupt
            end_command_interrupt => end_command_s,
          
          ----AXI_MASTER_STREAM  signals
            axim_s_valid=>axim_s_valid ,
            axim_s_last=>axim_s_last ,
            axim_s_ready=>axim_s_ready ,
            axim_s_data_out=> axim_s_data_out
             );
	-- Add user logic here
	end_command_interrupt <= end_command_s;
	-- User logic ends

end arch_imp;
