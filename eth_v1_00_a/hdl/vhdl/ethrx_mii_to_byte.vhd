library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_mii_to_byte is
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
end ethrx_mii_to_byte;

architecture RTL of ethrx_mii_to_byte is
	constant words : natural := 8/data_pins;
	--type word is std_logic_vector(data_pins-1 downto 0);
	
	signal data_BE		: std_logic_vector(data_pins-1 downto 0);
	signal data_sampled	: std_logic_vector(7 downto 0);
	signal data_count	: natural range 0 to words;

	signal pkt_start_sent	: std_logic;

	function flipbitorder( word : std_logic_vector; flip : boolean ) return std_logic_vector is
		variable drow : std_logic_vector( word'right to word'left );
		variable i    : natural range word'range;
	begin
		if flip=false then
			return word;
		end if;

		for i in word'range loop
			drow(i) := word(i);
		end loop;
		return drow;
	end function;

begin
	data_BE <= flipbitorder(rx_data, not rx_order_BigE);

	byte_data <= std_logic_vector(data_sampled);


	data_sampler : process (sys_clk) begin
		if rising_edge(sys_clk) then
			byte_dvalid	<= '0';
			byte_pkt_start	<= '0';
			byte_pkt_end	<= '0';
			
			if sys_reset='1' then
				data_sampled   <= (others => '0');
				data_count     <= 0;
				pkt_start_sent <= '0';


			else
				if data_count = words then
					data_count <= 0;
					byte_dvalid <= '1';
				end if;

				if rx_clock_pulse='1' then
					if sample_rx='0' or rx_dvalid='0' then
						data_sampled   <= (others => '0');
						data_count     <= 0;
						pkt_start_sent <= '0';

						if pkt_start_sent='1' then
							byte_pkt_end   <= '1';
						end if;

						if data_count /= 0 then
							null; -- align error <= '1';
						end if;
				
					elsif sample_rx='1' and rx_dvalid='1' then
						data_sampled <= data_BE & data_sampled(data_sampled'left downto data_pins);
						data_count <= data_count + 1;

						if pkt_start_sent = '0' then
							pkt_start_sent <= '1';
							byte_pkt_start <= '1';
						end if;
					else
						assert false report "weird sample_rx/rx_dvalid state" severity error;
					end if;

				end if;
			end if;
		end if;
	end process;
				

	
end architecture RTL;
