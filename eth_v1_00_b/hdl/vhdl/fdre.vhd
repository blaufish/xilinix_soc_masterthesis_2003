library ieee;
use ieee.std_logic_1164.all;

entity FDRE is
	generic (
		width : natural := 1;
		resetvalue : std_logic_vector := "0"
	);
	port (
		clk : in std_logic;
		r   : in std_logic;
		e   : in std_logic;
		d   : in std_logic_vector(width-1 downto 0);
		q   : out std_logic_vector(width-1 downto 0)
	);
end fdre;

architecture RTL of FDRE is
	signal reg : std_logic_vector(width-1 downto 0);
begin
	q <= reg;

	process(clk) begin
 		if rising_edge(clk) then
			if r='1' then
				reg <= resetvalue;

			elsif e='1' then
				reg <= d;
			end if;
		end if;
	end process;

end architecture RTL;
