library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_clk_sampler is
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		tx_clock	: in std_logic;
		tx_clock_pulse  : out std_logic
	);
end ethtx_clk_sampler;

architecture RTL of ethtx_clk_sampler is
	constant tx_clock_trigwave	: std_logic_vector(2 downto 0) := "001";
	signal   tx_clock_wave		: std_logic_vector(1 downto 0);
	signal   tx_clock_nextwave      : std_logic_vector(2 downto 0);
		
begin
	tx_clock_nextwave <= tx_clock_wave & tx_clock;
	tx_clock_pulse <= '1' when tx_clock_nextwave = tx_clock_trigwave else '0';

	wavesampler : process (sys_clk) begin
		if rising_edge(sys_clk) then
			if sys_reset='1' then
				tx_clock_wave <= not tx_clock_trigwave(1 downto 0);	
			else
				tx_clock_wave <= tx_clock_nextwave(1 downto 0);
			end if;
		end if;
	end process;

end architecture RTL;
