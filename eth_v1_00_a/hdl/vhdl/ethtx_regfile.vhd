
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity ethtx_regfile is
	port (

		sys_clk		: in std_logic;
		sys_reset	: in std_logic;
		
		reg_status	: out std_logic_vector(0 to 31);
		reg_status_rd	: in  std_logic;

		reg_wr_data	: in  std_logic_vector(0 to 31);
		reg_fifo_wr	: in  std_logic;
		reg_ctrl_wr	: in  std_logic;

		word_rd		: in  std_logic;
                word_data       : out std_logic_vector(31 downto 0);
                word_count      : out std_logic_vector(2 downto 0);
		
		packet_sent	: in  std_logic;
		append_fcs	: out std_logic;
		packet_buffered : out std_logic
	);
end ethtx_regfile;


architecture RTL of ethtx_regfile is
	signal status_packet_buffered  : std_logic;
	signal status_append_fcs       : std_logic;
	signal status_fifo_words       : unsigned(8 downto 0);
	signal status_fifo_words_rev   : unsigned(8 downto 0);
	signal status_fifo_BILW        : unsigned(2 downto 0);

	--signal status_fifo_words_p1    : unsigned(8 downto 0);
	--signal status_fifo_words_p1_c3 : unsigned(0 downto 0);

	signal output_set : std_logic;

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
	signal fifo_full  : std_logic;
	signal fifo_empty : std_logic;

begin
	reg_status(0) <= status_packet_buffered;
	reg_status(1) <= status_append_fcs;
	reg_status(8) <= fifo_full;
	reg_status(9) <= fifo_empty;
	
	reg_status(20 to 28) <= std_logic_vector( status_fifo_words );
	reg_status(29 to 31) <= std_logic_vector( status_fifo_BILW );

	reg_status(2)		 <= reg_status_rd; -- suppress not used error message
	reg_status(3 to 7)   <= (others => '0');
	reg_status(10 to 19) <= (others => '0');
	
	packet_buffered <= status_packet_buffered;
	append_fcs      <= status_append_fcs;
	

	TX_FIFO : blockram_fifo
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
			full      => fifo_full,
			empty     => fifo_empty
		);


	word_data <= fifo_q;
	fifo_rd <= word_rd;

	status_p : process (sys_clk) begin
		if rising_edge(sys_clk) then
			fifo_reset <= '0';
			fifo_wr    <= '0';
			--fifo_rd    <= '0';
			--fifo_d     <= (others => '0');
	
			if sys_reset='1' or packet_sent='1' then
				status_packet_buffered <= '0';
				status_append_fcs      <= '0';
				status_fifo_words      <= (others => '0');
				status_fifo_words_rev  <= (others => '0');
				status_fifo_BILW       <= (others => '0');
				output_set             <= '0';
				word_count             <= (others => '0');
			    fifo_d     <= (others => '0');
			else
				
				
				if reg_ctrl_wr = '1' then
					status_packet_buffered       <= reg_wr_data(0);
					status_append_fcs            <= reg_wr_data(1);
					status_fifo_BILW(1 downto 0) <= unsigned( reg_wr_data(30 to 31) );
					status_fifo_BILW(2)          <= reg_wr_data(30) nor reg_wr_data(31);
					status_fifo_words_rev        <= status_fifo_words;
					
					--if reg_wr_data(8) = '1' then
					--	fifo_reset        <= '1';
					--	status_fifo_words <= (others => '0');
					--	status_fifo_BILW  <= (others => '0');
					--end if;	
						
				end if;

				if reg_fifo_wr = '1' then
					fifo_wr           <= '1';
					fifo_d            <= reg_wr_data;
					status_fifo_words <= status_fifo_words + 1;
				end if;

				if status_packet_buffered='1' and status_fifo_words_rev/="000000000" and output_set='0' then
					output_set <= '1';
					--fifo_rd    <= '1';
					
					status_fifo_words_rev <= status_fifo_words_rev - 1;
					
					if status_fifo_words_rev="000000001" then
						word_count <= std_logic_vector( status_fifo_BILW );
					else
						word_count <= "100";
					end if;
				end if;

				if output_set='1' and word_rd='1' then
					output_set <= '0';
					word_count <= (others => '0');
				end if;		

			end if;
		end if;
	end process;


end architecture RTL;
