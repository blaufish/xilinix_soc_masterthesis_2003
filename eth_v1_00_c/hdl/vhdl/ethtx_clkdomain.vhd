library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_clkdomain is
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
end ethtx_clkdomain;

architecture RTL of ethtx_clkdomain is

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


	-- TX_CLK -> SYS_CLK domain tranfere, open loop solution
	signal tx2sys_transmit_d, tx2sys_receive_d1 : std_logic_vector(2 downto 0);
	signal tx2sys_receive_d2 : std_logic_vector(0 downto 0);



	signal sys2tx_reset_transmit, sys2tx_flag : std_logic;
	signal sys2tx_data : std_logic_vector(37 downto 0);

begin


	
	process (sys_clk, tx_clk) begin
		if rising_edge(sys_clk) then
			if sys_reset = '1' then
				sys2tx_flag <= '0';
				sys2tx_data <= (others => '0');
			else
		
				if sys2tx_flag = '0' then
					sys2tx_data(0)            <= append_fcs_SYSCLK;
					sys2tx_data(1)            <= packet_buffered_SYSCLK;
					sys2tx_data(33 downto 2)  <= word_data_SYSCLK;
					sys2tx_data(36 downto 34) <= word_count_SYSCLK;
					sys2tx_data(37)           <= word_almost_empty_SYSCLK;
				end if;
	
				sys2tx_flag <= '1';

				if sys2tx_reset_transmit = '1' then
					sys2tx_flag <= '0';
				end if;

				if sys_reset = '1' then
					sys2tx_flag <= '0';
				end if;
			end if;
		end if;
		

		
		if rising_edge(tx_clk) then
			
			if sys_reset = '1' then
				sys2tx_reset_transmit   <= '0';
				append_fcs_TXCLK        <= '0';
				packet_buffered_TXCLK   <= '0';
				word_data_TXCLK         <= (others => '0');
				word_count_TXCLK        <= (others => '0');
				word_almost_empty_TXCLK <= '0';
			else
			
				if sys2tx_flag = '1' then
					sys2tx_reset_transmit   <= '1';
					append_fcs_TXCLK        <= sys2tx_data(0);
					packet_buffered_TXCLK   <= sys2tx_data(1);
					word_data_TXCLK         <= sys2tx_data(33 downto 2);
					word_count_TXCLK        <= sys2tx_data(36 downto 34);
					word_almost_empty_TXCLK <= sys2tx_data(37);
				else
					sys2tx_reset_transmit <= '0';
				end if;
			end if;				
		end if;
	end process;
			
				





	process (sys_clk, tx_clk) begin
		-- TX_CLK is slower than SYS_CLK. Allows open loop solution!
		if rising_edge(tx_clk) then
			if sys_reset='1' then
				tx2sys_transmit_d <= (others => '0');
			else
				tx2sys_transmit_d(0) <= not tx2sys_transmit_d(0);
				tx2sys_transmit_d(1) <= packet_sent_TXCLK;
				tx2sys_transmit_d(2) <= word_rd_TXCLK;
			end if;
		end if;

		if rising_edge(sys_clk) then
			if sys_reset='1' then
				tx2sys_receive_d1  <= (others => '0'); 
				tx2sys_receive_d2  <= (others => '0');
				packet_sent_SYSCLK <= '0';
				word_rd_SYSCLK     <= '0';

			else
				tx2sys_receive_d1 <= tx2sys_transmit_d;
				tx2sys_receive_d2 <= tx2sys_receive_d1(0 downto 0);

				if tx2sys_receive_d1(0) = tx2sys_receive_d2(0) then
					packet_sent_SYSCLK <= '0';
					word_rd_SYSCLK     <= '0';
				else
					packet_sent_SYSCLK <= tx2sys_receive_d1(1);
					word_rd_SYSCLK     <= tx2sys_receive_d1(2);
				end if;
			end if;
		end if;
	end process;
					
		

end architecture RTL;
