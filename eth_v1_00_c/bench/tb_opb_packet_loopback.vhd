
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_opb_packet_loopback is
	generic (
		A_RX_FIFO   : std_logic_vector(0 to 31) := X"FFFF_8000";
		A_RX_STATUS : std_logic_vector(0 to 31) := X"FFFF_8004";
		A_TX_FIFO   : std_logic_vector(0 to 31) := X"FFFF_8010";
		A_TX_STATUS : std_logic_vector(0 to 31) := X"FFFF_8014";
		cutfcs      : std_logic := '1'
	);
	port (
                OPB_Clk     : in std_logic;
                OPB_Rst     : in std_logic;
                OPB_ABus    : out std_logic_vector(0 to 31);
                OPB_BE      : out std_logic_vector(0 to 3);
                OPB_DBus    : out std_logic_vector(0 to 31);
                OPB_RNW     : out std_logic;
                OPB_select  : out std_logic;
                ETH_DBus    : in std_logic_vector(0 to 31);
                ETH_xferAck : in std_logic
	);
end tb_opb_packet_loopback;

architecture tb_opb_packet_loopback_sim of tb_opb_packet_loopback is

                signal OPB_ABus_REG    : std_logic_vector(0 to 31);
                signal OPB_BE_REG      : std_logic_vector(0 to 3);
                signal OPB_DBus_REG    : std_logic_vector(0 to 31);
                signal OPB_RNW_REG     : std_logic;
                signal OPB_select_REG  : std_logic;
                --signal ETH_DBus_REG    : std_logic_vector(0 to C_OPB_DWIDTH-1);
                signal ETH_xferAck_REG : std_logic;

		constant msg : string := "##--## tb_opb_packet_loopback  ::  ";

		type T_STATEV is (SV_RST, SV_RX_STATUS, SV_TX_STATUS, SV_SHUFFLE_DATA, SV_CLEAR_RX, SV_SEND_TX );
		signal statev : T_STATEV;

		subtype T_STATE is std_logic_vector( 2 downto 0);
		constant S_RST          : T_STATE := "000";
		constant S_RX_STATUS    : T_STATE := "001";
		constant S_TX_STATUS    : T_STATE := "010";
		constant S_SHUFFLE_DATA : T_STATE := "011";
		constant S_CLEAR_RX     : T_STATE := "100";
		constant S_SEND_TX      : T_STATE := "101";
		signal   state          : T_STATE := S_RST;





		signal lengthDiv4 : unsigned( 8 downto 0 );
		signal lengthMod3 : unsigned( 1 downto 0 );

begin
	OPB_ABus   <= OPB_ABus_REG;
	OPB_BE     <= OPB_BE_REG;
	OPB_RNW    <= OPB_RNW_REG;
	OPB_select <= OPB_select_REG;
	OPB_DBus   <= OPB_DBus_REG when (OPB_select_REG='1' and OPB_RNW_REG='0') else (others => 'U');

	xferAck_checkp : process(OPB_Clk) 
	begin
		if rising_edge(OPB_Clk) then
			if OPB_Rst='1' then
				ETH_xferAck_REG <= '0';
			else
				ETH_xferAck_REG <= ETH_xferAck;
				
				if ETH_xferAck_REG/='0' then
					assert ETH_xferAck='0' report msg & "ETH_xferAck/='0' for two cycles!" severity error;
				end if;
				
				if ETH_xferAck/='1' then
					assert ETH_DBus=X"0000_0000" report msg & "ETH_DBus/=0x00000000 and ETH_xferAck/='1'" severity error;
				end if;

				if ETH_xferAck/='0' then
					assert OPB_select_REG='1' report msg & "ETH_xferAck/='0' and OPB_select/='1'" severity error;
				end if;
			end if;
		end if;
	end process;

	OPB_BE_REG <= X"F";


	statev <= 
		SV_RST          when state=S_RST else 
		SV_RX_STATUS    when state=S_RX_STATUS else 
		SV_TX_STATUS    when state=S_TX_STATUS else 
		SV_SHUFFLE_DATA when state=S_SHUFFLE_DATA else
		SV_CLEAR_RX     when state=S_CLEAR_RX else
		SV_SEND_TX      when state=S_SEND_TX ;


	loopback_p : process (OPB_Clk) 
		variable length_tmp : unsigned(8 downto 0);
		variable dbus_tmp : std_logic_vector(0 to 31);
	begin
		if rising_edge(OPB_Clk) then
			if OPB_Rst='1' then
				state          <= S_RX_STATUS;
				OPB_ABus_REG   <= A_RX_STATUS;
				OPB_RNW_REG    <= '1';
				OPB_select_REG <= '1';
				length_tmp     := (others => '0');
				
			elsif state=S_RX_STATUS and ETH_xferAck='1' then
				if ETH_DBus(0)='1' then
					state         <= S_TX_STATUS;
					OPB_ABus_REG  <= A_TX_STATUS;
					
					lengthMod3    <= unsigned( ETH_DBus(30 to 31) );
					length_tmp    := unsigned( ETH_DBus(21 to 29) );
					
					if ETH_DBus(30 to 31)/="00" then
						length_tmp := length_tmp + 1;
					end if;

					if cutfcs='1' then
						length_tmp := length_tmp - 1;
					end if;
					
					lengthDiv4 <= length_tmp;
				end if;
			
			elsif state=S_TX_STATUS and ETH_xferAck='1' then
				if ETH_DBus(0)='0' then
					state         <= S_SHUFFLE_DATA;
					OPB_ABus_REG  <= A_RX_FIFO;
				end if;
			
			elsif state=S_SHUFFLE_DATA and ETH_xferAck='1' then
				if OPB_ABus_REG=A_RX_FIFO then
					OPB_RNW_REG  <= '0';
					OPB_ABus_REG <= A_TX_FIFO;
					OPB_DBus_REG <= ETH_DBus;
					
				elsif OPB_ABus_REG=A_TX_FIFO then
					OPB_RNW_REG  <= '1';
					OPB_ABus_REG <= A_RX_FIFO;

					if lengthDiv4=0 then
						state        <= S_CLEAR_RX;
						OPB_ABus_REG <= A_RX_STATUS;
						OPB_DBus_REG <= X"8000_0000";
						OPB_RNW_REG  <= '0';

					else
						lengthDiv4 <= lengthDiv4 - 1;
					end if;
	
				end if;
					
			elsif state=S_CLEAR_RX and ETH_xferAck='1' then
				state        <= S_SEND_TX;
				OPB_ABus_REG <= A_TX_STATUS;
				
				if cutfcs='1' then
					dbus_tmp := X"C000_0000";
				else
					dbus_tmp := X"8000_0000";
				end if;
				
				OPB_DBus_REG <= dbus_tmp or ("000000000000000000000000000000" & std_logic_vector( lengthMod3 ) );
					
				OPB_RNW_REG  <= '0';

			elsif state=S_SEND_TX and ETH_xferAck='1' then
				state          <= S_RX_STATUS;
				OPB_ABus_REG   <= A_RX_STATUS;
				OPB_RNW_REG    <= '1';
				
			end if;
		end if;
	end process;
				



end architecture tb_opb_packet_loopback_sim;
