library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_core is
        generic (
                	data_pins : natural := 4;
			async     : boolean := true
		);
        port (
                sys_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

		reg_status	: out std_logic_vector(0 to 31);
		reg_status_rd	: in  std_logic;

		reg_wr_data	: in  std_logic_vector(0 to 31);
		reg_fifo_wr	: in  std_logic;
		reg_ctrl_wr	: in  std_logic;

		tx_clk		: in  std_logic;
		tx_en		: out std_logic;
		tx_d		: out std_logic_vector(data_pins-1 downto 0)
	);
end ethtx_core;

architecture RTL of ethtx_core is

        component ethtx_clk_sampler is
        port (
                sys_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

                tx_clock        : in std_logic;
                tx_clock_pulse  : out std_logic
        );
        end component ethtx_clk_sampler;

        signal tx_clock_pulse : std_logic;

        component ethtx_statemachine is
        port (
                sys_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

		packet_buffered : in  std_logic;	       
		packet_sent  	: in  std_logic;
		tx_clock_pulse  : in  std_logic;

		send_state	: out std_logic_vector(1 downto 0) -- 00 wait 01 preamble; 10 synch 11 send		

        );
        end component ethtx_statemachine;

	signal send_state : std_logic_vector(1 downto 0);

        component ethtx_byte_to_mii is
        generic (
                data_pins       : natural := 4
        );
        port (
                sys_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

		send_state	: in std_logic_vector(1 downto 0);

                tx_clock_pulse  : in  std_logic;
                tx_data         : out std_logic_vector(data_pins-1 downto 0);
                tx_en           : out std_logic;                

		append_fcs	: in std_logic;
		fcs		: in std_logic_vector(31 downto 0);

		packet_sent	: out std_logic;

		byte_rd		: out std_logic;
                byte_data       : in std_logic_vector(7 downto 0);
                byte_valid      : in std_logic
        );
        end component ethtx_byte_to_mii;
	
	signal byte_rd : std_logic;
	signal packet_sent	: std_logic;

	component ethtx_regfile is
	port (

		sys_clk		: in std_logic;
		sys_reset	: in std_logic;
		
		reg_status	: out std_logic_vector(0 to 31);
		reg_status_rd	: in  std_logic;

		reg_wr_data	: in  std_logic_vector(0 to 31);
		reg_fifo_wr	: in  std_logic;
		reg_ctrl_wr	: in  std_logic;

		word_rd		: in  std_logic;
                word_data       : out std_logic_vector(31 downto 0);
                word_count      : out std_logic_vector(2 downto 0);

		packet_sent	: in  std_logic;
		append_fcs	: out std_logic;
		packet_buffered : out std_logic
	);
	end component ethtx_regfile;
	
	signal word_data       : std_logic_vector(31 downto 0);
        signal word_count      : std_logic_vector(2 downto 0);
	signal append_fcs      : std_logic;
	signal packet_buffered : std_logic;

	component ethtx_word_to_byte is
	port (
		sys_clk		: in std_logic;
		sys_reset	: in std_logic;
			
		word_rd		: out  std_logic;
                word_data       : in   std_logic_vector(31 downto 0);
                word_count      : in   std_logic_vector(2 downto 0);

		byte_rd		: in  std_logic;
                byte_data       : out std_logic_vector(7 downto 0);
                byte_valid      : out std_logic
	);
	end component ethtx_word_to_byte;

	signal word_rd : std_logic;
	signal byte_data : std_logic_vector(7 downto 0);
	signal byte_valid : std_logic;

	component crc32 is
	generic (
		order  : boolean := false;
		dwidth : integer := 8
	);
	port (
		CLK, RST  : in  std_logic;
		softreset : in  std_logic;
		dvalid    : in  std_logic;
		data      : in  std_logic_vector(dwidth-1 downto 0);
		crc       : out std_logic_vector(31 downto 0)
	);
	end component crc32;

	signal fcs : std_logic_vector(31 downto 0);

	component fifo_async
    	generic (data_bits : integer;
             	addr_bits  : integer;
             	block_type : integer := 0;
             	fifo_arch  : integer := 0); -- 0=Generic architecture, 
                	                    -- 1=Xilinx XAPP131, 
                                            -- 2=Xilinx XAPP131 w/carry mux
    	port (reset	: in  std_logic;
          	wr_clk	: in  std_logic;
          	wr_en	: in  std_logic;
          	wr_data	: in  std_logic_vector (data_bits-1 downto 0);
          	rd_clk	: in  std_logic;
          	rd_en	: in  std_logic;
          	rd_data	: out std_logic_vector (data_bits-1 downto 0);
          	full	: out std_logic;
          	empty	: out std_logic
         	);
  	end component;

	signal	tx_async_fifo_full, 
		tx_async_fifo_wren,
		tx_async_fifo_empty,
		tx_async_fifo_empty_inv : std_logic;
		
	signal	tx_async_fifo_din, 
		tx_async_fifo_dout : std_logic_vector(data_pins downto 0);
	

	signal tx_clk_fdr : std_logic;	

	signal tx_en_s	: std_logic;
	signal tx_d_s	: std_logic_vector(data_pins-1 downto 0);


begin

	gen0 : if async = false generate

		tx_en <= tx_en_s;
		tx_d <= tx_d_s;

		fdr : process (sys_clk) begin
			if rising_edge(sys_clk) then
				if sys_reset='1' then
					tx_clk_fdr <= '0';
				else
					tx_clk_fdr <= tx_clk;		
				end if;
			end if;
		end process;


	        sampler : ethtx_clk_sampler
	        port map (
	                sys_clk         => sys_clk,
	                sys_reset       => sys_reset,

        	        tx_clock        => tx_clk_fdr,
                	tx_clock_pulse  => tx_clock_pulse
	        );
	end generate gen0;
	
	gen1 : if async = true generate
		tx_async_fifo :  fifo_async
    		generic map (
			data_bits  => data_pins+1,
             		addr_bits  => 4,
             		block_type => 0,
             		fifo_arch  => 0) -- 0=Generic architecture, 
                	                   -- 1=Xilinx XAPP131, 
                        	           -- 2=Xilinx XAPP131 w/carry mux
    		port map (
			reset	=> sys_reset,
        	  	wr_clk	=> sys_clk,
          		wr_en	=> tx_async_fifo_wren,
	          	wr_data	=> tx_async_fifo_din,
        	  	rd_clk	=> tx_clk,
          		rd_en	=> tx_async_fifo_empty_inv,
          		rd_data	=> tx_async_fifo_dout,
          		full	=> tx_async_fifo_full,
          		empty	=> tx_async_fifo_empty
         	);

		tx_clock_pulse <= not tx_async_fifo_full;

		process (sys_clk) begin
			if rising_edge(sys_clk) then
				if sys_reset='1' then
					tx_async_fifo_wren <= '0';
				else
					tx_async_fifo_wren <= tx_clock_pulse;
				end if;
			end if;
		end process;

		tx_async_fifo_empty_inv <= not tx_async_fifo_empty;

		tx_async_fifo_din <= tx_en_s & tx_d_s;

		process (tx_clk) begin
			if rising_edge(tx_clk) then
				tx_en <= tx_async_fifo_dout(data_pins);
				tx_d <= tx_async_fifo_dout(data_pins-1 downto 0);

				if tx_async_fifo_empty = '1' then
					tx_en <= '0';
				end if;
			end if;
		end process;
					

	end generate gen1;


	state : ethtx_statemachine
        port map (
                sys_clk         => sys_clk,
                sys_reset       => sys_reset,

		packet_buffered => packet_buffered,
		packet_sent  	=> packet_sent,
		tx_clock_pulse  => tx_clock_pulse,

		send_state	=> send_state

        );

	cyclic :  crc32
	generic map (
		order  => true,
		dwidth => 8
	)
	port map (
		CLK       => sys_clk,
		RST       => sys_reset,
		softreset => packet_sent,
		dvalid    => byte_rd,
		data      => byte_data,
		crc       => fcs
	);


	byteifier : ethtx_word_to_byte
	port map (
		sys_clk		=> sys_clk,
		sys_reset	=> sys_reset,

			
		word_rd		=> word_rd,
                word_data       => word_data,
                word_count      => word_count,

		byte_rd		=> byte_rd,
                byte_data       => byte_data,
                byte_valid      => byte_valid
	);


	sender : ethtx_byte_to_mii
        generic map (
                data_pins       => data_pins
        )
        port map (
                sys_clk         => sys_clk,
                sys_reset       => sys_reset,

		send_state	=> send_state,

                tx_clock_pulse  => tx_clock_pulse,
                tx_data         => tx_d_s,
                tx_en           => tx_en_s,

		append_fcs	=> append_fcs,
		fcs		=> fcs,

		packet_sent	=> packet_sent,

		byte_rd		=> byte_rd,
                byte_data       => byte_data,
                byte_valid      => byte_valid
        );
 
 	regfile : ethtx_regfile
	port map (
		sys_clk => sys_clk,
		sys_reset => sys_reset,

		reg_status	=> reg_status,
		reg_status_rd	=> reg_status_rd,

		reg_wr_data	=> reg_wr_data,
		reg_fifo_wr	=> reg_fifo_wr,
		reg_ctrl_wr	=> reg_ctrl_wr,

		word_rd		=> word_rd,
                word_data       => word_data,
                word_count      => word_count,

		packet_sent	=> packet_sent,
		append_fcs	=> append_fcs,
		packet_buffered => packet_buffered
	);




end architecture RTL;

