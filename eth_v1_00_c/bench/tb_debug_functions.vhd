library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tb_debug_functions is

function unsigned2hex( packet : unsigned ) return string;

function crc_iter_1( crc : unsigned(31 downto 0); input : std_logic ) return unsigned;
function crc_iter_n( packet : unsigned ) return unsigned;


end tb_debug_functions;

package body tb_debug_functions is

  function unsigned2hex( packet : unsigned ) return string is
		variable tmp : string(1 to packet'length/4) ;
		type ta_character is array (natural range <>) of character;
		constant hexset : ta_character(0 to 15) := ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
	begin
		for i in (packet'length/4)-1 downto 0 loop
			tmp((packet'length/4) - i) := hexset(to_integer(packet(i*4+3 downto i*4)));
		end loop;
		return tmp;
	end;
  
	function crc_iter_1( crc : unsigned(31 downto 0); input : std_logic ) return unsigned is
    variable crc_o : unsigned(31 downto 0) ;
    variable zed   : std_logic := input xor crc(31); 
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

  function crc_iter_n( packet : unsigned ) return unsigned is
	  variable crc : unsigned(31 downto 0) := (others=>'1');
	begin
	  for i in packet'left downto packet'right loop
			crc := crc_iter_1(crc, packet(i));
		end loop;
		return crc;
  end;

end ;
