--
--
-- See Xilinx Answers Database, Record Number: 4075
-- SYNPLIFY: How to infer synchronous (single-port/dual-port) RAM in HDL (Verilog/VHDL)? 
--
-- Also see http://www.synplicity.com/literature/pdf/inferring_blockRAMs.pdf
--


library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;

entity blockram_dp is 
generic( 
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
end blockram_dp; 

architecture RTL of blockram_dp is 
type mem_type is array (mem_depth - 1 downto 0) of 
STD_LOGIC_VECTOR (d_width - 1 downto 0); 

signal mem : mem_type; 
signal read_addr : STD_LOGIC_VECTOR(addr_width - 1 downto 0);

--attribute syn_ramstyle of d : signal is "block_ram";

begin 

o <= mem(conv_integer(read_addr));

process(wclk)
begin 
if (rising_edge(wclk)) then 
  if (we = '1') then 
    mem(conv_integer(w_addr)) <= d; 
  end if; 
  read_addr <= r_addr;
end if; 
end process; 

end architecture RTL;
