----------------------------------------------------------------------------
----------------------------------------------------------------------------
--  The Free IP Project
--  VHDL Free-RAM Core
--  (c) 1999-2000, The Free IP Project and David Kessner
--
--
--  FREE IP GENERAL PUBLIC LICENSE
--  TERMS AND CONDITIONS FOR USE, COPYING, DISTRIBUTION, AND MODIFICATION
--
--  1.  You may copy and distribute verbatim copies of this core, as long
--      as this file, and the other associated files, remain intact and
--      unmodified.  Modifications are outlined below.  
--  2.  You may use this core in any way, be it academic, commercial, or
--      military.  Modified or not.  
--  3.  Distribution of this core must be free of charge.  Charging is
--      allowed only for value added services.  Value added services
--      would include copying fees, modifications, customizations, and
--      inclusion in other products.
--  4.  If a modified source code is distributed, the original unmodified
--      source code must also be included (or a link to the Free IP web
--      site).  In the modified source code there must be clear
--      identification of the modified version.
--  5.  Visit the Free IP web site for additional information.
--      http://www.free-ip.com
--
----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


package ram_lib is
  component ram_dp
    generic (addr_bits		:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    	:in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector(data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector(data_bits-1 downto 0)
         );
  end component;

  component ram_dp_lut
    generic (addr_bits		:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    	:in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector(data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector(data_bits-1 downto 0)
         );
  end component;

  component ram_x1_dp_lut
    generic (addr_bits	:integer);
    port (clk		:in  std_logic;
    	  port1_wr	:in  std_logic;
          port1_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          port1_din	:in  std_logic;
          port1_dout	:out std_logic;
          port2_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          port2_dout	:out std_logic
         );
  end component;

  component ram_x1_dp_block
    generic (addr_bits	:integer);
    port (reset		:in  std_logic;
	  wr_clk	:in  std_logic;
	  wr_en		:in  std_logic;
	  wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
	  wr_data	:in  std_logic;
	  rd_clk	:in  std_logic;
	  rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
	  rd_data	:out std_logic
         );
  end component;

  component ram_dp_block
    generic (addr_bits		:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    	:in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector(data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector(data_bits-1 downto 0)
         );
  end component;


  component ram_dp2
    generic (addr_bits		:integer;
             data_bits		:integer;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          p1_clk	:in  std_logic;
          p1_we		:in  std_logic;
          p1_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p1_din	:in  std_logic_vector (data_bits-1 downto 0);
          p1_dout	:out std_logic_vector (data_bits-1 downto 0);

          p2_clk	:in  std_logic;
          p2_we		:in  std_logic;
          p2_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p2_din	:in  std_logic_vector (data_bits-1 downto 0);
          p2_dout	:out std_logic_vector (data_bits-1 downto 0)          
         ); 
  end component;

  component ram_x1_dp2_block
    generic (addr_bits	:integer);
    port (reset		:in  std_logic;
          p1_clk	:in  std_logic;
          p1_we		:in  std_logic;
          p1_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p1_din	:in  std_logic;
          p1_dout	:out std_logic;
          p2_clk	:in  std_logic;
          p2_we		:in  std_logic;
          p2_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p2_din	:in  std_logic;
          p2_dout	:out std_logic
         );
  end component;


  function slv_to_integer(x : std_logic_vector)
       return integer;
  function integer_to_slv(n, bits : integer)
      return std_logic_vector;


  -- Xilinx Specific "components"
  component RAM16X1D
      port (D, WE, WCLK, A3, A2, A1, A0,
            DPRA3, DPRA2, DPRA1, DPRA0: in std_logic;
            SPO,DPO: out std_logic);
  end component;
  
  component RAMB4_S1_S1
    port (WEA, ENA, RSTA, CLKA	:in  std_logic;
          ADDRA			:in  std_logic_vector (11 downto 0);
          DIA			:in  std_logic_vector(0 downto 0);
          DOA			:out std_logic_vector(0 downto 0);
          WEB, ENB, RSTB, CLKB	:in  std_logic;
          ADDRB			:in  std_logic_vector (11 downto 0);
          DIB			:in  std_logic_vector(0 downto 0);
          DOB			:out std_logic_vector(0 downto 0)
          );
  end component;

  component RAMB4_S2_S2
    port (WEA, ENA, RSTA, CLKA	:in  std_logic;
          ADDRA			:in  std_logic_vector (10 downto 0);
          DIA			:in  std_logic_vector (1 downto 0);
          DOA			:out std_logic_vector (1 downto 0);
          WEB, ENB, RSTB, CLKB	:in  std_logic;
          ADDRB			:in  std_logic_vector (10 downto 0);
          DIB			:in  std_logic_vector (1 downto 0);
          DOB			:out std_logic_vector (1 downto 0)
          );
  end component;

  component RAMB4_S4_S4
    port (WEA, ENA, RSTA, CLKA	:in  std_logic;
          ADDRA			:in  std_logic_vector (9 downto 0);
          DIA			:in  std_logic_vector (3 downto 0);
          DOA			:out std_logic_vector (3 downto 0);
          WEB, ENB, RSTB, CLKB	:in  std_logic;
          ADDRB			:in  std_logic_vector (9 downto 0);
          DIB			:in  std_logic_vector (3 downto 0);
          DOB			:out std_logic_vector (3 downto 0)
          );
  end component;

  component RAMB4_S8_S8
    port (WEA, ENA, RSTA, CLKA	:in  std_logic;
          ADDRA			:in  std_logic_vector (8 downto 0);
          DIA			:in  std_logic_vector (7 downto 0);
          DOA			:out std_logic_vector (7 downto 0);
          WEB, ENB, RSTB, CLKB	:in  std_logic;
          ADDRB			:in  std_logic_vector (8 downto 0);
          DIB			:in  std_logic_vector (7 downto 0);
          DOB			:out std_logic_vector (7 downto 0)
          );
  end component;

  component RAMB4_S16_S16
    port (WEA, ENA, RSTA, CLKA	:in  std_logic;
          ADDRA			:in  std_logic_vector (7 downto 0);
          DIA			:in  std_logic_vector (15 downto 0);
          DOA			:out std_logic_vector (15 downto 0);
          WEB, ENB, RSTB, CLKB	:in  std_logic;
          ADDRB			:in  std_logic_vector (7 downto 0);
          DIB			:in  std_logic_vector (15 downto 0);
          DOB			:out std_logic_vector (15 downto 0)
          );
  end component;
  
end ram_lib;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

package body ram_lib is
  function slv_to_integer(x : std_logic_vector)
       return integer is
    variable n	:integer range 0 to (2**30 - 1);
  begin
    n := 0;
    for i in x'range loop
      n := n * 2;
      case x(i) is
        when '1' | 'H' => n := n + 1;
        when '0' | 'L' => null;
        when others =>	  null;
      end case;
    end loop;

    return n;
  end slv_to_integer;

  function integer_to_slv(n, bits : integer)
      return std_logic_vector is
    variable x		:std_logic_vector(bits-1 downto 0);
    variable tempn	:integer;
  begin
    x := (others => '0');
    tempn := n;
    for i in x'reverse_range loop
      if (tempn mod 2) = 1 then
        x(i) := '1';
      end if;
      tempn := tempn / 2;
    end loop;

    return x;
  end integer_to_slv;
end ram_lib;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_x1_dp_lut is
    generic (addr_bits	:integer);
    port (clk		:in std_logic;
    	  port1_wr	:in std_logic;
          port1_addr	:in std_logic_vector (addr_bits-1 downto 0);
          port1_din	:in std_logic;
          port1_dout	:out std_logic;
          port2_addr	:in std_logic_vector (addr_bits-1 downto 0);
          port2_dout	:out std_logic
         );
end ram_x1_dp_lut;


architecture arch_ram_x1_dp_lut of ram_x1_dp_lut is
  signal d_port1_dout :std_logic_vector ((2**(addr_bits-4))-1 downto 0);
  signal d_port2_dout :std_logic_vector ((2**(addr_bits-4))-1 downto 0);
  signal write_enable :std_logic_vector ((2**(addr_bits-4))-1 downto 0);

begin
  ------------------------------------
  -- Array of RAM Blocks
  RAMX1_DP: for i in (2**(addr_bits-4))-1 downto 0 generate
  begin
    RAM_LUT: component RAM16X1D port map
            (D=>port1_din,
             WE=>write_enable(i),
             WCLK=>clk,
             A3=>port1_addr(3),
             A2=>port1_addr(2),
             A1=>port1_addr(1),
             A0=>port1_addr(0),
             DPRA3=>port2_addr(3),
             DPRA2=>port2_addr(2),
             DPRA1=>port2_addr(1),
             DPRA0=>port2_addr(0),
             SPO=>d_port1_dout(i),
             DPO=>d_port2_dout(i));
  end generate RAMX1_DP;


  ------------------------------------
  -- Generate the write enables
  WE_GEN_SMALL: if addr_bits<=4 generate
  begin
    write_enable(0) <= port1_wr;
  end generate WE_GEN_SMALL;
  
  WE_GEN_LARGE: if addr_bits>4 generate
  begin
    WE_GEN:  for i in (2**(addr_bits-4))-1 downto 0 generate
    begin
      process (port1_wr, port1_addr)
      begin
        if integer_to_slv(i, addr_bits-4) = port1_addr(addr_bits-1 downto 4) and port1_wr='1' then
          write_enable(i) <= '1';
        else
          write_enable(i) <= '0';
        end if;
      end process;
    end generate WE_GEN;
  end generate WE_GEN_LARGE;


  ------------------------------------
  -- Mux the data outputs
  MUX_SMALL: if addr_bits<=4 generate
  begin
    port1_dout <= d_port1_dout(0);
    port2_dout <= d_port2_dout(0);
  end generate MUX_SMALL;

  MUX_LARGE: if addr_bits>4 generate
  begin
    port1_dout <= d_port1_dout(slv_to_integer(port1_addr(addr_bits-1 downto 4)));
    port2_dout <= d_port2_dout(slv_to_integer(port2_addr(addr_bits-1 downto 4)));
  end generate MUX_LARGE;

end arch_ram_x1_dp_lut;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_dp_lut is
    generic (addr_bits		:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    	:in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector (data_bits-1 downto 0)
         ); 
end ram_dp_lut;


architecture arch_ram_dp_lut of ram_dp_lut is
  signal rd_data_int	:std_logic_vector (data_bits-1 downto 0);
  
  signal wr_dout	:std_logic_vector (data_bits-1 downto 0);
begin
  RAM_DP:  for i in data_bits-1 downto 0 generate
  begin
    RAMX1: component ram_x1_dp_lut
      generic map (addr_bits)
      port map (wr_clk, wr_en, wr_addr, wr_data(i), wr_dout(i),
                rd_addr, rd_data_int(i));
  end generate RAM_DP;

  RAM_BUF:  if register_out_flag=0 generate
  begin
    rd_data <= rd_data_int;
  end generate RAM_BUF;

  RAM_REG:  if register_out_flag/=0 generate
  begin
    process (reset, rd_clk)
    begin
      if reset='1' then
        rd_data <= (others=>'0');
      elsif rd_clk'event and rd_clk='1' then
        rd_data <= rd_data_int;
      end if;
    end process;
  end generate RAM_REG; 
end arch_ram_dp_lut;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Note:  This entity only works for addr_bits>12
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_x1_dp_block is
    generic (addr_bits	:integer);
    port (reset		:in  std_logic;
	  wr_clk	:in  std_logic;
	  wr_en		:in  std_logic;
	  wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
	  wr_data	:in  std_logic;
	  rd_clk	:in  std_logic;
	  rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
	  rd_data	:out std_logic
         );
end ram_x1_dp_block;


architecture arch_ram_x1_dp_block of ram_x1_dp_block is
  signal d_port1_dout :std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  signal d_port2_dout :std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  signal write_enable :std_logic_vector ((2**(addr_bits-12))-1 downto 0);

  signal rd_addr_reg  :std_logic_vector (addr_bits-12-1 downto 0);
  
  signal always_one	:std_logic;
  signal always_zero	:std_logic;

  signal always_zero_v	:std_logic_vector (0 downto 0);
  signal wr_data_v	:std_logic_vector (0 downto 0);
begin
  always_one <= '1';
  always_zero <= '0';
  always_zero_v <= "0";

  wr_data_v(0) <= wr_data;
  
  ------------------------------------
  -- Array of RAM Blocks
  RAMX1_DP: for i in (2**(addr_bits-12))-1 downto 0 generate
  begin
    RAMX1:  component RAMB4_S1_S1 port map
          (write_enable(i), always_one, reset, wr_clk, wr_addr(11 downto 0), wr_data_v,     d_port1_dout(i downto i),
          always_zero,      always_one, reset, rd_clk, rd_addr(11 downto 0), always_zero_v, d_port2_dout(i downto i));
  end generate RAMX1_DP;


  ------------------------------------
  -- Generate the write enables
  WE_GEN:  for i in (2**(addr_bits-12))-1 downto 0 generate
  begin
    process (wr_en, wr_addr)
    begin
      if integer_to_slv(i, addr_bits-12) = wr_addr(addr_bits-1 downto 12) and wr_en='1' then
        write_enable(i) <= '1';
      else
        write_enable(i) <= '0';
      end if;
    end process;
  end generate WE_GEN;

  ------------------------------------
  -- Register the upper read address bits
  process (reset, rd_clk)
  begin
    if reset='1' then
      rd_addr_reg <= (others=>'0');
    elsif rd_clk'event and rd_clk='1' then
      rd_addr_reg <= rd_addr (addr_bits-1 downto 12);
    end if;
  end process;

  ------------------------------------
  -- Mux the data outputs
  rd_data <= d_port2_dout(slv_to_integer(rd_addr_reg));
end arch_ram_x1_dp_block;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_dp_block is
    generic (addr_bits		:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    	:in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector (data_bits-1 downto 0)
         ); 
end ram_dp_block;


architecture arch_ram_dp_block of ram_dp_block is
  signal always_one	:std_logic;
  signal always_zero	:std_logic;

  signal wr_dummy 	:std_logic_vector (data_bits-1 downto 0);
  signal rd_dummy 	:std_logic_vector (data_bits-1 downto 0);

  signal wr_dummy2 	:std_logic_vector (15 downto 0);
  signal rd_dummy2 	:std_logic_vector (15 downto 0);

  signal last_in	:std_logic_vector (15 downto 0);
  signal last_out	:std_logic_vector (15 downto 0);
  
  signal wr_addr2	:std_logic_vector (7 downto 0);
  signal rd_addr2	:std_logic_vector (7 downto 0);    

begin
  always_one <= '1';
  always_zero <= '0';
  rd_dummy <= (others=>'0');
  rd_dummy2 <= (others=>'0');
  
  --------------------------------------------
  -- Needs smaller than a 256xN RAM, use 256x16's anyway
  --------------------------------------------
  ADDRMIN:  if addr_bits<8 generate
  begin
    CLEARMIN_ADDR: for i in rd_addr2'high downto addr_bits generate
    begin
      rd_addr2(i) <= '0';
      wr_addr2(i) <= '0';
    end generate CLEARMIN_ADDR;
    
    rd_addr2(addr_bits-1 downto 0) <= rd_addr;
    wr_addr2(addr_bits-1 downto 0) <= wr_addr;
    
    RAMMIN:  for i in 0 to (data_bits/16)-1 generate
    begin
      RAMX16:  component RAMB4_S16_S16 port map
          (wr_en      , always_one, reset, wr_clk, wr_addr2, wr_data(16*i+15 downto 16*i),  wr_dummy(16*i+15 downto 16*i),
           always_zero, always_one, reset, rd_clk, rd_addr2, rd_dummy(16*i+15 downto 16*i), rd_data(16*i+15 downto 16*i));
    end generate RAMMIN;

    RAMMINA:  if (data_bits mod 16) /= 0 generate
    begin
      CLEARMIN: for i in last_in'high downto (data_bits mod 16) generate
      begin
        last_in(i) <= '0';
      end generate CLEARMIN;
      
      last_in((data_bits mod 16)-1 downto 0) <= wr_data(data_bits-1 downto data_bits-(data_bits mod 16));
      rd_data(data_bits-1 downto data_bits-(data_bits mod 16)) <= last_out((data_bits mod 16)-1 downto 0);
      
      RAMX16A:  component RAMB4_S16_S16 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr2, last_in(15 downto 0),  wr_dummy2(15 downto 0),
           always_zero, always_one, reset, rd_clk, rd_addr2, rd_dummy2(15 downto 0), last_out(15 downto 0));
    end generate RAMMINA;
  end generate ADDRMIN;


  --------------------------------------------
  -- Use 256x16 RAM's
  --------------------------------------------
  ADDR8:  if addr_bits=8 generate
  begin
    RAM8:  for i in 0 to (data_bits/16)-1 generate
    begin
      RAMX16:  component RAMB4_S16_S16 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, wr_data(16*i+15 downto 16*i),  wr_dummy(16*i+15 downto 16*i),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy(16*i+15 downto 16*i), rd_data(16*i+15 downto 16*i));
    end generate RAM8;

    RAM8A:  if (data_bits mod 16) /= 0 generate
    begin
      CLEAR8: for i in last_in'high downto (data_bits mod 16) generate
      begin
        last_in(i) <= '0';
      end generate CLEAR8;

      last_in((data_bits mod 16)-1 downto 0) <= wr_data(data_bits-1 downto data_bits-(data_bits mod 16));
      rd_data(data_bits-1 downto data_bits-(data_bits mod 16)) <= last_out((data_bits mod 16)-1 downto 0);

      RAMX16A:  component RAMB4_S16_S16 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, last_in(15 downto 0),   wr_dummy2(15 downto 0),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy2(15 downto 0), last_out(15 downto 0));
    end generate RAM8A;
  end generate ADDR8;

  --------------------------------------------
  -- Use 512x8 RAM's 
  --------------------------------------------
  ADDR9:  if addr_bits=9 generate
  begin
    RAM9:  for i in 0 to (data_bits/8)-1 generate
    begin     
      RAMX8:  component RAMB4_S8_S8 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, wr_data(8*i+7 downto 8*i),  wr_dummy(8*i+7 downto 8*i),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy(8*i+7 downto 8*i), rd_data(8*i+7 downto 8*i));
    end generate RAM9;

    RAM9A:  if (data_bits mod 8) /= 0 generate
    begin
      CLEAR9: for i in last_in'high downto (data_bits mod 8) generate
      begin
        last_in(i) <= '0';
      end generate CLEAR9;
      
      last_in((data_bits mod 8)-1 downto 0) <= wr_data(data_bits-1 downto data_bits-(data_bits mod 8));
      rd_data(data_bits-1 downto data_bits-(data_bits mod 8)) <= last_out((data_bits mod 8)-1 downto 0);

      RAMX8A:  component RAMB4_S8_S8 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, last_in(7 downto 0), wr_dummy2(7 downto 0),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy2(7 downto 0), last_out(7 downto 0));
    end generate RAM9A;
  end generate ADDR9;

  --------------------------------------------
  -- Use 1k x 4 RAM's
  --------------------------------------------
  ADDR10:  if addr_bits=10 generate
  begin
    RAM10:  for i in 0 to (data_bits/4)-1 generate
    begin
      RAMX4:  component RAMB4_S4_S4 port map
          (wr_en      , always_one, reset, wr_clk, wr_addr, wr_data(4*i+3 downto 4*i),  wr_dummy(4*i+3 downto 4*i),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy(4*i+3 downto 4*i), rd_data(4*i+3 downto 4*i));
    end generate RAM10;

    RAM10A:  if (data_bits mod 4) /= 0 generate
    begin
      CLEAR10: for i in last_in'high downto (data_bits mod 4) generate
      begin
        last_in(i) <= '0';
      end generate CLEAR10;

      last_in((data_bits mod 4)-1 downto 0) <= wr_data(data_bits-1 downto data_bits-(data_bits mod 4));
      rd_data(data_bits-1 downto data_bits-(data_bits mod 4)) <= last_out((data_bits mod 4)-1 downto 0);

      RAMX4A:  component RAMB4_S4_S4 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, last_in(3 downto 0), wr_dummy2(3 downto 0),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy2(3 downto 0), last_out(3 downto 0));
    end generate RAM10A;
  end generate ADDR10;

  --------------------------------------------
  -- Use 2k x 2 RAM's
  --------------------------------------------
  ADDR11:  if addr_bits=11 generate
  begin
    RAM11:  for i in 0 to (data_bits/2)-1 generate
    begin
      RAMX2:  component RAMB4_S2_S2 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, wr_data(2*i+1 downto 2*i),  wr_dummy(2*i+1 downto 2*i),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy(2*i+1 downto 2*i), rd_data(2*i+1 downto 2*i));
    end generate RAM11;

    RAM11A:  if (data_bits mod 2) /= 0 generate
    begin
      CLEAR11: for i in last_in'high downto (data_bits mod 2) generate
      begin
        last_in(i) <= '0';
      end generate CLEAR11;

      last_in((data_bits mod 2)-1 downto 0) <= wr_data(data_bits-1 downto data_bits-(data_bits mod 2));
      rd_data(data_bits-1 downto data_bits-(data_bits mod 2)) <= last_out((data_bits mod 2)-1 downto 0);

      RAMX2A:  component RAMB4_S2_S2 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, last_in(1 downto 0), wr_dummy2(1 downto 0),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy2(1 downto 0), last_out(1 downto 0));
    end generate RAM11A;
  end generate ADDR11;

  --------------------------------------------
  -- Use 4x k 1 RAM's
  --------------------------------------------
  ADDR12:  if addr_bits=12 generate
  begin
    RAM12:  for i in 0 to data_bits-1 generate
    begin
      RAMX1:  component RAMB4_S1_S1 port map
          (wr_en    ,   always_one, reset, wr_clk, wr_addr, wr_data(i downto i),  wr_dummy(i downto i),
           always_zero, always_one, reset, rd_clk, rd_addr, rd_dummy(i downto i), rd_data(i downto i));
    end generate RAM12;
  end generate ADDR12;

  --------------------------------------------
  -- Requires larger than a 4K x N RAM, use a 2-D array of 4Kx1's
  --------------------------------------------
  ADDRMAX:  if addr_bits>12 generate
      signal wr_en_col :std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  begin
    RAMMAX:  for i in 0 to data_bits-1 generate
    begin
      RAMXMAXA:  component ram_x1_dp_block generic map
                    (addr_bits)
                  port map
                    (reset, wr_clk, wr_en, wr_addr, wr_data(i),
                            rd_clk, rd_addr, rd_data(i));
    end generate RAMMAX;
  end generate ADDRMAX;
  
end arch_ram_dp_block;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_dp is
    generic (addr_bits		:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    	:in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector (data_bits-1 downto 0)
         ); 
end ram_dp;


architecture arch_ram_dp of ram_dp is
begin
  RAM_LUT: if (((2**addr_bits)*data_bits)<1024 and block_type=0)
              or block_type=1
              or register_out_flag=0 generate
  begin
    RAM_LUT0: component ram_dp_lut
        generic map (addr_bits, data_bits, register_out_flag, block_type)
        port map (reset, wr_clk, wr_en, wr_addr, wr_data, rd_clk, rd_addr, rd_data);
  end generate RAM_LUT;

  RAM_BLOCK: if (((2**addr_bits)*data_bits)>=1024 and block_type=0 and register_out_flag=1)
                or (block_type=2 and register_out_flag=1) generate
  begin
    RAM_BLOCK0: component ram_dp_block
        generic map (addr_bits, data_bits, register_out_flag, block_type)
        port map (reset, wr_clk, wr_en, wr_addr, wr_data, rd_clk, rd_addr, rd_data);
  end generate RAM_BLOCK;
end arch_ram_dp;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- Note:  This entity only works for addr_bits>12
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_x1_dp2_block is
    generic (addr_bits	:integer);
    port (reset		:in  std_logic;
          p1_clk	:in  std_logic;
          p1_we		:in  std_logic;
          p1_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p1_din	:in  std_logic;
          p1_dout	:out std_logic;
          p2_clk	:in  std_logic;
          p2_we		:in  std_logic;
          p2_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p2_din	:in  std_logic;
          p2_dout	:out std_logic
         );
end ram_x1_dp2_block;


architecture arch_ram_x1_dp2_block of ram_x1_dp2_block is
  signal p1_rdata 	:std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  signal p2_rdata 	:std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  
  signal p1_we_int	:std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  signal p2_we_int	:std_logic_vector ((2**(addr_bits-12))-1 downto 0);

  signal p1_addr_reg	:std_logic_vector (addr_bits-12-1 downto 0);
  signal p2_addr_reg	:std_logic_vector (addr_bits-12-1 downto 0);
  
  signal p1_wdata	:std_logic_vector (0 downto 0);
  signal p2_wdata	:std_logic_vector (0 downto 0);

  signal always_one	:std_logic;

begin
  always_one <= '1';

  p1_wdata(0) <= p1_din;
  p2_wdata(0) <= p2_din;
  
  ------------------------------------
  -- Array of RAM Blocks
  RAMX1_DP: for i in (2**(addr_bits-12))-1 downto 0 generate
  begin
    RAMX1:  component RAMB4_S1_S1 port map
          (p1_we_int(i), always_one, reset, p1_clk, p1_addr(11 downto 0), p1_wdata, p1_rdata(i downto i),
           p2_we_int(i), always_one, reset, p2_clk, p2_addr(11 downto 0), p2_wdata, p2_rdata(i downto i));
  end generate RAMX1_DP;


  ------------------------------------
  -- Generate the write enables
  WE_GEN0:  for i in (2**(addr_bits-12))-1 downto 0 generate
  begin
    process (p1_addr, p1_we)
    begin
      if integer_to_slv(i, addr_bits-12) = p1_addr(addr_bits-1 downto 12) and p1_we='1' then
        p1_we_int(i) <= '1';
      else
        p1_we_int(i) <= '0';
      end if;
    end process;
  end generate WE_GEN0;

  WE_GEN1:  for i in (2**(addr_bits-12))-1 downto 0 generate
  begin
    process (p2_addr, p2_we)
    begin
      if integer_to_slv(i, addr_bits-12) = p2_addr(addr_bits-1 downto 12) and p2_we='1' then
        p2_we_int(i) <= '1';
      else
        p2_we_int(i) <= '0';
      end if;
    end process;
  end generate WE_GEN1;

  ------------------------------------
  -- Register the upper read address bits
  process (reset, p1_clk)
  begin
    if reset='1' then
      p1_addr_reg <= (others=>'0');
    elsif p1_clk'event and p1_clk='1' then
      p1_addr_reg <= p1_addr (addr_bits-1 downto 12);
    end if;
  end process;

  process (reset, p2_clk)
  begin
    if reset='1' then
      p2_addr_reg <= (others=>'0');
    elsif p2_clk'event and p2_clk='1' then
      p2_addr_reg <= p2_addr (addr_bits-1 downto 12);
    end if;
  end process;

  ------------------------------------
  -- Mux the data outputs
  p1_dout <= p1_rdata(slv_to_integer(p1_addr_reg));
  p2_dout <= p2_rdata(slv_to_integer(p2_addr_reg));

end arch_ram_x1_dp2_block;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.ram_lib.all;

entity ram_dp2 is
    generic (addr_bits		:integer;
             data_bits		:integer;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          p1_clk	:in  std_logic;
          p1_we		:in  std_logic;
          p1_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p1_din	:in  std_logic_vector (data_bits-1 downto 0);
          p1_dout	:out std_logic_vector (data_bits-1 downto 0);

          p2_clk	:in  std_logic;
          p2_we		:in  std_logic;
          p2_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          p2_din	:in  std_logic_vector (data_bits-1 downto 0);
          p2_dout	:out std_logic_vector (data_bits-1 downto 0)          
         ); 
end ram_dp2;


architecture arch_ram_dp2 of ram_dp2 is
  signal always_one	:std_logic;
  signal always_zero	:std_logic;

  signal p1_addr_min 	:std_logic_vector (7 downto 0);
  signal p2_addr_min 	:std_logic_vector (7 downto 0);

  signal p1_lastin	:std_logic_vector (15 downto 0);
  signal p2_lastin	:std_logic_vector (15 downto 0);

  signal p1_lastout	:std_logic_vector (15 downto 0);
  signal p2_lastout	:std_logic_vector (15 downto 0);
  
begin
  always_one <= '1';
  always_zero <= '0';

  --------------------------------------------
  -- Needs smaller than a 256xN RAM, use 256x16's anyway
  --------------------------------------------
  ADDRMIN:  if addr_bits<8 generate
  begin
    -- Zero out (and drive) the high address bits
    CLEARMIN_ADDR: for i in p1_addr_min'high downto addr_bits generate
    begin
      p1_addr_min(i) <= '0';
      p2_addr_min(i) <= '0';
    end generate CLEARMIN_ADDR;
    
    p1_addr_min(addr_bits-1 downto 0) <= p1_addr;
    p2_addr_min(addr_bits-1 downto 0) <= p2_addr;

    RAMMIN:  for i in 0 to (data_bits/16)-1 generate
    begin
      RAMX16:  component RAMB4_S16_S16 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr_min, p1_din(16*i+15 downto 16*i),  p1_dout(16*i+15 downto 16*i),
           p2_we      , always_one, reset, p2_clk, p2_addr_min, p2_din(16*i+15 downto 16*i),  p2_dout(16*i+15 downto 16*i) );
    end generate RAMMIN;

    RAMMINA:  if (data_bits mod 16) /= 0 generate
    begin
      CLEARMIN: for i in p1_lastin'high downto (data_bits mod 16) generate
      begin
        p1_lastin(i) <= '0';
        p2_lastin(i) <= '0';
      end generate CLEARMIN;
      
      p1_lastin((data_bits mod 16)-1 downto 0) <= p1_din(data_bits-1 downto data_bits-(data_bits mod 16));
      p2_lastin((data_bits mod 16)-1 downto 0) <= p2_din(data_bits-1 downto data_bits-(data_bits mod 16));

      p1_dout(data_bits-1 downto data_bits-(data_bits mod 16)) <= p1_lastout((data_bits mod 16)-1 downto 0);
      p2_dout(data_bits-1 downto data_bits-(data_bits mod 16)) <= p2_lastout((data_bits mod 16)-1 downto 0);
      
      RAMX16A:  component RAMB4_S16_S16 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr_min, p1_lastin(15 downto 0),  p1_lastout(15 downto 0),
           p2_we      , always_one, reset, p2_clk, p2_addr_min, p2_lastin(15 downto 0),  p2_lastout(15 downto 0) );
    end generate RAMMINA;
  end generate ADDRMIN;

  --------------------------------------------
  -- Use 256x16 RAM's
  --------------------------------------------
  ADDR8:  if addr_bits=8 generate
  begin
    RAM8:  for i in 0 to (data_bits/16)-1 generate
    begin
      RAMX16:  component RAMB4_S16_S16 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_din(16*i+15 downto 16*i),  p1_dout(16*i+15 downto 16*i),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_din(16*i+15 downto 16*i),  p2_dout(16*i+15 downto 16*i) );
    end generate RAM8;

    RAM8A:  if (data_bits mod 16) /= 0 generate
    begin
      CLEAR8: for i in p1_lastin'high downto (data_bits mod 16) generate
      begin
        p1_lastin(i) <= '0';
        p2_lastin(i) <= '0';
      end generate CLEAR8;

      p1_lastin((data_bits mod 16)-1 downto 0) <= p1_din(data_bits-1 downto data_bits-(data_bits mod 16));
      p2_lastin((data_bits mod 16)-1 downto 0) <= p2_din(data_bits-1 downto data_bits-(data_bits mod 16));

      p1_dout(data_bits-1 downto data_bits-(data_bits mod 16)) <= p1_lastout((data_bits mod 16)-1 downto 0);
      p2_dout(data_bits-1 downto data_bits-(data_bits mod 16)) <= p2_lastout((data_bits mod 16)-1 downto 0);

      RAMX16A:  component RAMB4_S16_S16 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_lastin(15 downto 0),  p1_lastout(15 downto 0),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_lastin(15 downto 0),  p2_lastout(15 downto 0) );
    end generate RAM8A;
  end generate ADDR8;


  --------------------------------------------
  -- Use 512x8 RAM's 
  --------------------------------------------
  ADDR9:  if addr_bits=9 generate
  begin
    RAM9:  for i in 0 to (data_bits/8)-1 generate
    begin     
      RAMX8:  component RAMB4_S8_S8 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_din(8*i+7 downto 8*i),  p1_dout(8*i+7 downto 8*i),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_din(8*i+7 downto 8*i),  p2_dout(8*i+7 downto 8*i) );
    end generate RAM9;

    RAM9A:  if (data_bits mod 8) /= 0 generate
    begin
      CLEAR9: for i in p1_lastin'high downto (data_bits mod 8) generate
      begin
        p1_lastin(i) <= '0';
        p2_lastin(i) <= '0';
      end generate CLEAR9;

      p1_lastin((data_bits mod 8)-1 downto 0) <= p1_din(data_bits-1 downto data_bits-(data_bits mod 8));
      p2_lastin((data_bits mod 8)-1 downto 0) <= p2_din(data_bits-1 downto data_bits-(data_bits mod 8));

      p1_dout(data_bits-1 downto data_bits-(data_bits mod 8)) <= p1_lastout((data_bits mod 8)-1 downto 0);
      p2_dout(data_bits-1 downto data_bits-(data_bits mod 8)) <= p2_lastout((data_bits mod 8)-1 downto 0);

      RAMX8A:  component RAMB4_S8_S8 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_lastin(7 downto 0),  p1_lastout(7 downto 0),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_lastin(7 downto 0),  p2_lastout(7 downto 0) );
    end generate RAM9A;
  end generate ADDR9;

  --------------------------------------------
  -- Use 1k x 4 RAM's
  --------------------------------------------
  ADDR10:  if addr_bits=10 generate
  begin
    RAM10:  for i in 0 to (data_bits/4)-1 generate
    begin
      RAMX4:  component RAMB4_S4_S4 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_din(4*i+3 downto 4*i),  p1_dout(4*i+3 downto 4*i),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_din(4*i+3 downto 4*i),  p2_dout(4*i+3 downto 4*i) );
    end generate RAM10;

    RAM10A:  if (data_bits mod 4) /= 0 generate
    begin
      CLEAR10: for i in p1_lastin'high downto (data_bits mod 4) generate
      begin
        p1_lastin(i) <= '0';
        p2_lastin(i) <= '0';
      end generate CLEAR10;

      p1_lastin((data_bits mod 4)-1 downto 0) <= p1_din(data_bits-1 downto data_bits-(data_bits mod 4));
      p2_lastin((data_bits mod 4)-1 downto 0) <= p2_din(data_bits-1 downto data_bits-(data_bits mod 4));

      p1_dout(data_bits-1 downto data_bits-(data_bits mod 4)) <= p1_lastout((data_bits mod 4)-1 downto 0);
      p2_dout(data_bits-1 downto data_bits-(data_bits mod 4)) <= p2_lastout((data_bits mod 4)-1 downto 0);

      RAMX4A:  component RAMB4_S4_S4 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_lastin(3 downto 0),  p1_lastout(3 downto 0),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_lastin(3 downto 0),  p2_lastout(3 downto 0) );
    end generate RAM10A;
  end generate ADDR10;


  --------------------------------------------
  -- Use 2k x 2 RAM's
  --------------------------------------------
  ADDR11:  if addr_bits=11 generate
  begin
    RAM11:  for i in 0 to (data_bits/2)-1 generate
    begin
      RAMX2:  component RAMB4_S2_S2 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_din(2*i+1 downto 2*i),  p1_dout(2*i+1 downto 2*i),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_din(2*i+1 downto 2*i),  p2_dout(2*i+1 downto 2*i) );
    end generate RAM11;

    RAM11A:  if (data_bits mod 2) /= 0 generate
    begin
      CLEAR11: for i in p1_lastin'high downto (data_bits mod 2) generate
      begin
        p1_lastin(i) <= '0';
        p2_lastin(i) <= '0';
      end generate CLEAR11;

      p1_lastin((data_bits mod 2)-1 downto 0) <= p1_din(data_bits-1 downto data_bits-(data_bits mod 2));
      p2_lastin((data_bits mod 2)-1 downto 0) <= p2_din(data_bits-1 downto data_bits-(data_bits mod 2));

      p1_dout(data_bits-1 downto data_bits-(data_bits mod 2)) <= p1_lastout((data_bits mod 2)-1 downto 0);
      p2_dout(data_bits-1 downto data_bits-(data_bits mod 2)) <= p2_lastout((data_bits mod 2)-1 downto 0);

      RAMX2A:  component RAMB4_S2_S2 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_lastin(1 downto 0),  p1_lastout(1 downto 0),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_lastin(1 downto 0),  p2_lastout(1 downto 0) );
    end generate RAM11A;
  end generate ADDR11;

  --------------------------------------------
  -- Use 4x k 1 RAM's
  --------------------------------------------
  ADDR12:  if addr_bits=12 generate
  begin
    RAM12:  for i in 0 to data_bits-1 generate
    begin
      RAMX1:  component RAMB4_S1_S1 port map
          (p1_we      , always_one, reset, p1_clk, p1_addr, p1_din(i downto i),  p1_dout(i downto i),
           p2_we      , always_one, reset, p2_clk, p2_addr, p2_din(i downto i),  p2_dout(i downto i) );
    end generate RAM12;
  end generate ADDR12;


  --------------------------------------------
  -- Requires larger than a 4K x N RAM, use a 2-D array of 4Kx1's
  --------------------------------------------
  ADDRMAX:  if addr_bits>12 generate
      signal wr_en_col :std_logic_vector ((2**(addr_bits-12))-1 downto 0);
  begin
    RAMMAX:  for i in 0 to data_bits-1 generate
    begin
      RAMXMAXA:  component ram_x1_dp2_block generic map
                    (addr_bits)
                  port map
                    (reset,
                     p1_clk, p1_we, p1_addr, p1_din(i),  p1_dout(i),
                     p2_clk, p2_we, p2_addr, p2_din(i),  p2_dout(i) );
    end generate RAMMAX;
  end generate ADDRMAX;

end arch_ram_dp2;



----------------------------------------------------------------------------
----------------------------------------------------------------------------

----------------------------------------------------------------------------
----------------------------------------------------------------------------

