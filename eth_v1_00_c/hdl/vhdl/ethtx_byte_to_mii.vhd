library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_byte_to_mii is
        generic (
                data_pins       : natural := 4
        );
        port (
                tx_clk          : in std_logic; -- rising edge
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
end ethtx_byte_to_mii;



architecture RTL of ethtx_byte_to_mii is
	constant preamble_seq_8b : std_logic_vector(7 downto 0) := "01010101";
	constant preamble_sfd_8b : std_logic_vector(7 downto 0) := "11010101";

	constant preamble_seq : std_logic_vector(data_pins-1 downto 0) := preamble_seq_8b(7 downto 8-data_pins);
	constant preamble_sfd : std_logic_vector(data_pins-1 downto 0) := preamble_sfd_8b(7 downto 8-data_pins);

	constant state_wait     : std_logic_vector(1 downto 0) := "00";
	constant state_preamble : std_logic_vector(1 downto 0) := "01";
	constant state_sync     : std_logic_vector(1 downto 0) := "10";
	constant state_send     : std_logic_vector(1 downto 0) := "11";


	signal count : unsigned(2 downto 0);
	signal data  : std_logic_vector(7 downto 0);

	signal send_fcs_ok : std_logic;
	signal fcs_count : unsigned (2 downto 0);


	constant nibbles : natural := 8/data_pins;

	signal fcs_byte_BadOrder, fcs_byte : std_logic_vector(7 downto 0);

	signal packet_sent_REG : std_logic;

begin

	packet_sent <= packet_sent_REG;

	process (fcs, fcs_count) begin
		case fcs_count(1 downto 0) is
		when "00"  => fcs_byte_BadOrder <= fcs(31 downto 24);
		when "01"  => fcs_byte_BadOrder <= fcs(23 downto 16);
		when "10"  => fcs_byte_BadOrder <= fcs(15 downto  8);
		when "11"  => fcs_byte_BadOrder <= fcs( 7 downto  0);
		when others => fcs_byte_BadOrder <= (others => '0');
		end case;
	end process;

	
	-- Flip nibble order & flip bitorder in nibbles
	--
	-- Will put MSB into the first bit sent (first txd[0]) 
	--   and LSB into the last (last txd[max])
	--
	foo : for i in 0 to 7 generate
		fcs_byte(i) <= fcs_byte_BadOrder(7-i);
	end generate;

	process (tx_clk) 
	begin
		if rising_edge(tx_clk) then
			packet_sent_REG <= '0';
			byte_rd         <= '0';
			
		
			if sys_reset='1' then
				tx_en       <= '0';
				tx_data     <= (others => '0');
				count       <= (others => '0');
				fcs_count   <= (others => '0');
				send_fcs_ok <= '0';
			else

				if send_state=state_wait then
					tx_en <= '0';
					count <= (others => '0');
					fcs_count <= (others => '0');
					send_fcs_ok <= '0';

				elsif send_state=state_preamble then
					tx_en   <= '1';
					tx_data <= preamble_seq;
					--count <= (others => '0');

				elsif send_state=state_sync then
					tx_en   <= '1';
					tx_data <= preamble_sfd;
					--count <= (others => '0');

				elsif send_state=state_send then
					tx_en   <= '1';
					tx_data <= data(data_pins-1 downto 0);
					count   <= count-1;
					data	<= std_logic_vector( shift_right( unsigned(data), data_pins ) );
				end if;


				if byte_valid='1' then
					byte_rd <= '1';
						
					if send_state = state_send and count="001" then
						send_fcs_ok <= '1';
						data        <= byte_data;
						count       <= to_unsigned( 8/data_pins, 3 );

					elsif (send_state = state_preamble or send_state = state_sync) and count="000" then
						data  <= byte_data;
						count <= to_unsigned( 8/data_pins, 3 );		
						
					else
						byte_rd <= '0';
					end if;
				end if;

				if send_state=state_send and append_fcs='1' and send_fcs_ok='1' and count="001" and byte_valid='0' then
						fcs_count <= fcs_count+1;
						data      <= fcs_byte;
						count     <= to_unsigned( 8/data_pins, 3 );
						
						if fcs_count="100" then
							count <= "000";
							fcs_count <= fcs_count;
						end if;
				end if;
					
							
			
			
				if send_state=state_send then
					if (append_fcs='0' and count="000" and byte_valid='0') 
					or (append_fcs='1' and fcs_count="100" and count="000") then
						
						if packet_sent_REG='0' then
							packet_sent_REG <= '1';
						end if;
						
						count <= (others => '0');

						-- race condition fix
						--if tx_clock_pulse='1' then
						tx_en <= '0';
						--end if;
					end if;
				end if;

				-- race condition fix
				if packet_sent_REG = '1' then
					tx_en <= '0';
				end if;

	
			end if;
		end if;
	end process;
end architecture RTL;
					
