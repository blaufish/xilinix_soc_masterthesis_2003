library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_clkdomain is
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
end ethrx_clkdomain;

architecture RTL of ethrx_clkdomain is

	-- RX_CLK -> SYS_CLK domain tranfere, open loop solution
	signal rx2sys_transmit_d, rx2sys_receive_d1 : std_logic_vector(37 downto 0);
	signal rx2sys_receive_d2 : std_logic_vector(0 downto 0);


begin


	process (sys_clk, rx_clk) begin
		-- RX_CLK is slower than SYS_CLK. Allows open loop solution!
		if rising_edge(rx_clk) then
			
			if sys_reset='1' then
				rx2sys_transmit_d <= (others => '0');
			else
				rx2sys_transmit_d(0)           <= not rx2sys_transmit_d(0);
				rx2sys_transmit_d(1)           <= packet_start_RXCLK;
				rx2sys_transmit_d(2)           <= packet_end_RXCLK;
				rx2sys_transmit_d(5 downto 3)  <= word_dv_bytes_RXCLK;
				rx2sys_transmit_d(37 downto 6) <= word_data_RXCLK;
			end if;
		end if;

		if rising_edge(sys_clk) then
			packet_start_SYSCLK  <= '0';
			packet_end_SYSCLK    <= '0';
			word_dv_bytes_SYSCLK <= (others => '0');
			word_data_SYSCLK     <= (others => '-');
			
			if sys_reset='1' then
				rx2sys_receive_d1  <= (others => '0'); 
				rx2sys_receive_d2  <= (others => '0');
			else
				rx2sys_receive_d1 <= rx2sys_transmit_d;
				rx2sys_receive_d2 <= rx2sys_receive_d1(0 downto 0);

				if rx2sys_receive_d1(0) = rx2sys_receive_d2(0) then
					-- default ange packet_start, packet_end, word_dv_bytes=0
					null;
				else
					packet_start_SYSCLK  <= rx2sys_receive_d1(1);
					packet_end_SYSCLK    <= rx2sys_receive_d1(2);
					word_dv_bytes_SYSCLK <= rx2sys_receive_d1(5 downto 3);
					word_data_SYSCLK     <= rx2sys_receive_d1(37 downto 6);
				end if;
			end if;
		end if;
	end process;
					
		

end architecture RTL;
