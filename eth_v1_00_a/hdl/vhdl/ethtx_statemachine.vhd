library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_statemachine is
	generic (
		data_pins	: natural := 4
	);
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1
		
		packet_buffered : in std_logic;	       
		packet_sent  	: in std_logic;
		tx_clock_pulse  : in std_logic;

		send_state	: out std_logic_vector(1 downto 0) -- 00 wait 01 preamble; 10 synch 11 send
		
	);
end ethtx_statemachine;


architecture RTL of ethtx_statemachine is

	constant ipg_bits	: natural := 96; 
	constant ipg_cycles	: natural := ipg_bits / data_pins;
	constant pream_bits	: natural := 64 - data_pins; 
	constant pream_cycles	: natural := pream_bits / data_pins;

	constant state_wait     : std_logic_vector(1 downto 0) := "00";
	constant state_preamble : std_logic_vector(1 downto 0) := "01";
	constant state_sync     : std_logic_vector(1 downto 0) := "10";
	constant state_send	: std_logic_vector(1 downto 0) := "11";


	type T_STATES is (S_IPG, S_WAIT, S_PRE, S_SYNC, S_SEND);
	signal state   : T_STATES;
	signal counter : natural range 0 to 127;
begin

	process (state)
	begin
		case state is
		when S_IPG  => send_state <= state_wait;
		when S_WAIT => send_state <= state_wait;
		when S_PRE  => send_state <= state_preamble;
		when S_SYNC => send_state <= state_sync;
		when S_SEND => send_state <= state_send;
		end case;
	end process;



	state_p : process (sys_clk) begin
		if rising_edge(sys_clk) then
			if sys_reset='1' then
				state   <= S_IPG;
				counter <= 0;
		
			elsif packet_sent = '1' then
				state <= S_IPG;
				counter <= 0;

			elsif tx_clock_pulse = '1' then
				case state is
				when S_IPG =>
					counter <= counter + 1;

					if counter = ipg_cycles then
						state <= S_WAIT;
					end if;

				when S_WAIT =>
					counter <= 0;
					
					if packet_buffered='1' then
						state <= S_PRE;
					end if;
					
				when S_PRE =>
					counter <= counter + 1;
					
					if counter = pream_cycles then
						state <= S_SYNC;
					end if;

				when S_SYNC =>
					counter <= 0;
					state   <= S_SEND;
					
				when others => null;
				end case;
			end if; -- clock_pulse
		end if; -- sys_reset
	end process;

end architecture RTL;



