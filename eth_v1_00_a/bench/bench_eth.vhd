library IEEE;
use IEEE.std_logic_1164.all;
use std.textio.all;
use IEEE.numeric_std.all;

entity bench_eth is
end bench_eth;

architecture sim of bench_eth is
	constant C_OPB_AWIDTH : integer := 32;
	constant C_OPB_DWIDTH : integer := 32;
	
	constant A_RX_FIFO   : std_logic_vector(0 to 31) := X"FFFF_8000";
	constant A_RX_STATUS : std_logic_vector(0 to 31) := X"FFFF_8004";
	constant A_TX_FIFO   : std_logic_vector(0 to 31) := X"FFFF_8010";
	constant A_TX_STATUS : std_logic_vector(0 to 31) := X"FFFF_8014";

	component eth is
	generic (
		C_OPB_AWIDTH : integer := 32;
		C_OPB_DWIDTH : integer := 32;
		C_BASEADDR : std_logic_vector(0 to 31) := X"FFFF_8000";
		C_HIGHADDR : std_logic_vector(0 to 31) := X"FFFF_80FF"
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
		RX_D   : in std_logic_vector(3 downto 0);
		TX_CLK : in std_logic;
		TX_D   : out std_logic_vector(3 downto 0);
		TX_EN  : out std_logic
	);
	end component eth;

	constant clkperiod : time := 50 ns;  -- 20 MHz
	constant rx_period : time := 400 ns;  -- 2.5 MHz

	-- Stimulus
	file vectors0 : text open read_mode is "stimulus0.txt";
	file vectors1 : text open read_mode is "stimulus1.txt";

	file output_file0 : text open write_mode is "output_0.txt";
	file output_file1 : text open write_mode is "output_1.txt";
	file clk_drift    : text open read_mode is "clkdrift.txt";

	type vector is record
		rx_data : std_logic_vector(3 downto 0);
		rx_dv   : std_logic;
	end record;

	signal testvector0 : vector;
	signal testvector1 : vector;

	type testarray is array (natural range <>) of vector;

	signal rx_data0 : std_logic_vector(3 downto 0);
	signal rx_dv0   : std_logic;
	signal phy_clk  : std_logic := '0';
	signal rx_clk0  : std_logic;

  	signal OPB_Clk     : std_logic := '1';
  	signal OPB_Rst     : std_logic := '1';
	signal OPB_ABus    : std_logic_vector(0 to C_OPB_AWIDTH-1)   := (others => '0');
	signal OPB_BE      : std_logic_vector(0 to C_OPB_DWIDTH/8-1) := (others => '0');
	signal OPB_DBus    : std_logic_vector(0 to C_OPB_DWIDTH-1)   := (others => '0');
	signal OPB_RNW     : std_logic := '0';
	signal OPB_select  : std_logic := '0';
	signal OPB_seqAddr : std_logic := '0';

	signal ETH_DBus    : std_logic_vector(0 to C_OPB_DWIDTH-1);
	signal ETH_errAck  : std_logic;
	signal ETH_retry   : std_logic;
	signal ETH_toutSup : std_logic;
	signal ETH_xferAck : std_logic;


	--signal rx_clk1  : std_logic;
	--signal rx_data1 : std_logic_vector(3 downto 0);
	--signal rx_dv1   : std_logic;
	signal tx_clk0  : std_logic;
	--signal tx_clk1  : std_logic;
	signal tx_data0 : std_logic_vector(3 downto 0);
	signal tx_en0   : std_logic;
	--signal tx_data1 : std_logic_vector(3 downto 0);
	--signal tx_en1   : std_logic;

	signal rx_clk_drift0 : time := 0 ns;
	signal tx_clk_drift0 : time := 0 ns;
	--ignal rx_clk_drift1 : time := 0 ns;
	--signal tx_clk_drift1 : time := 0 ns;


	--signal rx_clock	: std_logic;
	--signal rx_data		: std_logic_vector(3 downto 0);
	--signal rx_dvalid	: std_logic;


	type t_rx_state is (rx_await_tx, rx_sleep, read_rx_fifo, read_rx_status);
	signal rx_state : t_rx_state;

	type t_tx_state is (tx_init, tx_send1, tx_w1, tx_send2, tx_w2, tx_status, tx_sleep);
	signal tx_state : t_tx_state;
	
	component tb_mii_reciever_model is
        generic (
                nic : string := "no_name"
        );
        port (
                mii_clk, 
                mii_dv   : std_logic;
                mii_rxd  : std_logic_vector(3 downto 0)
        );
	end component tb_mii_reciever_model;

begin  -- sim

	reciever : tb_mii_reciever_model
		generic map (
			nic => "tx0"
		)
		port map (
			mii_clk => tx_clk0,
			mii_dv  => tx_en0,
			mii_rxd => tx_data0
		);


	fake_bus : process (OPB_Clk) 
		--variable i : integer;
		variable status : std_logic_vector(0 to 31) := X"0000_0000";
		--variable fifo : std_logic_vector(0 to 31) := X"0000_0000";
	begin
		if rising_edge(OPB_Clk) then
			if (OPB_Rst='1') then
				rx_state <= rx_await_tx;
				tx_state <= tx_init;
				OPB_select <= '0';
				OPB_BE     <= X"F";
			else


				if tx_state=tx_init then
					OPB_ABus   <= A_TX_FIFO;
					OPB_select <= '1';
					OPB_RNW    <= '0';
					OPB_DBus   <= X"12345678";
					tx_state   <= tx_send1;
				
				elsif tx_state=tx_send1 then
					OPB_select <= '0';
					tx_state   <= tx_w1;

				elsif tx_state=tx_w1 then
					OPB_select <= '1';
					OPB_DBus   <= X"9abcdef0";
					tx_state   <= tx_send2;

				elsif tx_state=tx_send2 then
					OPB_select <= '0';
					tx_state   <= tx_w2;
					
				elsif tx_state=tx_w2 then
					OPB_ABus   <= A_TX_STATUS;
					OPB_select <= '1';
					OPB_DBus   <= X"C0000002";
					tx_state   <= tx_status;	

				elsif tx_state=tx_status then
					OPB_select <= '0';
					tx_state   <= tx_sleep;
			
				elsif rx_state=rx_await_tx then
					rx_state <= rx_sleep;

				elsif rx_state=rx_sleep and status(0)='0' then
					OPB_ABus   <= A_RX_STATUS;
					OPB_select <= '1';
					OPB_RNW    <= '1';
					rx_state   <= read_rx_status;
				
				elsif rx_state=read_rx_status and ETH_xferAck='1' then
					status := ETH_DBus;
					rx_state <= rx_sleep;
				
				end if;
				
			end if;
		end if;
	end process;

	
	Eth0 : ETH
	--generic map (
	--	C_OPB_AWIDTH : integer := 32;
	--	C_OPB_DWIDTH : integer := 32;
	--	C_BASEADDR : std_logic_vector(0 to 31) := X"FFFF_8000";
	--	C_HIGHADDR : std_logic_vector(0 to 31) := X"FFFF_80FF"
	--)
	port map (
		OPB_Clk       => OPB_Clk,
		OPB_Rst       => OPB_Rst,
		OPB_ABus      => OPB_ABus,
		OPB_BE        => OPB_BE,
		OPB_DBus      => OPB_DBus,
		OPB_RNW       => OPB_RNW,
		OPB_select    => OPB_select,
		OPB_seqAddr   => OPB_seqAddr,
		ETH_DBus    => ETH_DBus,
		ETH_errAck  => ETH_errAck,
		ETH_retry   => ETH_retry,
		ETH_toutSup => ETH_toutSup,
		ETH_xferAck => ETH_xferAck,
		-- PHY signals
		RX_CLK => rx_clk0,
		RX_DV  => rx_dv0,
		RX_D   => rx_data0,
		TX_CLK => tx_clk0,
		TX_D   => tx_data0,
		TX_EN  => tx_en0
	);

	halt_sim : process begin
		wait for 500000 ns;
		assert false report "Simulation complete" severity error;
	end process;

	readVec0 : process
		variable VectorLine  : line;
		variable VectorValid : boolean;
		variable Vdata       : bit_vector(3 downto 0);
		variable Vdv         : bit;

	begin
		while not endfile(vectors0) loop
			readline(vectors0, VectorLine);
			read(VectorLine, vdata, good => VectorValid);
			next when not VectorValid;

			read(VectorLine, vdv);
			rx_data0 <= to_stdLogicVector(Vdata);
			rx_dv0   <= to_stdULogic(vdv);

			wait until falling_edge(rx_clk0);
		end loop;
		wait;
	end process;  -- readVec


	readVecClk : process
		variable VectorLine  : line;
		variable VectorValid : boolean;
		variable time0_rx    : integer;
		variable time1_rx    : integer;
		variable time0_tx    : integer;
		variable time1_tx    : integer;

	begin
		while not endfile(clk_drift) loop
			readline(clk_drift, VectorLine);

			read(VectorLine, time0_rx);
				read(VectorLine, time0_tx);
				--read(VectorLine, time1_rx);
				--read(VectorLine, time1_tx);
				rx_clk_drift0 <= time0_rx * 1 ns;
				tx_clk_drift0 <= time0_tx * 1 ns;
				--rx_clk_drift1 <= time1_rx * 1 ns;
				--tx_clk_drift1 <= time1_tx * 1 ns;
			wait until rising_edge(phy_clk);
		end loop;
		wait;
	end process;

	clkprocess : process
	begin
	wait for 20 ns;
		while true loop
			OPB_Clk <= not OPB_Clk;
			wait for clkperiod/2;
		end loop;
	end process;


	rx_clk0 <= phy_clk after rx_clk_drift0;
	tx_clk0 <= phy_clk after tx_clk_drift0;
	--rx_clk1 <= phy_clk after rx_clk_drift1;
	--tx_clk1 <= phy_clk after tx_clk_drift1;

	phy_clk <= not phy_clk after rx_period/2;

	OPB_Rst   <= '0' after 105 ns;

end sim;





