library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_word_to_byte is
	port (
		sys_clk		: in std_logic;
		sys_reset	: in std_logic;
			
		word_rd		: out  std_logic;
                word_data       : in   std_logic_vector(31 downto 0);
                word_count      : in   std_logic_vector(2 downto 0);

		--append_fcs	: in std_logic;
		--fcs		: in std_logic_vector(31 downto 0);
		
		byte_rd		: in  std_logic;
                byte_data       : out std_logic_vector(7 downto 0);
                byte_valid      : out std_logic
	);
end  ethtx_word_to_byte;


architecture RTL of ethtx_word_to_byte is
	--type T_STATE is (S_WORD, S_FCS, S_SLEEP);
	type T_STATE is (S_WORD, S_SLEEP);
	signal state : T_STATE;

	signal count  : unsigned(2 downto 0);
	signal data   : std_logic_vector(31 downto 0);

begin

	byte_valid <= '1' when count /= "000" else '0';

	byte_data  <= data(31 downto 24);

	process (sys_clk) begin
		if rising_edge(sys_clk) then
			word_rd	<= '0';
			
			if sys_reset='1' then
				count      <= (others => '0');
				data       <= (others => '0');
				state      <= S_WORD;

			else
				if byte_rd = '1' then
					assert count/="000" report "byte read when count=0 !" severity error;
					
					count  <= count - 1 ;
					data   <= data(23 downto 0) & X"00";
				

				elsif state=S_WORD then
						if count="000" then
							if word_count="000" then
								--if append_fcs = '1' then
								--	state    <= S_FCS;
								--	count    <= "100";
								--	data     <= fcs;
								--else
									state    <= S_SLEEP;
								--end if;
							else
								word_rd <= '1';
								count   <= unsigned( word_count );
								data    <= word_data;
							end if;
						end if;

				--elsif state=S_FCS and count="000" then
				--	state    <= S_SLEEP;
				--	count	 <= "000";

				elsif state=S_SLEEP and word_count/="000" then
					state    <= S_WORD;
				end if;
			end if;		
		end if;
	end process;

	end architecture RTL;
