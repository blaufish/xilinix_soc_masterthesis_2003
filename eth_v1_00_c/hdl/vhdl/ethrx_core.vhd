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

	component ethrx_statemachine is
	generic (
		rx_data_pins	: natural := 4
	);
	port (
		rx_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_data		: in std_logic_vector(rx_data_pins-1 downto 0);
		rx_dvalid	: in std_logic;
		
		sample_rx	: out std_logic
	);
	end component ethrx_statemachine;

	signal sample_rx : std_logic;

	component ethrx_mii_to_byte is
	generic (
		data_pins	: natural := 4;
		rx_order_BigE	: boolean := true
	);
	port (
		rx_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		sample_rx	: in std_logic;

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
			rx_clk		: in std_logic; -- rising edge
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

	signal core_pkt_start	: std_logic;
	signal core_pkt_end	: std_logic;
	signal core_data	: std_logic_vector(0 to 31);
	signal core_dv_bytes	: std_logic_vector(0 to 2);


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


	component ethrx_clkdomain is
	port (
		sys_clk   : in std_logic;
		sys_reset : in std_logic;
		rx_clk    : in std_logic;
				
		packet_start_SYSCLK  : out std_logic;
		packet_start_RXCLK   : in  std_logic;
		packet_end_SYSCLK    : out std_logic;
		packet_end_RXCLK     : in  std_logic;
		word_dv_bytes_SYSCLK : out std_logic_vector(0 to 2);
		word_dv_bytes_RXCLK  : in  std_logic_vector(0 to 2);
		word_data_SYSCLK     : out std_logic_vector(0 to 31);
		word_data_RXCLK      : in  std_logic_vector(0 to 31)

	);
	end component ethrx_clkdomain;


	signal rx_clock_FDR  : std_logic;
	signal rx_data_FDR   : std_logic_vector(rx_data_pins-1 downto 0);
	signal rx_dvalid_FDR : std_logic;
begin

	domaincross : ethrx_clkdomain
	port map (
		sys_clk   => sys_clk,
		sys_reset => sys_reset,
		rx_clk    => rx_clock,
				
		packet_start_SYSCLK  => core_pkt_start,
		packet_start_RXCLK   => word_pkt_start,
		packet_end_SYSCLK    => core_pkt_end,
		packet_end_RXCLK     => word_pkt_end,
		word_dv_bytes_SYSCLK => core_dv_bytes,
		word_dv_bytes_RXCLK  => word_dv_bytes,
		word_data_SYSCLK     => core_data,
		word_data_RXCLK      => word_data

	);

	clockbuffering1 : process (rx_clock) begin
		if rising_edge(rx_clock) then
			rx_dvalid_FDR <= rx_dvalid;
			rx_data_FDR   <= rx_data;
		end if;
	end process;

	statemachine : ethrx_statemachine
	generic map (
		rx_data_pins	=> rx_data_pins
	)
	port map (
		rx_clk		=> rx_clock,
		sys_reset	=> sys_reset,
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
		rx_clk		=> rx_clock,
		sys_reset	=> sys_reset,
		sample_rx	=> sample_rx,
		rx_data		=> rx_data_FDR,
		rx_dvalid	=> rx_dvalid_FDR,
		byte_pkt_start	=> byte_pkt_start,
		byte_pkt_end	=> byte_pkt_end,
		byte_data	=> byte_data,
		byte_dvalid	=> byte_dvalid
	);

	wordmaker : ethrx_byte_to_word 
	port map (
		rx_clk		=> rx_clock,
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
		
		core_pkt_start	=> core_pkt_start,
		core_pkt_end	=> core_pkt_end, 
		core_data	=> core_data,
		core_dv_bytes	=> core_dv_bytes

	);

	
end architecture RTL;
