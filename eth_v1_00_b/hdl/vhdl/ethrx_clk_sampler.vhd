library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_clk_sampler is
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_clock	: in std_logic;
		rx_clock_pulse  : out std_logic
	);
end ethrx_clk_sampler;

architecture RTL of ethrx_clk_sampler is
	constant rx_clock_trigwave	: std_logic_vector(2 downto 0) := "001";
	signal   rx_clock_wave		: std_logic_vector(1 downto 0);
	signal   rx_clock_nextwave      : std_logic_vector(2 downto 0);
		
begin
	rx_clock_nextwave <= rx_clock_wave & rx_clock;

	rx_clock_pulse <= '1' when rx_clock_nextwave = rx_clock_trigwave else '0';

	wavesampler : process (sys_clk) begin
		if rising_edge(sys_clk) then
			--rx_clock_pulse <= '0';
			
			if sys_reset='1' then
				rx_clock_wave <= not rx_clock_trigwave(1 downto 0);	
			else
				rx_clock_wave <= rx_clock_nextwave(1 downto 0);
				
				--if rx_clock_nextwave = rx_clock_trigwave then
				--	rx_clock_pulse <= '1';
				--end if;
			end if;
		end if;
	end process;

end architecture RTL;
