library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethtx_word_to_byte is
	port (
		tx_clk		: in std_logic;
		sys_reset	: in std_logic;
			
		word_rd		  : out  std_logic;
                word_data         : in   std_logic_vector(31 downto 0);
                word_count        : in   std_logic_vector(2 downto 0);
		word_almost_empty : in std_logic;

		byte_rd		: in  std_logic;
                byte_data       : out std_logic_vector(7 downto 0);
                byte_valid      : out std_logic
	);
end  ethtx_word_to_byte;


architecture RTL of ethtx_word_to_byte is
	type T_STATE is (S_WORD, S_SLEEP);
	signal state : T_STATE;

	signal count  : unsigned(2 downto 0);
	signal data   : std_logic_vector(31 downto 0);

	signal almost_empty : std_logic;

begin

	byte_data  <= data(31 downto 24);

	process (tx_clk) begin
		if rising_edge(tx_clk) then
			word_rd	<= '0';
			
			if sys_reset='1' then
				count        <= (others => '0');
				data         <= (others => '0');
				state        <= S_WORD;
				byte_valid   <= '0';
				almost_empty <= '0';

			else
				if byte_rd = '1' then
					assert count/="000" report "byte read when count=0 !" severity error;					
					count  <= count - 1 ;
					data   <= data(23 downto 0) & X"00";
				end if;
				
				if (state=S_WORD) and ((count="001" and byte_rd='1') or count="000") then
					
					byte_valid <= '0';
						
					if word_count="000" or almost_empty='1' then
						state        <= S_SLEEP;
						almost_empty <= '0';
							
					else	
						byte_valid   <= '1';
						word_rd      <= '1';
						count        <= unsigned( word_count );
						data         <= word_data;
						almost_empty <= word_almost_empty;
					end if;

				end if;
				
				if state=S_SLEEP and word_count/="000" and word_almost_empty='0' then
					state    <= S_WORD;
				end if;
			end if;		
		end if;
	end process;

	end architecture RTL;
