--
-- This is a VHDL model of an ethernet reciever for verification purposes.
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use std.textio.all;
use work.tb_debug_functions.all;

entity tb_mii_reciever_model is
	generic (
		nic : string := "no_name"
	);
	port (
		mii_clk, 
		mii_dv   : std_logic;
		mii_rxd  : std_logic_vector(3 downto 0)
	);
end tb_mii_reciever_model;

architecture tb_mii_reciever_model_sim of tb_mii_reciever_model is

signal RST : std_logic := '1';
constant ethernet_2_5MHz_IPG   : natural := 24; -- 9.6us*2.5MHz = 24
constant ethernet_preamble     : natural := 15;





type T_STATE is (IPG, STANDBY, PRE, RECV, IGNORE );
signal state : T_STATE := IPG;

constant msg : string := "##--## tb_mii_reciever_model  ::  " & nic & "  ::  "; 

begin
	bootup : process
	variable dummy    : boolean := false;
	variable nonsense     : unsigned(8*60-1 downto 0) := (others => '0');
	variable nonsensecrc1 : unsigned(31 downto 0);
	variable nonsensecrc2 : unsigned(31 downto 0);
	begin
		nonsensecrc1 := crc_iter_n( nonsense );
		nonsensecrc2 := crc_iter_n( nonsense & nonsensecrc1 );

		assert nonsensecrc2=X"00000000" report "CRC Check functions is insane!" severity error;

		wait for 1 ns;
		
		RST <= '1';
		assert false report (msg & "model booted!") severity note;
		wait;
	end process;

	p : process (mii_clk)
		variable count : integer := 0;
		variable countbytes : integer := 0;
		variable packet : unsigned(4*1024-1 downto 0) := (others=>'0');
		variable raw    : unsigned(4*1024-1 downto 0) := (others=>'0');
		variable rawcrc : unsigned(31 downto 0) := (others=>'0');
	begin
		if falling_edge(mii_clk) then
			if state /= RECV then
				packet := (others=>'0');
			end if;
			
			case state is
			
			when IPG =>
				assert mii_dv='0' report (msg&"IPG unexpected data!") severity note;
				--assert rmii_dv='1' report (msg&"IPG cycle "&count&" unexpected data: "&rmii_rxd) severity warning;

				if ( count = ethernet_2_5MHz_IPG ) then
					state <= STANDBY;
				else
					count := count + 1;
				end if;
				
			when STANDBY =>
				count := 0;
			
		 		if mii_dv='1' then

					if mii_rxd="0101" then
						state <= PRE;
					else
						state <= IGNORE;
						assert false report (msg&"STANDBY unexpected data!") severity warning;
						
					end if;
				end if;
					
			when PRE =>
				if mii_dv='0' then
					state <= IPG;
					assert false report (msg&"PREAMBLE: carrier lost, count="&natural'image(count)) severity warning;
				
				elsif mii_rxd="1101" then
					assert count > ethernet_preamble - 3 report (msg&"Short preamble!") severity warning;
					assert count < ethernet_preamble + 2 report (msg&"Long preamble!") severity warning;
					state <= RECV;
					count := 0;
					countbytes := 0;
					packet := (others => '0');
					raw := (others => '0');


				elsif mii_rxd="0101" then
					count := count + 1;
				else
					assert false report (msg&"PREAMBLE unexpected data! count="&natural'image(count)&" data="&natural'image(to_integer(unsigned(mii_rxd)))) severity warning;
				end if;
					
			when RECV =>
			  if mii_dv='0' then
					assert (count mod 2)=0 report (msg&"RECV/Length: alignment error! count="&natural'image(count)) severity warning;
					assert (count/2 >= 58) report (msg&"RECV/Length: short packet! length="&natural'image(count/4)) severity warning;
					assert (count/2 <= 1518) report (msg&"RECV/Length: Long packet! length="&natural'image(count/4)) severity warning;
					--assert (count/4 < 58) or (count > 1518*4) report (msg&"RECV: Packet received: "&packet2hex(packet));
					
					if (count mod 4)=0 and (count/4 >= 58) and (count/4 < 1518) then
						rawcrc := crc_iter_n(raw(2*count-1 downto 32) & not raw(31 downto 0));		
						assert false report (msg&"RECV: Packet received, Length: " & natural'image(count/4) & " FCS: " & unsigned2hex(raw(31 downto 0)) & " CRC: " & unsigned2hex(rawcrc) & " DATA: " & unsigned2hex(packet((count - count mod 4)*2-1 downto 0))) severity note;
					end if;	
					state <= IPG;
					count := 0;
				else
					case count mod 2 is
					when 0 =>
						packet := shift_left(packet, 8);
					        packet(3 downto 0) := unsigned( mii_rxd );
					when 1 =>
					        packet(7 downto 4) := unsigned( mii_rxd );
						countbytes := countbytes+1;
					when others => null;
					end case;
					raw := raw(raw'left-4 downto 0) & mii_rxd(0) & mii_rxd(1) & mii_rxd(2) & mii_rxd(3);
					count := count+1;
				end if;
				assert count<5000*2 report (msg&"RECV/Length: severe bug!") severity error;
					
			when IGNORE =>
				if mii_dv='0' then
					state <= IPG;
				end if;
			when others =>
				null;
			end case;
		end if;
	end process;
			  



end tb_mii_reciever_model_sim ;


