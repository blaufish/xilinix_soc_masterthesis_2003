library ieee;
use ieee.std_logic_1164.all;


entity mux4 is
	generic( 
		width : natural := 8
	);
	port (
		sel : in std_logic_vector(1 downto 0);
		d0  : in std_logic_vector(width-1 downto 0);
		d1  : in std_logic_vector(width-1 downto 0);
		d2  : in std_logic_vector(width-1 downto 0);
		d3  : in std_logic_vector(width-1 downto 0);
		q   : out std_logic_vector(width-1 downto 0)
	);
end mux4;

architecture RTL of mux4 is

begin
	process (sel, d0, d1, d2, d3) begin
		case sel is
		when "00" => q <= d0;
		when "01" => q <= d1;
		when "10" => q <= d2;
		when "11" => q <= d3;
		when others => null;
		end case;
	end process;
	
end architecture RTL;
		
