library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_statemachine is
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
end ethrx_statemachine;


architecture RTL of ethrx_statemachine is
	constant rx_preamble_seq_8b : std_logic_vector(7 downto 0) := "01010101";
	constant rx_preamble_sfd_8b : std_logic_vector(7 downto 0) := "11010101";

	constant rx_preamble_seq : std_logic_vector(rx_data_pins-1 downto 0) := rx_preamble_seq_8b(7 downto 8-rx_data_pins);
	constant rx_preamble_sfd : std_logic_vector(rx_data_pins-1 downto 0) := rx_preamble_sfd_8b(7 downto 8-rx_data_pins);

	type T_RX_STATES is (S_WAIT, S_PRE, S_SAMP);
	signal rx_state   : T_RX_STATES;
begin
	sample_rx <= '1' when rx_state=S_SAMP else '0';

	rx_state_p : process (rx_clk) begin
		if rising_edge(rx_clk) then
			if sys_reset='1' then
				rx_state   <= S_WAIT;
				
			else
				case rx_state is
				when S_WAIT =>
					if rx_dvalid='1' then
						if rx_data = rx_preamble_seq then
							rx_state <= S_PRE;
						end if;
					end if;
					
				when S_PRE =>
					if rx_dvalid='1' and rx_data=rx_preamble_seq then
						null;
						
					elsif rx_dvalid='1' and rx_data=rx_preamble_sfd then
						
						rx_state <= S_SAMP;
						
					else
						rx_state <= S_WAIT;
					end if;
					
				when S_SAMP =>
					if rx_dvalid='0' then
						rx_state <= S_WAIT;
					end if;
				
				when others => null;
				end case;
			end if; -- sys_reset
		end if; -- rx_clk
	end process;

end architecture RTL;



