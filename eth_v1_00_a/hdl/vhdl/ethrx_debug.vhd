library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_debug is
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
end ethrx_debug;

architecture RTL of ethrx_debug is
	signal reg0 : unsigned ( 0 to 31 );

	signal reg1 : std_logic_vector ( 0 to 31 );

begin
	debugfile0 <= std_logic_vector( reg0 );
	debugfile1 <= reg1;

	reg0_fdre_p : process ( sys_clk ) begin
		if rising_edge( sys_clk ) then
			if sys_reset = '1' then
				reg0 <= ( others => '0' );

			elsif rx_clock_pulse = '1' then
				reg0 <= reg0 + 1;
			
			end if;
		end if;
	end process;


	reg1_fdre : process ( sys_clk ) begin
		if rising_edge( sys_clk ) then
			if sys_reset = '1' then
				reg1 <= ( others => '0' );

			elsif rx_clock_pulse = '1' then
				reg1(0) <= rx_dvalid;
				if reg1(0) = '0' and rx_dvalid = '1' then
					reg1(32-data_pins to 31) <= rx_data;
				end if;
			
			end if;
		end if;
	end process;

end architecture RTL;

