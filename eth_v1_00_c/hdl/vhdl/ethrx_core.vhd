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

	component fifo_async
    	generic (data_bits	:integer;
             	addr_bits  :integer;
             	block_type	:integer := 0;
             	fifo_arch  :integer := 0); -- 0=Generic architecture, 
                	                   -- 1=Xilinx XAPP131, 
                        	           -- 2=Xilinx XAPP131 w/carry mux
    	port (
		reset	:in  std_logic;
          	wr_clk	:in  std_logic;
          	wr_en	:in  std_logic;
          	wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          	rd_clk	:in  std_logic;
          	rd_en	:in  std_logic;
          	rd_data	:out std_logic_vector (data_bits-1 downto 0);
          	full	:out std_logic;
          	empty	:out std_logic
         	);
  	end component;

	signal fifo_wren  : std_logic;
	signal fifo_wrd   : std_logic_vector(36 downto 0);
	signal fifo_rden  : std_logic;
	signal fifo_rdd   : std_logic_vector(36 downto 0);
	signal fifo_empty : std_logic;
	signal to_reg_en  : std_logic;
	signal to_reg     : std_logic_vector(36 downto 0);

	signal rx_clock_FDR  : std_logic;
	signal rx_data_FDR   : std_logic_vector(rx_data_pins-1 downto 0);
	signal rx_dvalid_FDR : std_logic;
begin
	domaincross : fifo_async
    	generic map (
		data_bits  => 37,
             	addr_bits  => 2,
             	block_type => 2,
             	fifo_arch  => 0 ) -- 0=Generic architecture, 
                	                   -- 1=Xilinx XAPP131, 
                        	           -- 2=Xilinx XAPP131 w/carry mux
    	port map (
		reset	=> sys_reset,
          	wr_clk	=> rx_clock,
          	wr_en	=> fifo_wren,
          	wr_data	=> fifo_wrd,
          	rd_clk	=> sys_clk,
          	rd_en	=> fifo_rden,
          	rd_data	=> fifo_rdd,
          	full	=> open,
          	empty	=> fifo_empty
         	);

	fifo_wren <= '1' when (word_pkt_start & word_pkt_end & word_dv_bytes) /= "00000" else '0';
	fifo_wrd  <= word_pkt_start & word_pkt_end & word_data & word_dv_bytes;
	fifo_rden <= not fifo_empty;
	
	to_reg_en <= fifo_rden;
	--process (sys_clk) begin
	--	if rising_edge(sys_clk) then
	--		if sys_reset = '1' then
	--			to_reg_en <= '0';
	--		else
	--			to_reg_en <= fifo_rden;
	--		end if;
	--	end if;
	--end process;
	
	to_reg <= fifo_rdd when to_reg_en = '1' else (others=>'0');

	core_pkt_start <= to_reg(36);
	core_pkt_end   <= to_reg(35);
	core_data      <= to_reg(34 downto 3);
	core_dv_bytes  <= to_reg(2 downto 0);


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
