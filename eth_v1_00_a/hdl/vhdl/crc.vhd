--
-- CRC-32 / Ethernet FCS calculator for generic word width
--
-- Author: Peter Magnusson <petmag-8 at sm dot luth dot se>
--
-- Keywords: ethernet, cyclic redundant check, frame check sequence, VHSIC HDL, 
-- Keywords: Very High Speed Integrated Circuit Hardware Description Language
--
--
-- Generics: 
--   order  : from which order data is streamed.
--            TRUE:  MSB to the left (Big Endian)
--            FALSE: MSB to the right (IEEE Bit Transmition Order)
--   dwidth : data width, typical values are 4 (e.g. MII), 2 (e.g. RMII), 8 (bytes)
--   
-- Input ports:
--   CLK       : clock (registers & outputs change on rising edge)
--   RST       : synchronous reset, active high
--   softreset : synchronous reset (use between packets / streams)
--   dvalid    : set to '1' when data is available to the entity
--   data      : word passed for CRC calculation
--
--
-- Output ports:
--   crc       : CRC-32 value.
--
--
-- Notes on latency:
-- * data and dvalid is disregarded during RST='1' and softreset='1'.
-- * data and dvalid are set during the _same_ cycle.
-- * crc has a 1 cycle latency in regard to softreset and dvalid/data.
--
-- Please observe:
-- * order=false invokes _bitwise_ little endian, IEEE standard.
--   This is usefull prior to IEEE -> Big Endian or IEEE -> Little Endian conversion.
-- * dwidth>8 is not usefull with ethernet (because it is 8bit aligned).
-- * Implementations should differ between alignment errors and CRC/FCS errors.
--
library ieee;
use ieee.std_logic_1164.all;


entity crc32 is
	generic (
		order  : boolean := false;
		dwidth : integer := 8
	);
	port (
		CLK, RST  : in  std_logic;
		softreset : in  std_logic;
		dvalid    : in  std_logic;
		data      : in  std_logic_vector(dwidth-1 downto 0);
		crc       : out std_logic_vector(31 downto 0)
	);
end crc32;


architecture crc32_rtl of crc32 is

  --
  -- Function crc32f does one CRC32 iteration using one bit input
  --
  function crc32f( 
      crc : std_logic_vector(31 downto 0); 
	  b : std_logic 
  ) return std_logic_vector is
    variable crc_o : std_logic_vector(31 downto 0) ;
    variable zed   : std_logic := b xor crc(31); 
  begin
          crc_o( 0) := zed;
          crc_o( 1) := crc( 0) xor zed;
          crc_o( 2) := crc( 1) xor zed;
          crc_o( 3) := crc( 2);
          crc_o( 4) := crc( 3) xor zed;
          crc_o( 5) := crc( 4) xor zed;
          crc_o( 6) := crc( 5);
          crc_o( 7) := crc( 6) xor zed;
          crc_o( 8) := crc( 7) xor zed;
          crc_o( 9) := crc( 8);
          crc_o(10) := crc( 9) xor zed;
          crc_o(11) := crc(10) xor zed;
          crc_o(12) := crc(11) xor zed;
          crc_o(13) := crc(12);
          crc_o(14) := crc(13);
          crc_o(15) := crc(14);
          crc_o(16) := crc(15) xor zed;
          crc_o(17) := crc(16);
          crc_o(18) := crc(17);
          crc_o(19) := crc(18);
          crc_o(20) := crc(19);
          crc_o(21) := crc(20);
          crc_o(22) := crc(21) xor zed;
          crc_o(23) := crc(22) xor zed;
          crc_o(24) := crc(23);
          crc_o(25) := crc(24);
          crc_o(26) := crc(25) xor zed;
          crc_o(27) := crc(26);
          crc_o(28) := crc(27);
          crc_o(29) := crc(28);
          crc_o(30) := crc(29);
          crc_o(31) := crc(30);
	  return crc_o;
  end function;

  type ta_crc is array (natural range <>) of std_logic_vector(31 downto 0);

  signal crc_reg : std_logic_vector(31 downto 0);
  signal crc_net : ta_crc(dwidth downto 0);

begin

	crc <= not crc_reg;
	crc_net(0) <= crc_reg;

	
	crc_gen: for i in 0 to dwidth-1 generate 
	    net1 : if order generate
			big_endian  : crc_net(i+1) <= crc32f(crc_net(i), data(i));
		end generate;
		net2 : if not order generate
			ieee_endian : crc_net(i+1) <= crc32f(crc_net(i), data(dwidth-1-i));
		end generate;
	end generate;

	clkp : process (CLK)
	begin
		if rising_edge(CLK) then

			if (RST or softreset)='1' then
				crc_reg <= (others => '1');

			elsif dvalid='1' then
				crc_reg <= crc_net(dwidth);

			end if;
		end if;
	end process;

end architecture crc32_rtl;
