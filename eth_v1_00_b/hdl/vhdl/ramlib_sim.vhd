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
    	  wr_en	    :in  std_logic;
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


  function slv_to_integer(x : std_logic_vector)
       return integer;
  function integer_to_slv(n, bits : integer)
      return std_logic_vector;  
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
    variable n : integer := 0;
    variable failure : boolean := false;
  begin
    assert (x'high - x'low + 1) <= 31
        report "Range of sulv_to_integer argument exceeds integer range"
        severity error;
    for i in x'range loop
      n := n * 2;
      case x(i) is
        when '1' | 'H' => n := n + 1;
        when '0' | 'L' => null;
        when others =>
            -- failure := true;
            null;
      end case;
    end loop;

    assert not failure
      report "sulv_to_integer cannot convert indefinite std_ulogic_vector"
      severity error;
    if failure then
      return 0;
    else
      return n;
    end if;
  end slv_to_integer;

  function integer_to_slv(n, bits : integer)
      return std_logic_vector is
    variable x : std_logic_vector(bits-1 downto 0) := (others => '0');
    variable tempn : integer := n;
  begin
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

entity ram_dp is
    generic (addr_bits	:integer;
             data_bits		:integer;
             register_out_flag	:integer := 0;
             block_type		:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
    	  wr_en	    :in  std_logic;
          wr_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          wr_data	:in  std_logic_vector(data_bits-1 downto 0);
	  rd_clk	:in  std_logic;
          rd_addr	:in  std_logic_vector (addr_bits-1 downto 0);
          rd_data	:out std_logic_vector(data_bits-1 downto 0)
         ); 

   subtype word is std_logic_vector (data_bits-1 downto 0);
   constant nwords : integer := 2 ** addr_bits;
   type ram_type is array (0 to nwords-1) of word;
end ram_dp;


architecture arch_ram_dp of ram_dp is
  shared variable ram :ram_type;
begin

  -- Handle the write port
  process (wr_clk)
    variable address :integer;
  begin
    if wr_clk'event and wr_clk='1' then
      if wr_en='1' then
        address := slv_to_integer (wr_addr);
        ram(address) := wr_data;
      end if;
    end if;
  end process;


  -- Handle the read ports
  READ_BUF: if register_out_flag=0 generate
  begin
    process (rd_addr, rd_clk, wr_clk)
    begin
      rd_data <= ram(slv_to_integer(rd_addr));
    end process;
  end generate READ_BUF;


  READ_REG: if register_out_flag/=0 generate
  begin
    process (reset, rd_clk)
    begin
      if reset='1' then
        rd_data <= (others=>'0');
      elsif rd_clk'event and rd_clk='1' then
        rd_data <= ram(slv_to_integer(rd_addr));
      end if;
    end process;
  end generate READ_REG;
      
end arch_ram_dp;


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

   subtype word is std_logic_vector (data_bits-1 downto 0);
   constant nwords : integer := 2 ** addr_bits;
   type ram_type is array (0 to nwords-1) of word;
end ram_dp2;


architecture arch_ram_dp2 of ram_dp2 is
  shared variable ram :ram_type;
begin

  -- Handle the write ports
  process (p1_clk)
    variable address :integer;
  begin
    if p1_clk'event and p1_clk='1' then
      if p1_we='1' then
        address := slv_to_integer (p1_addr);
        ram(address) := p1_din;
      end if;
    end if;
  end process;

  process (p2_clk)
    variable address :integer;
  begin
    if p2_clk'event and p2_clk='1' then
      if p2_we='1' then
        address := slv_to_integer (p2_addr);
        ram(address) := p2_din;
      end if;
    end if;
  end process;


  -- Handle the read ports
  process (reset, p1_clk)
  begin
    if reset='1' then
      p1_dout <= (others=>'0');
    elsif p1_clk'event and p1_clk='1' then
      p1_dout <= ram(slv_to_integer(p1_addr));
    end if;
  end process;
      
  process (reset, p2_clk)
  begin
    if reset='1' then
      p2_dout <= (others=>'0');
    elsif p2_clk'event and p2_clk='1' then
      p2_dout <= ram(slv_to_integer(p2_addr));
    end if;
  end process;
      
end arch_ram_dp2;


----------------------------------------------------------------------------
----------------------------------------------------------------------------


