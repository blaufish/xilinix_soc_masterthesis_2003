library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ETH is
	generic (
		C_BASEADDR : std_logic_vector(0 to 31) := X"FFFF_8000";
		C_HIGHADDR : std_logic_vector(0 to 31) := X"FFFF_80FF";
		C_OPB_AWIDTH : integer := 32;
		C_OPB_DWIDTH : integer := 32;
		C_PHY_WIDTH : integer := 4
	);
	port (
		-- Global signals
		OPB_Clk : in std_logic;
		OPB_Rst : in std_logic;
		-- OPB signals
		OPB_ABus : in std_logic_vector(0 to C_OPB_AWIDTH-1);
		OPB_BE : in std_logic_vector(0 to C_OPB_DWIDTH/8-1);
		OPB_DBus : in std_logic_vector(0 to C_OPB_DWIDTH-1);
		OPB_RNW : in std_logic;
		OPB_select : in std_logic;
		OPB_seqAddr : in std_logic;
		ETH_DBus : out std_logic_vector(0 to C_OPB_DWIDTH-1);
		ETH_errAck : out std_logic;
		ETH_retry : out std_logic;
		ETH_toutSup : out std_logic;
		ETH_xferAck : out std_logic;
		-- PHY signals
		RX_CLK : in std_logic;
		RX_DV  : in std_logic;
		RX_D   : in std_logic_vector(C_PHY_WIDTH-1 downto 0);
		TX_CLK : in std_logic;
		TX_D   : out std_logic_vector(C_PHY_WIDTH-1 downto 0);
		TX_EN  : out std_logic
	);
end ETH;

architecture RTL of ETH is

	component ethrx_core is
	generic (
		rx_data_pins : natural := 4
	);
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		rx_clock	: in std_logic;
		rx_data		: in std_logic_vector(rx_data_pins-1 downto 0);
		rx_dvalid	: in std_logic;

		reg_status_wr	: in std_logic;
		reg_status	: out std_logic_vector(0 to 31);
		reg_fifo_rd	: in std_logic;
		reg_fifo	: out std_logic_vector(0 to 31);

		debugfile0	: out std_logic_vector(0 to 31);
		debugfile1	: out std_logic_vector(0 to 31)		

	);
	end component ethrx_core;	


	signal RX_reg_status_wr	: std_logic;
	signal RX_reg_status	: std_logic_vector(0 to 31);
	signal RX_reg_fifo_rd	: std_logic;
	signal RX_reg_fifo		: std_logic_vector(0 to 31);

	signal RX_debugfile0	: std_logic_vector(0 to 31);
	signal RX_debugfile1	: std_logic_vector(0 to 31);

	component ethtx_core is
        generic (
                data_pins : natural := 4
	);
        port (
                sys_clk         : in std_logic; -- rising edge
                sys_reset       : in std_logic; -- synchronous reset on 1

		reg_status	: out std_logic_vector(0 to 31);
		reg_status_rd	: in  std_logic;

		reg_wr_data	: in  std_logic_vector(0 to 31);
		reg_fifo_wr	: in  std_logic;
		reg_ctrl_wr	: in  std_logic;

		tx_clk		: in  std_logic;
		tx_en		: out std_logic;
		tx_d		: out std_logic_vector(data_pins-1 downto 0)
	);
	end component ethtx_core;

	signal TX_reg_status	: std_logic_vector(0 to 31);
	signal TX_reg_status_rd	: std_logic;
	signal TX_reg_wr_data	: std_logic_vector(0 to 31);
	signal TX_reg_fifo_wr	: std_logic;
	signal TX_reg_ctrl_wr	: std_logic;


	component FDRE is
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
	end component FDRE;

	signal ETH_DBus_REG_r : std_logic;
	signal ETH_DBus_REG_e : std_logic;
	signal ETH_DBus_REG   : std_logic_vector(0 to 31);

	-- internal signals

	signal address_match, uint32_operation, selected, ETH_xferAck_sig : std_logic;
	signal reg : std_logic_vector(0 to 2);
	signal dbus, dbus_2 : std_logic_vector(0 to 31);

begin -- architecture RTL

	ETH_xferAck <= ETH_xferAck_sig;

	address_match <= '1' when OPB_ABus(0 to 23) = C_BASEADDR(0 to 23) else '0';
	uint32_operation <= '1' when OPB_BE = X"F" else '0';

	selected <= OPB_select and address_match and uint32_operation and not ETH_xferAck_sig;

	reg <= OPB_ABus(27 to 29);

	
	dbus <= 
		RX_reg_fifo   when reg="000" else 
		RX_reg_status when reg="001" else 
		RX_debugfile0 when reg="010" else 
		RX_debugfile1 when reg="011" else 
		X"DEAD0001"   when reg="100" else -- read only
		TX_reg_status when reg="101" else
		X"DEAD0002"; -- unimplemented

	dbus_2 <= dbus when selected='1' else (others => '0');

	ETH_DBus_FDRE : FDRE 
		generic map (
			width => 32,
			resetvalue => X"0000_0000"
		)
		port map (
			clk => OPB_Clk,
			r => ETH_DBus_REG_r,
			e => ETH_DBus_REG_e,
			d => dbus_2,
			q => ETH_DBus_REG
		);

	ETH_DBus_REG_r <= OPB_Rst;
	ETH_DBus_REG_e <= '1';
	ETH_DBus <= ETH_DBus_REG;

	process (OPB_Clk) begin
		if rising_edge(OPB_Clk) then
			
			ETH_xferAck_sig <= '0';
			--ETH_DBus        <= (others => '0');
			
			RX_reg_status_wr  <= '0';
			RX_reg_fifo_rd    <= '0';
			
			TX_reg_status_rd  <= '0';
			TX_reg_fifo_wr    <= '0';			
			TX_reg_ctrl_wr    <= '0';
			TX_reg_wr_data	  <= OPB_DBus;
			
			
			if OPB_Rst='1' then
				null;
				
			elsif selected='1' then
				ETH_xferAck_sig <= '1';

				if OPB_RNW='1' then
					--ETH_DBus <= dbus;

					case reg is
					when  "000" => RX_reg_fifo_rd <= '1';
					when  "101" => TX_reg_status_rd <= '1';
					when others => null;
					end case;
									
				elsif OPB_RNW='0' then
				
					case reg is 
					when  "001" => RX_reg_status_wr <= '1';
					when  "100" => TX_reg_fifo_wr   <= '1';
					when  "101" => TX_reg_ctrl_wr   <= '1';
					when others => null;
					end case;

				end if;
			end if;
		end if;
	end process;


	RX_core : ethrx_core 
	generic map (
		rx_data_pins => C_PHY_WIDTH
	)
	port map (
		sys_clk		=> OPB_clk,
		sys_reset	=> OPB_Rst,
		rx_clock	=> RX_CLK,
		rx_data		=> RX_D,
		rx_dvalid	=> RX_DV,
		reg_status_wr	=> RX_reg_status_wr,
		reg_status	=> RX_reg_status,
		reg_fifo_rd	=> RX_reg_fifo_rd,
		reg_fifo	=> RX_reg_fifo,
		debugfile0	=> RX_debugfile0,
		debugfile1	=> RX_debugfile1
	);

	TX_core : ethtx_core
        generic map (
                data_pins => C_PHY_WIDTH
	)
        port map (
                sys_clk         => OPB_clk,
                sys_reset       => OPB_rst,
		reg_status	=> TX_reg_status,
		reg_status_rd	=> TX_reg_status_rd,
		reg_wr_data	=> TX_reg_wr_data,
		reg_fifo_wr	=> TX_reg_fifo_wr,
		reg_ctrl_wr	=> TX_reg_ctrl_wr,
		tx_clk		=> TX_CLK,
		tx_en		=> TX_EN,
		tx_d		=> TX_D
	);


	ETH_errAck  <= '0'; -- no errors
	ETH_retry   <= '0'; -- no retries
	ETH_toutSup <= '0'; -- no timeout suppress (ETH responds as fast as possible)
	
end architecture RTL;
