library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethrx_regfile is 
	port (
		sys_clk		: in std_logic; -- rising edge
		sys_reset	: in std_logic; -- synchronous reset on 1

		reg_status_wr	: in std_logic;
		reg_status	: out std_logic_vector(0 to 31);
		reg_fifo_rd	: in std_logic;
		reg_fifo	: out std_logic_vector(0 to 31);

		core_pkt_start	: in std_logic;
		core_pkt_end	: in std_logic;
		core_data	: in std_logic_vector(0 to 31);
		core_dv_bytes	: in std_logic_vector(0 to 2)

	);

end ethrx_regfile;

architecture RTL of ethrx_regfile is

	component blockram_fifo is
		generic (
			a_width : natural := 9;
			d_width : natural := 32
		);
		port (
			sys_clk   : in  std_logic;
			sys_reset : in  std_logic;
			softreset : in  std_logic;
			rd        : in  std_logic;
			wr        : in  std_logic;
			data_out  : out std_logic_vector(d_width-1 downto 0);
			data_in   : in  std_logic_vector(d_width-1 downto 0);
			full      : out std_logic;
			empty     : out std_logic
		);
	end component blockram_fifo;
	
		
	signal fifo_reset : std_logic;
	signal fifo_rd    : std_logic;
	signal fifo_wr    : std_logic;
	signal fifo_q     : std_logic_vector(31 downto 0);
	signal fifo_d     : std_logic_vector(31 downto 0);
	--signal fifo_full  : std_logic;
	--signal fifo_empty : std_logic;
			
	signal status_reg : std_logic_vector(0 to 31);
		
	signal SR_packet_buffered  : std_logic;
	signal SR_fifo_overflowed  : std_logic;
	signal SR_packet_length_nz : std_logic;
	signal SR_packet_preambled : std_logic;
	signal SR_packet_length    : std_logic_vector(0 to 10);


	signal packet_length_B_tmp : std_logic_vector(0 to 11);
	signal packet_length_A, packet_length_B : unsigned(0 to 11);
	signal packet_length : unsigned(0 to 11);

begin

       	status_reg(0)        <= SR_packet_buffered; 
	status_reg(1)        <= SR_fifo_overflowed;
	status_reg(2)        <= SR_packet_length_nz;
	status_reg(3)        <= SR_packet_preambled;
	status_reg(4 to 20)  <= (others => '0');
	status_reg(21 to 31) <= SR_packet_length;


	--regs <= fifo_q when reg_reg(1 to 2) = "00" else status_reg when reg_reg(1 to 2) = "01" else X"0000_0000";

	reg_fifo   <= fifo_q;
	reg_status <= status_reg;

	fifo_reset <= reg_status_wr ;



	packet_length_B_tmp(0 to 8)  <= "000000000"; 
	packet_length_B_tmp(9 to 11) <= core_dv_bytes;
	packet_length_B <= unsigned(packet_length_B_tmp);
	packet_length_A <= unsigned("0" & SR_packet_length);
	packet_length <= packet_length_A + packet_length_B;


	fifo_rd <= reg_fifo_rd and SR_packet_buffered;
	fifo_wr <= '1' when (not reg_status_wr and not SR_packet_buffered)='1' and core_dv_bytes /= "000" else '0';
	fifo_d  <= core_data;
	


	RX_FIFO : blockram_fifo
		generic map (
			a_width => 9,
			d_width => 32
		)
		port map (
			sys_clk   => sys_clk,
			sys_reset => sys_reset,
			softreset => fifo_reset,
			rd        => fifo_rd,
			wr        => fifo_wr,
			data_out  => fifo_q,
			data_in   => fifo_d,
			full      => open,
			empty     => open
		);

	process (sys_clk) 
	begin
		if rising_edge(sys_clk) then			
			if sys_reset = '1' then
				SR_packet_buffered   <= '0';
				SR_fifo_overflowed   <= '0'; 
				SR_packet_length_nz  <= '0'; 
				SR_packet_preambled  <= '0'; 
				SR_packet_length     <= (others => '0'); 

				-- fifo will reset by sys_reset too
			else
		
				if reg_status_wr='1' then
					SR_packet_buffered   <= '0';
					SR_fifo_overflowed   <= '0'; 
					SR_packet_length_nz  <= '0'; 
					SR_packet_preambled  <= '0'; 
					SR_packet_length     <= (others => '0'); 

				elsif SR_packet_buffered = '0' then

					SR_packet_length		<= std_logic_vector(packet_length(1 to 11));
					SR_packet_length_nz		<= SR_packet_length_nz or core_dv_bytes(2) or core_dv_bytes(1) or core_dv_bytes(0) ;
					SR_fifo_overflowed		<= SR_fifo_overflowed or std_logic(packet_length(0));

					if core_pkt_end = '1' then
						SR_packet_buffered <= '1';
					end if;	
	
					if core_pkt_start = '1' then
						SR_packet_preambled <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;


end architecture RTL;


