library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_byte_to_word is
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		byte_pkt_start  : in std_logic;
		byte_pkt_end    : in std_logic;
		byte_data	: in std_logic_vector(7 downto 0);
		byte_dvalid	: in std_logic;
		
		word_pkt_start	: out std_logic;
		word_pkt_end	: out std_logic;
		word_data	: out std_logic_vector(0 to 31);
		word_dv_bytes	: out std_logic_vector(0 to 2)
	);
end ethrx_byte_to_word;

architecture RTL of ethrx_byte_to_word is
	signal word  : std_logic_vector(23 downto 0);
	signal count : natural range 0 to 3;

begin
	process (sys_clk) 
	begin
	
		if rising_edge(sys_clk) then
			
			word_dv_bytes  <= "000";
				
			if sys_reset='1' then
				count <= 0;
				word_pkt_start <= '0';
				word_pkt_end   <= '0';
				word <= (others => '0');
				count <= 0;
			else
				word_pkt_start <= byte_pkt_start;
				word_pkt_end   <= byte_pkt_end;
				
				if byte_pkt_end = '1' then
					assert byte_dvalid = '0' report "illegal input; byte_pkt_end = '1' and byte_dvalid = '1'" severity error;
					assert count /= 4 report "illegal input; byte_pkt_end = '1' while count=4. Clock error?" severity error;

					word_data     <= word & X"00";
					word_dv_bytes <= std_logic_vector( to_unsigned( count, 3 ) );
					word          <= (others => '0');


				elsif byte_dvalid = '1' then

					if count=3 then
						word_data     <= word & byte_data;
						word_dv_bytes <= "100";
						count         <= 0;
						word          <= (others => '0');
					else
						count <= count + 1;
					end if;

					case count is
					when 0 => word(23 downto 16) <= byte_data;
					when 1 => word(15 downto  8) <= byte_data;
					when 2 => word( 7 downto  0) <= byte_data;
					when 3 => null;
					when others => assert false report "unreachable state" severity error;
					end case;


				end if;

			end if;
		end if;
	end process;
	
end architecture RTL;




