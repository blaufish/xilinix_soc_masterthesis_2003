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

        component ethtx_statemachine is
	generic (
		data_pins	: natural := 4
	);
        port (
                tx_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

		packet_buffered : in  std_logic;	       
		packet_sent  	: in  std_logic;

		send_state	: out std_logic_vector(1 downto 0) -- 00 wait 01 preamble; 10 synch 11 send		

        );
        end component ethtx_statemachine;

	signal send_state : std_logic_vector(1 downto 0);

        component ethtx_byte_to_mii is
        generic (
                data_pins       : natural := 4
        );
        port (
                tx_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

		send_state	: in std_logic_vector(1 downto 0);

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

		word_rd            : in  std_logic;
                word_data          : out std_logic_vector(31 downto 0);
                word_count         : out std_logic_vector(2 downto 0);
		word_almost_empty  : out std_logic;

		packet_sent	: in  std_logic;
		append_fcs	: out std_logic;
		packet_buffered : out std_logic
	);
	end component ethtx_regfile;
	
	signal word_data         : std_logic_vector(31 downto 0);
        signal word_count        : std_logic_vector(2 downto 0);
	signal word_almost_empty : std_logic;
	signal append_fcs        : std_logic;
	signal packet_buffered   : std_logic;

	component ethtx_word_to_byte is
	port (
		tx_clk		: in std_logic;
		sys_reset	: in std_logic;
			
		word_rd	          : out  std_logic;
                word_data         : in   std_logic_vector(31 downto 0);
                word_count        : in   std_logic_vector(2 downto 0);
		word_almost_empty : in   std_logic;

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



	signal tx_clk_fdr : std_logic;	

	signal tx_en_s	: std_logic;
	signal tx_d_s	: std_logic_vector(data_pins-1 downto 0);

	component ethtx_clkdomain is
	port (
		sys_clk   : in std_logic;
		sys_reset : in std_logic;
		tx_clk    : in std_logic;
				
		packet_sent_SYSCLK : out std_logic;
		packet_sent_TXCLK  : in  std_logic;
		word_rd_SYSCLK     : out std_logic;
		word_rd_TXCLK      : in  std_logic;

		append_fcs_SYSCLK        : in  std_logic;
		append_fcs_TXCLK         : out std_logic;
		packet_buffered_SYSCLK   : in  std_logic;
		packet_buffered_TXCLK    : out std_logic;
		word_data_SYSCLK         : in  std_logic_vector(31 downto 0);
		word_data_TXCLK          : out std_logic_vector(31 downto 0);
		word_count_SYSCLK        : in  std_logic_vector(2 downto 0);
		word_count_TXCLK         : out std_logic_vector(2 downto 0);
		word_almost_empty_SYSCLK : in  std_logic;
		word_almost_empty_TXCLK  : out std_logic
	);
	end component ethtx_clkdomain;
	
	-----------------------------------------------------
	--- Signals for crossing TXCLK to SYSCLK boundary ---
	-----------------------------------------------------

	signal word_rd_SYSCLK, packet_sent_SYSCLK : std_logic;



	-----------------------------------------------------
	--- Signals for crossing SYSCLK to TXCLK boundary ---
	-----------------------------------------------------
	

	signal append_fcs_TXCLK, packet_buffered_TXCLK : std_logic;
	signal word_data_TXCLK : std_logic_vector(31 downto 0);
	signal word_count_TXCLK : std_logic_vector(2 downto 0);
	signal word_almost_empty_TXCLK : std_logic;


	
begin


	domaincross : ethtx_clkdomain
	port map (
		sys_clk   => sys_clk,
		sys_reset => sys_reset,
		tx_clk    => tx_clk,
				
		packet_sent_SYSCLK => packet_sent_SYSCLK,
		packet_sent_TXCLK  => packet_sent,
		word_rd_SYSCLK     => word_rd_SYSCLK,
		word_rd_TXCLK      => word_rd,

		append_fcs_SYSCLK        => append_fcs,
		append_fcs_TXCLK         => append_fcs_TXCLK,
		packet_buffered_SYSCLK   => packet_buffered,
		packet_buffered_TXCLK    => packet_buffered_TXCLK,
		word_data_SYSCLK         => word_data,
		word_data_TXCLK          => word_data_TXCLK,
		word_count_SYSCLK        => word_count,
		word_count_TXCLK         => word_count_TXCLK,
		word_almost_empty_SYSCLK => word_almost_empty,
		word_almost_empty_TXCLK  => word_almost_empty_TXCLK
	);

	
				

	state : ethtx_statemachine
 	generic map (
		data_pins => data_pins
	)
	port map (
        	tx_clk         	=> tx_clk,
		sys_reset       => sys_reset,

		packet_buffered => packet_buffered_TXCLK,
		packet_sent  	=> packet_sent,

		send_state	=> send_state

        );

	cyclic :  crc32
	generic map (
		order  => true,
		dwidth => 8
	)
	port map (
		CLK       => tx_clk,
		RST       => sys_reset,
		softreset => packet_sent,
		dvalid    => byte_rd,
		data      => byte_data,
		crc       => fcs
	);


	byteifier : ethtx_word_to_byte
	port map (
		tx_clk		=> tx_clk,
		sys_reset	=> sys_reset,

			
		word_rd	          => word_rd,
                word_data         => word_data_TXCLK,
                word_count        => word_count_TXCLK,
		word_almost_empty => word_almost_empty_TXCLK,

		byte_rd		=> byte_rd,
                byte_data       => byte_data,
                byte_valid      => byte_valid
	);


	sender : ethtx_byte_to_mii
        generic map (
                data_pins       => data_pins
        )
        port map (
                tx_clk         => tx_clk,
                sys_reset       => sys_reset,

		send_state	=> send_state,

                tx_data         => tx_d,
                tx_en           => tx_en,

		append_fcs	=> append_fcs_TXCLK,
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

		word_rd	          => word_rd_SYSCLK,
                word_data         => word_data,
                word_count        => word_count,
		word_almost_empty => word_almost_empty,

		packet_sent	=> packet_sent_SYSCLK,
		append_fcs	=> append_fcs,
		packet_buffered => packet_buffered
	);




end architecture RTL;

