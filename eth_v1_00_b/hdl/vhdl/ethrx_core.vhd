library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_core is
	generic (
		rx_data_pins : natural := 4;
		async        : boolean := true
	);
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_clock	: in std_logic;
		rx_data		: in std_logic_vector(rx_data_pins-1 downto 0);
		rx_dvalid	: in std_logic;

		reg_status_wr	: in std_logic;
		reg_status	: out std_logic_vector(0 to 31);
		reg_fifo_rd	: in std_logic;
		reg_fifo	: out std_logic_vector(0 to 31)

	);
end ethrx_core;

architecture RTL of ethrx_core is

	component ethrx_clk_sampler is
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_clock	: in std_logic;
		rx_clock_pulse  : out std_logic
	);
	end component ethrx_clk_sampler;

	signal rx_clock_pulse : std_logic;

	component ethrx_statemachine is
	generic (
		rx_data_pins	: natural := 4
	);
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_clock_pulse	: in std_logic;
		rx_data		: in std_logic_vector(rx_data_pins-1 downto 0);
		rx_dvalid	: in std_logic;
		
		sample_rx	: out std_logic
	);
	end component ethrx_statemachine;

	signal sample_rx : std_logic;

	component ethrx_debug is
	generic (
		data_pins	: natural := 4
	);
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_clock_pulse	: in std_logic;
		rx_data		: in std_logic_vector(data_pins-1 downto 0);
		rx_dvalid	: in std_logic;

		debugfile0	: out std_logic_vector(0 to 31);
		debugfile1	: out std_logic_vector(0 to 31)

		
	);
	end component ethrx_debug;

	signal debugfile : std_logic_vector(0 to 63);

	component ethrx_mii_to_byte is
	generic (
		data_pins	: natural := 4;
		rx_order_BigE	: boolean := true
	);
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		sample_rx	: in std_logic;

		rx_clock_pulse	: in std_logic;
		rx_data		: in std_logic_vector(data_pins-1 downto 0);
		rx_dvalid	: in std_logic;
		
		byte_pkt_start	: out std_logic;
		byte_pkt_end	: out std_logic;
		byte_data	: out std_logic_vector(7 downto 0);
		byte_dvalid	: out std_logic
	);
	end component ethrx_mii_to_byte;
	
	signal byte_pkt_start	: std_logic;
	signal byte_pkt_end	: std_logic;
	signal byte_data	: std_logic_vector(7 downto 0);
	signal byte_dvalid	: std_logic;
		
	component ethrx_byte_to_word is
		port (
			sys_clk		: in std_logic; -- rising edge
			sys_reset	: in std_logic; -- synchronous reset on 1

			byte_pkt_start  : in std_logic;
			byte_pkt_end    : in std_logic;
			byte_data	: in std_logic_vector(7 downto 0);
			byte_dvalid	: in std_logic;
		
			word_pkt_start	: out std_logic;
			word_pkt_end	: out std_logic;
			word_data	: out std_logic_vector(0 to 31);
			word_dv_bytes	: out std_logic_vector(0 to 2)
		);
	end component ethrx_byte_to_word;

	signal word_pkt_start	: std_logic;
	signal word_pkt_end	: std_logic;
	signal word_data	: std_logic_vector(0 to 31);
	signal word_dv_bytes	: std_logic_vector(0 to 2);

	component ethrx_regfile is 
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		reg_status_wr	: in std_logic;
		reg_status	: out std_logic_vector(0 to 31);
		reg_fifo_rd	: in std_logic;
		reg_fifo	: out std_logic_vector(0 to 31);

		core_pkt_start	: in std_logic;
		core_pkt_end	: in std_logic;
		core_data	: in std_logic_vector(0 to 31);
		core_dv_bytes	: in std_logic_vector(0 to 2)

	);
	end component ethrx_regfile;

	component fifo_async
    	generic (data_bits	:integer;
             	addr_bits  :integer;
             	block_type	:integer := 0;
             	fifo_arch  :integer := 0); -- 0=Generic architecture, 
                	                   -- 1=Xilinx XAPP131, 
                        	           -- 2=Xilinx XAPP131 w/carry mux
    	port (reset		:in  std_logic;
          	wr_clk	:in  std_logic;
          	wr_en		:in  std_logic;
          	wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          	rd_clk	:in  std_logic;
          	rd_en		:in  std_logic;
          	rd_data	:out std_logic_vector (data_bits-1 downto 0);
          	full		:out std_logic;
          	empty		:out std_logic
         	);
  	end component;

	signal 
		rx_async_fifo_full, 
		rx_async_fifo_full_inv,
		rx_async_fifo_empty,
		rx_async_fifo_empty_inv : std_logic;
	signal rx_async_fifo_din, rx_async_fifo_dout : std_logic_vector(rx_data_pins downto 0);
	
	signal rx_clock_FDR  : std_logic;
	signal rx_data_FDR   : std_logic_vector(rx_data_pins-1 downto 0);
	signal rx_dvalid_FDR : std_logic;
begin

	gen0 : if async=false generate

		clockbuffering : process (sys_clk) begin
			if rising_edge(sys_clk) then
				if sys_reset='1' then
					rx_clock_FDR  <= '0';
					rx_data_FDR   <= (others => '0');
					rx_dvalid_FDR <= '0';
				else
					rx_clock_FDR  <= rx_clock;
					rx_data_FDR   <= rx_data;
					rx_dvalid_FDR <= rx_dvalid;
				end if;
			end if;
		end process clockbuffering;


		sampler : ethrx_clk_sampler
		port map (
			sys_clk		=> sys_clk,
			sys_reset	=> sys_reset,
			rx_clock	=> rx_clock_FDR,
			rx_clock_pulse  => rx_clock_pulse
		);

	end generate gen0;

	gen1 : if async=true generate

		rx_async_fifo :  fifo_async
    		generic map (
			data_bits  => rx_data_pins+1,
             		addr_bits  => 4,
             		block_type => 0,
             		fifo_arch  => 0) -- 0=Generic architecture, 
                	                   -- 1=Xilinx XAPP131, 
                        	           -- 2=Xilinx XAPP131 w/carry mux
    		port map (
			reset	=> sys_reset,
        	  	wr_clk	=> rx_clock,
          		wr_en	=> rx_async_fifo_full_inv,
	          	wr_data	=> rx_async_fifo_din,
        	  	rd_clk	=> sys_clk,
          		rd_en	=> rx_async_fifo_empty_inv,
          		rd_data	=> rx_async_fifo_dout,
          		full	=> rx_async_fifo_full,
          		empty	=> rx_async_fifo_empty
         	);
		rx_async_fifo_din <= rx_dvalid & rx_data;
		rx_dvalid_FDR <= rx_async_fifo_dout(rx_data_pins);
		rx_data_FDR <= rx_async_fifo_dout(rx_data_pins-1 downto 0);

		rx_async_fifo_full_inv <= not rx_async_fifo_full;
		rx_async_fifo_empty_inv <= not rx_async_fifo_empty;
		
		rx_clock_pulse <= not rx_async_fifo_empty;
		
	end generate gen1;
	

	statemachine : ethrx_statemachine
	generic map (
		rx_data_pins	=> rx_data_pins
	)
	port map (
		sys_clk		=> sys_clk,
		sys_reset	=> sys_reset,
		rx_clock_pulse	=> rx_clock_pulse,
		rx_data		=> rx_data_FDR,
		rx_dvalid	=> rx_dvalid_FDR,
		sample_rx	=> sample_rx
	);

	bytemaker : ethrx_mii_to_byte
	generic map (
		data_pins	=> rx_data_pins,
		rx_order_BigE	=> true
	)
	port map (
		sys_clk		=> sys_clk,
		sys_reset	=> sys_reset,
		sample_rx	=> sample_rx,
		rx_clock_pulse	=> rx_clock_pulse,
		rx_data		=> rx_data_FDR,
		rx_dvalid	=> rx_dvalid_FDR,
		byte_pkt_start	=> byte_pkt_start,
		byte_pkt_end	=> byte_pkt_end,
		byte_data	=> byte_data,
		byte_dvalid	=> byte_dvalid
	);

	wordmaker : ethrx_byte_to_word 
	port map (
		sys_clk		=> sys_clk,
		sys_reset	=> sys_reset,

		byte_pkt_start  => byte_pkt_start,
		byte_pkt_end    => byte_pkt_end,
		byte_data	=> byte_data,
		byte_dvalid	=> byte_dvalid,
		
		word_pkt_start	=> word_pkt_start,
		word_pkt_end	=> word_pkt_end,
		word_data	=> word_data,
		word_dv_bytes	=> word_dv_bytes
	);
	
	regfile : ethrx_regfile  
	port map (
		sys_clk		=> sys_clk,
		sys_reset	=> sys_reset,

		reg_status_wr	=> reg_status_wr,
		reg_status	=> reg_status,
		reg_fifo_rd	=> reg_fifo_rd,
		reg_fifo	=> reg_fifo,
		
		core_pkt_start	=> word_pkt_start,
		core_pkt_end	=> word_pkt_end, 
		core_data	=> word_data,
		core_dv_bytes	=> word_dv_bytes

	);

	
end architecture RTL;
