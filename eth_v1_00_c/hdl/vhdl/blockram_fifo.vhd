library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blockram_fifo is
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
end blockram_fifo;

architecture RTL of blockram_fifo is
	constant depth : integer := 2**a_width;

	component blockram_dp is 
	generic ( 
		d_width    : integer := 16; 
		addr_width : integer := 8;
		mem_depth  : integer := 256
	);
	port (
		o : out STD_LOGIC_VECTOR(d_width - 1 downto 0); 
		we, wclk : in STD_LOGIC; 
		d : in STD_LOGIC_VECTOR(d_width - 1 downto 0);
		w_addr : in STD_LOGIC_VECTOR(addr_width - 1 downto 0);
		r_addr : in STD_LOGIC_VECTOR(addr_width - 1 downto 0)); 
	end component blockram_dp; 


	signal elems : natural range depth downto 0;
	--signal p_rd, p_rd_next, p_wr  : natural range depth-1 downto 0;
	signal p_rd, p_wr  : unsigned( a_width-1 downto 0 );

  	signal read_enable : boolean;
	signal write_enable : boolean;

	signal ram_we : std_logic;
	signal ram_waddr, ram_raddr :  std_logic_vector(a_width - 1 downto 0);

	signal ram_tmp : std_logic_vector(d_width-1 downto 0);

	--signal reset : std_logic;
begin
	full     <= '1' when elems=depth else '0';
	empty    <= '1' when elems=0 else '0';

	write_enable <= wr = '1'; -- and elems /= depth;
	read_enable <= rd = '1'; -- and elems /= 0;

	ram_we <= '1' when write_enable else '0';

	

	ram_raddr <= std_logic_vector( p_rd );
	ram_waddr <= std_logic_vector( p_wr );
	
	ram : blockram_dp
	generic map ( 
		d_width    => d_width,
		addr_width => a_width,
		mem_depth  => depth
	)
	port map (
		o      => ram_tmp,
		we     => ram_we, 
		wclk   => sys_clk,
		d      => data_in,  
		r_addr => ram_raddr,
		w_addr => ram_waddr
	);

	process (sys_clk) begin
		if rising_edge(sys_clk) then
			data_out <= ram_tmp;
		end if;
	end process;


	--reset <= sys_reset or softreset;

	p_rd_p : process (sys_clk) begin
		if rising_edge(sys_clk) then
			if sys_reset='1' then
				p_rd <= (others => '0');

			elsif softreset='1' then
				p_rd <= (others => '0');

			elsif read_enable then
				p_rd <= p_rd + 1;
			end if;
		end if;
	end process p_rd_p;




  	p_wr_p : process(sys_clk) begin
		if rising_edge(sys_clk) then
			if sys_reset='1' then
      				p_wr  <= (others => '0');

			elsif softreset='1' then
      				p_wr  <= (others => '0');

			elsif write_enable then
				p_wr <= p_wr+1;
			end if;	
		end if;
	end process;
  

  	p_elems_p : process(sys_clk) begin
		if rising_edge(sys_clk) then
			if sys_reset='1' then
	      			elems <= 0;

			elsif softreset='1' then
	      			elems <= 0;

			elsif (write_enable or read_enable) then
			
				if write_enable and not read_enable then
					elems <= elems + 1;
				elsif not write_enable and read_enable then
					elems <= elems - 1;
				end if;
			end if;
		end if;
	end process;

end architecture RTL;


    

