----------------------------------------------------------------------------
----------------------------------------------------------------------------
--  The Free IP Project
--  VHDL Free-FIFO Core
--  (c) 2000, The Free IP Project and David Kessner
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

package free_fifo is
  component fifo_sync
    generic (data_bits  :integer;
             addr_bits  :integer;
             block_type :integer := 0);
    port (reset		:in std_logic;
          clk		:in std_logic;
          wr_en		:in std_logic;
          wr_data	:in std_logic_vector (data_bits-1 downto 0);
          rd_en		:in std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;
          
             
  component fifo_async
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fifo_arch  :integer := 0); -- 0=Generic architecture, 1=Xilinx, 2=Xilinx w/carry
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;


  component fifo_wrcount
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             async_size :integer := 16); 
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;


  component fifo_wrcount_orig
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fifo_arch  :integer := 0); -- 0=Generic architecture, 1=Xilinx, 2=Xilinx w/carry
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;
  

  component fifo_rdcount
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             async_size :integer := 16); 
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;

  component fifo_rdcount_orig
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fifo_arch  :integer := 0); -- 0=Generic architecture, 1=Xilinx, 2=Xilinx w/carry
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;


  component fifo_async_xilinx
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fpga_type  :integer := 0);  -- 0=generic VHDL, 1=Xilinx Spartan2/Virtex
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          full_out	:out std_logic;
          empty_out	:out std_logic
         );
  end component;

  component fifo_async_generic
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
  end component;

  function bin_to_gray(din :std_logic_vector)
      return std_logic_vector;
      
end package;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;

package body free_fifo is

  function bin_to_gray(din :std_logic_vector)
      return std_logic_vector is
    variable dout :std_logic_vector(din'range);
  begin
    dout := din xor ("0" & din(din'high downto 1));
    return dout;
  end bin_to_gray;
  
end free_fifo;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;


entity fifo_async_xilinx is
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fpga_type  :integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          full_out	:out std_logic;
          empty_out	:out std_logic
         );
end fifo_async_xilinx;

architecture arch_fifo_async_xilinx of fifo_async_xilinx is
  signal full		:std_logic;
  signal empty		:std_logic;
  signal rd_allow	:std_logic;
  signal wr_allow	:std_logic;
  signal rd_addr	:std_logic_vector (addr_bits-1 downto 0);
  signal rd_addr_gray1	:std_logic_vector (addr_bits-1 downto 0);
  signal rd_addr_gray2	:std_logic_vector (addr_bits-1 downto 0);
  signal rd_addr_gray3	:std_logic_vector (addr_bits-1 downto 0);
  signal wr_addr	:std_logic_vector (addr_bits-1 downto 0);
  signal wr_addr_gray1	:std_logic_vector (addr_bits-1 downto 0);
  signal wr_addr_gray2	:std_logic_vector (addr_bits-1 downto 0);
  signal emptyg		:std_logic;
  signal almostemptyg	:std_logic;
  signal fullg		:std_logic;
  signal almostfullg	:std_logic;

  signal always_one   :std_logic;
  signal always_zero  :std_logic;
  
  -- MUXCY_L -- 2-to-1 Multiplexer for Carry Logic with Local Output
  -- Applies only to the Xilinx Virtex and Spartan-II FPGA's
  -- http://toolbox.xilinx.com/docsan/2_1i/data/common/lib/lib7_35.htm
  -- VHDL Equivalent:   LO <= DI when S='0' else CI;
  component MUXCY_L
     port (
        DI:  IN std_logic;
        CI:  IN std_logic;
        S:   IN std_logic;
        LO: OUT std_logic);
  END component;

  -- Note:  These signals are only used for the Xilinx version (fpga_type=1)
  signal ecomp		:std_logic_vector (addr_bits-1 downto 0);
  signal aecomp		:std_logic_vector (addr_bits-1 downto 0);
  signal fcomp		:std_logic_vector (addr_bits-1 downto 0);
  signal afcomp		:std_logic_vector (addr_bits-1 downto 0);
  signal emuxcyo	:std_logic_vector (addr_bits-1 downto 0);
  signal aemuxcyo	:std_logic_vector (addr_bits-1 downto 0);
  signal fmuxcyo	:std_logic_vector (addr_bits-1 downto 0);
  signal afmuxcyo	:std_logic_vector (addr_bits-1 downto 0);
  signal ecin		:std_logic;
  signal aecin		:std_logic;
  signal fcin		:std_logic;
  signal afcin		:std_logic;

begin
  always_one <= '1';
  always_zero <= '0';

  ---------------------------------------------------------------
  -- Generate the read/write allow signals
  ---------------------------------------------------------------
  rd_allow <= '1' when rd_en='1' and empty='0' else '0';
  wr_allow <= '1' when wr_en='1' and full='0' else '0';

  ---------------------------------------------------------------
  -- Instantiate the RAM
  ---------------------------------------------------------------
  fifo_ram: ram_dp
               generic map (addr_bits => addr_bits,
                            data_bits => data_bits,
                            register_out_flag => 1,
                            block_type => block_type)
               port map (reset,
                         wr_clk, wr_allow, wr_addr_gray2, wr_data,
                         rd_clk, rd_addr_gray2, rd_data);

  ---------------------------------------------------------------
  -- Generate the read addresses & pipelined gray-code versions  
  -- If you're reading along in the Xilinx XAPP174, here's the conversion chart:
  --   rd_addr_gray1 == read_nextgray
  --   rd_addr_gray2 == read_addrgray
  --   rd_addr_gray3 == read_lastgray
  --
  --  The addr and gray-code reset procedure has been designed
  --  to be more "dumb-proof" when parameterized.  The initial
  --  values are different than the Xilinx version.
  ---------------------------------------------------------------
  process (rd_clk, reset)
    variable addr	:std_logic_vector (rd_addr'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      rd_addr_gray3 <= bin_to_gray (addr);
      addr := addr + 1;
      rd_addr_gray2 <= bin_to_gray (addr);
      addr := addr + 1;
      rd_addr_gray1 <= bin_to_gray (addr);
      addr := addr + 1;
      rd_addr <= addr;
    elsif rd_clk'event and rd_clk='1' then
      if rd_allow='1' then
        rd_addr_gray3 <= rd_addr_gray2;
        rd_addr_gray2 <= rd_addr_gray1;
        rd_addr_gray1 <= bin_to_gray(rd_addr);
        rd_addr <= rd_addr + 1;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------
  --  Generate the write addresses & pipelined gray-code versions
  --    wr_addr_gray1 == write_nextgray
  --    wr_addr_gray2 == write_addrgray
  ---------------------------------------------------------------
  process (wr_clk, reset)
    variable addr	:std_logic_vector (rd_addr'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      --wr_addr_gray3 <= bin_to_gray (addr);  -- There isn't a wr_addr_gray3
      addr := addr + 1;
      wr_addr_gray2 <= bin_to_gray (addr);
      addr := addr + 1;
      wr_addr_gray1 <= bin_to_gray (addr);
      addr := addr + 1;
      wr_addr <= addr;
    elsif wr_clk'event and wr_clk='1' then
      if wr_allow='1' then
        wr_addr_gray2 <= wr_addr_gray1;
        wr_addr_gray1 <= bin_to_gray(wr_addr);
        wr_addr <= wr_addr + 1;
      end if;
    end if;
  end process;
  

  ---------------------------------------------------------------
  --  Generate Empty
  ---------------------------------------------------------------
  process (rd_clk, reset)
  begin
    if reset='1' then
      empty <= '1';
    elsif rd_clk'event and rd_clk='1' then
      if emptyg='1' or (almostemptyg='1' and rd_allow='1') then
        empty <= '1';
      else
        empty <= '0';
      end if;
    end if;
  end process;

  empty_out <= empty;

      
  ---------------------------------------------------------------
  --  Generate Full
  ---------------------------------------------------------------
  process (wr_clk, reset)
  begin
    if reset='1' then
      full <= '1';
    elsif wr_clk'event and wr_clk='1' then
      if fullg='1' or (almostfullg='1' and wr_allow='1') then
        full <= '1';
      else
        full <= '0';
      end if;
    end if;
  end process;

  full_out <= full;


  ---------------------------------------------------------------
  -- Generate the full, empty, almost full, and almost empty
  -- combinatorial flags
  ---------------------------------------------------------------
  UNDEFINED0: if fpga_type=0 generate
  begin
    emptyg       <= '1' when wr_addr_gray2=rd_addr_gray2 else '0';
    almostemptyg <= '1' when wr_addr_gray2=rd_addr_gray1 else '0';
    fullg        <= '1' when wr_addr_gray2=rd_addr_gray3 else '0';
    almostfullg  <= '1' when wr_addr_gray1=rd_addr_gray3 else '0';
  end generate UNDEFINED0;


  XILINX0: if fpga_type=1 generate
  begin
    ecomp  <= not (wr_addr_gray2 XOR rd_addr_gray2);
    aecomp <= not (wr_addr_gray2 XOR rd_addr_gray1);
    fcomp  <= not (wr_addr_gray2 XOR rd_addr_gray3);
    afcomp <= not (wr_addr_gray1 XOR rd_addr_gray3);

    EMUXCYi: MUXCY_L port map (DI=>always_one,  CI=>always_one, S=>always_one, LO=>ecin);
    EMUXCY0: MUXCY_L port map (DI=>always_zero, CI=>ecin,       S=>ecomp(0),   LO=>emuxcyo(0));
    EMUXCYa: for i in 0 to addr_bits-3 generate
    begin
      EMUXCYb: MUXCY_L port map (DI=>always_zero, CI=>emuxcyo(i), S=>ecomp(i+1), LO=>emuxcyo(i+1));
    end generate EMUXCYa;
    EMUXCYN: MUXCY_L port map (DI=>always_zero,CI=>emuxcyo(addr_bits-2),S=>ecomp(addr_bits-1),LO=>emptyg);

    AEMUXCYi: MUXCY_L port map (DI=>always_one,CI=>always_one,        S=>always_one,      LO=>aecin);
    AEMUXCY0: MUXCY_L port map (DI=>always_zero,CI=>aecin,      S=>aecomp(0),LO=>aemuxcyo(0));
    AEMUXCYa:  for i in 0 to addr_bits-3 generate
    begin
      AEMUXCYb: MUXCY_L port map (DI=>always_zero,CI=>aemuxcyo(i),S=>aecomp(i+1),LO=>aemuxcyo(i+1));
    end generate AEMUXCYa;
    AEMUXCYN: MUXCY_L port map (DI=>always_zero,CI=>aemuxcyo(addr_bits-2),S=>aecomp(addr_bits-1),LO=>almostemptyg);

    FMUXCYi: MUXCY_L port map (DI=>always_one,CI=>always_one,       S=>always_one,     LO=>fcin);
    FMUXCY0: MUXCY_L port map (DI=>always_zero,CI=>fcin,      S=>fcomp(0),LO=>fmuxcyo(0));
    FMUXCYa:  for i in 0 to addr_bits-3 generate
    begin
      FMUXCYb: MUXCY_L port map (DI=>always_zero,CI=>fmuxcyo(i),S=>fcomp(i+1),LO=>fmuxcyo(i+1));
    end generate FMUXCYa;
    FMUXCYn: MUXCY_L port map (DI=>always_zero,CI=>fmuxcyo(addr_bits-2),S=>fcomp(addr_bits-1),LO=>fullg);
    
    AFMUXCYi: MUXCY_L port map (DI=>always_one,CI=>always_one,        S=>always_one,      LO=>afcin);
    AFMUXCY0: MUXCY_L port map (DI=>always_zero,CI=>afcin,      S=>afcomp(0),LO=>afmuxcyo(0));
    AFMUXCYa: for i in 0 to addr_bits-3 generate
      AFMUXCYb:  MUXCY_L port map (DI=>always_zero,CI=>afmuxcyo(i),S=>afcomp(i+1),LO=>afmuxcyo(i+1));
    end generate AFMUXCYa;
    AFMUXCYn: MUXCY_L port map (DI=>always_zero,CI=>afmuxcyo(addr_bits-2),S=>afcomp(addr_bits-1),LO=>almostfullg);
    
  end generate XILINX0;

end arch_fifo_async_xilinx;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;


entity fifo_async_generic is
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0);
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_async_generic;

architecture arch_fifo_async_generic of fifo_async_generic is
  signal rd_allow	:std_logic;
  signal wr_allow	:std_logic;
  signal rd_addr	:std_logic_vector (addr_bits-1 downto 0);
  signal rd_addr_gray1	:std_logic_vector (addr_bits-1 downto 0);
  signal wr_addr	:std_logic_vector (addr_bits-1 downto 0);
  signal wr_addr_gray1	:std_logic_vector (addr_bits-1 downto 0);
  signal wr_addr_gray2	:std_logic_vector (addr_bits-1 downto 0);

  signal empty_match	:std_logic;
  signal full_match	:std_logic;
  signal empty_int	:std_logic;
  signal full_int	:std_logic;

  signal always_one   :std_logic;
  signal always_zero  :std_logic;
  
begin
  always_one <= '1';
  always_zero <= '0';

  ---------------------------------------------------------------
  -- Generate the read/write allow signals
  ---------------------------------------------------------------
  rd_allow <= '1' when rd_en='1' and empty_int='0' else '0';
  wr_allow <= '1' when wr_en='1' and full_int='0' else '0';

  ---------------------------------------------------------------
  -- Instantiate the RAM
  ---------------------------------------------------------------
  fifo_ram: ram_dp
               generic map (addr_bits => addr_bits,
                            data_bits => data_bits,
                            register_out_flag => 1,
                            block_type => block_type)
               port map (reset,
                         wr_clk, wr_allow, wr_addr_gray2, wr_data,
                         rd_clk, rd_addr_gray1, rd_data);

  ---------------------------------------------------------------
  -- Generate the read addresses & pipelined gray-code versions  
  ---------------------------------------------------------------
  process (rd_clk, reset)
    variable addr	:std_logic_vector (rd_addr'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      rd_addr_gray1 <= bin_to_gray (addr);
      addr := addr + 1;
      rd_addr <= addr;
    elsif rd_clk'event and rd_clk='1' then
      if rd_allow='1' then
        rd_addr_gray1 <= bin_to_gray(rd_addr);
        rd_addr <= rd_addr + 1;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------
  --  Generate the write addresses & pipelined gray-code versions
  ---------------------------------------------------------------
  process (wr_clk, reset)
    variable addr	:std_logic_vector (wr_addr'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      wr_addr_gray2 <= bin_to_gray (addr);
      addr := addr + 1;
      wr_addr_gray1 <= bin_to_gray (addr);
      addr := addr + 1;
      wr_addr <= addr;
    elsif wr_clk'event and wr_clk='1' then
      if wr_allow='1' then
        wr_addr_gray2 <= wr_addr_gray1;
        wr_addr_gray1 <= bin_to_gray(wr_addr);
        wr_addr <= wr_addr + 1;
      end if;
    end if;
  end process;
  
  ---------------------------------------------------------------
  -- Generate Empty & Full
  ---------------------------------------------------------------
  empty_match <= '1' when rd_addr_gray1=wr_addr_gray2 else '0';
  full_match  <= '1' when rd_addr_gray1=wr_addr_gray1 else '0';

  process (rd_clk, empty_match)
  begin
    if empty_match='1' then
      empty_int <= '1';
    elsif rd_clk'event and rd_clk='1' then
      empty_int <= empty_match;
    end if;
  end process;

  process (wr_clk, full_match)
  begin
    if full_match='1' then
      full_int <= '1';
    elsif wr_clk'event and wr_clk='1' then
      full_int <= full_match;
    end if;
  end process;

  empty <= empty_int;
  full <= full_int;

end arch_fifo_async_generic;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;


entity fifo_async is
    generic (data_bits	:integer;
             addr_bits 	:integer;
             block_type	:integer := 0;
             fifo_arch  :integer := 0); -- 0=Generic architecture, 1=Xilinx, 2=Xilinx w/carry
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_async;


architecture arch_fifo_async of fifo_async is
begin
  -- Generic FIFO
  UNSPECIFIED0: if fifo_arch=0 generate
  begin
    U1: fifo_async_generic
        generic map (data_bits, addr_bits, block_type)
        port map (reset, wr_clk, wr_en, wr_data, rd_clk, rd_en, rd_data, full, empty);        
  end generate UNSPECIFIED0;

  -- Xilinx XAPP175 without carry logic
  XILINX0: if fifo_arch=1 generate
  begin
    U2: fifo_async_xilinx
        generic map (data_bits, addr_bits, block_type, 0)
        port map (reset, wr_clk, wr_en, wr_data, rd_clk, rd_en, rd_data, full, empty);
  end generate XILINX0;

  -- Xilinx XAPP175 with carry logic
  XILINX1: if fifo_arch=2 generate
  begin
    U3: fifo_async_xilinx
        generic map (data_bits, addr_bits, block_type, 1)
        port map (reset, wr_clk, wr_en, wr_data, rd_clk, rd_en, rd_data, full, empty);
  end generate XILINX1;

end arch_fifo_async;




----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;

entity fifo_sync is
    generic (data_bits  :integer;
             addr_bits  :integer;
             block_type :integer := 0);
    port (reset		:in std_logic;
          clk		:in std_logic;
          wr_en		:in std_logic;
          wr_data	:in std_logic_vector (data_bits-1 downto 0);
          rd_en		:in std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_sync;


architecture arch_fifo_sync of fifo_sync is
  signal wr_addr	:std_logic_vector (addr_bits-1 downto 0);
  signal rd_addr	:std_logic_vector (addr_bits-1 downto 0);
  signal rd_allow	:std_logic;
  signal wr_allow	:std_logic;
  signal count_int	:std_logic_vector (addr_bits-1 downto 0);
  signal empty_int	:std_logic;
  signal full_int	:std_logic;

  signal empty_count	:std_logic_vector (addr_bits-1 downto 0);
  signal aempty_count	:std_logic_vector (addr_bits-1 downto 0);
  signal full_count	:std_logic_vector (addr_bits-1 downto 0);
  signal afull_count	:std_logic_vector (addr_bits-1 downto 0);
  
begin
  count <= count_int;
  full <= full_int;
  empty <= empty_int;

  -- Some constants
  empty_count <= (others=>'0');
  aempty_count <= empty_count + 1;  
  full_count <= (others=>'1');
  afull_count <= full_count - 1;

  ----------------------------------------------
  ----------------------------------------------
  rd_allow <= '1' when rd_en='1' and empty_int='0' else '0';
  wr_allow <= '1' when wr_en='1' and full_int='0' else '0';

  ----------------------------------------------
  ----------------------------------------------
  fifo_ram: ram_dp
      generic map (addr_bits => addr_bits,
                   data_bits => data_bits,
                   register_out_flag => 1,
                   block_type => block_type)
      port map (reset,
                clk, wr_allow, wr_addr, wr_data,
                clk, rd_addr, rd_data);

  ----------------------------------------------
  ----------------------------------------------
  process (clk, reset)
  begin
    if reset='1' then
      rd_addr <= (others=>'0');
    elsif clk'event and clk='1' then
      if rd_allow='1' then
        rd_addr <= rd_addr + 1;
      end if;
    end if;
  end process;

  
  ----------------------------------------------
  ----------------------------------------------
  process (clk, reset)
  begin
    if reset='1' then
      wr_addr <= (others=>'0');
    elsif clk'event and clk='1' then
      if wr_allow='1' then
        wr_addr <= wr_addr + 1;
      end if;
    end if;
  end process;


  ----------------------------------------------
  ----------------------------------------------
  process (clk, reset)
  begin
    if reset='1' then
      count_int <= (others=>'0');
    elsif clk'event and clk='1' then
      if wr_allow='0' and rd_allow='1' then
        count_int <= count_int-1;
      elsif wr_allow='1' and rd_allow='0' then
        count_int <= count_int+1;
      end if; -- else count<=count        
    end if;
  end process;

  ----------------------------------------------
  ----------------------------------------------
  process (clk, reset)
  begin
    if reset='1' then
      empty_int <= '1';
    elsif clk'event and clk='1' then
      if empty_int='1' and wr_allow='1' then
        empty_int <= '0';
      elsif count_int=aempty_count and rd_allow='1' and wr_allow='0' then
        empty_int <= '1';
      elsif count_int=empty_count then
        empty_int <= '1';
      else
        empty_int <= '0';
      end if;
    end if;
  end process;


  ----------------------------------------------
  ----------------------------------------------
  process (clk, reset)
  begin
    if reset='1' then
      full_int <= '0';
    elsif clk'event and clk='1' then
      if full_int='1' and rd_allow='1' then
        full_int <= '0';
      elsif count_int=afull_count and rd_allow='0' and wr_allow='1' then
        full_int <= '1';
      elsif count_int=full_count then
        full_int <= '1';
      else
        full_int <= '0';
      end if;
    end if;
  end process;

end arch_fifo_sync;




----------------------------------------------------------------------------
--  This is basically a test model.  It shows that the wrcount and rdcount
--  FIFO's are really made up of two seperate FIFO's.  But since the *_orig
--  FIFO's are slightly different than the "normal" ones, they are not
--  "pin" compatible.   The *_orig FIFO's are included here as reference
--  and "prior art".
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;


entity fifo_wrcount_orig is
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fifo_arch  :integer := 0); -- 0=Generic architecture, 1=Xilinx, 2=Xilinx w/carry
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_wrcount_orig;

architecture arch_fifo_wrcount_orig of fifo_wrcount_orig is
  signal i_rd_en	:std_logic;
  signal i_rd_en2	:std_logic;
  signal i_wr_en	:std_logic;
  signal i_data1	:std_logic_vector (data_bits-1 downto 0);
  signal i_data2	:std_logic_vector (data_bits-1 downto 0);
  signal i_data3	:std_logic_vector (data_bits-1 downto 0);
  signal i_count	:std_logic_vector (addr_bits-1 downto 0);
  signal i_full1	:std_logic;
  signal i_empty1	:std_logic;
  signal i_full2	:std_logic;
  signal i_empty2	:std_logic;
  signal temp_valid	:std_logic;
  signal count_max 	:std_logic_vector (addr_bits-1 downto 0);

begin
  count_max <= (others=>'1');
  
  -- Misc signals
  full <= i_full1;
  empty <= i_empty2;
  count <= count_max - i_count;

  -- The Input FIFO
  U1: fifo_sync
        generic map (data_bits, addr_bits, block_type)
        port map (reset, wr_clk, wr_en, wr_data,
                  i_rd_en, i_data1, i_count, i_full1, i_empty1);

  -- The output FIFO
  U2: fifo_async
        generic map (data_bits, addr_bits, block_type, fifo_arch)
        port map (reset,
                  wr_clk, i_wr_en, i_data3,
                  rd_clk, rd_en, rd_data, i_full2, i_empty2);
                  

  -- Generate the read enables
  i_rd_en <= '1' when i_empty1='0' and i_full2='0' else '0';

  process (reset, wr_clk)
  begin
    if reset='1' then
      i_rd_en2 <= '0';
    elsif wr_clk'event and wr_clk='1' then
      i_rd_en2 <= i_rd_en;
    end if;
  end process;

  -- Latch the data into a temp buffer if the read FIFO is full
  process (reset, wr_clk)
  begin
    if reset='1' then
      i_data2 <= (others=>'0');
    elsif wr_clk'event and wr_clk='1' then
      if i_full2='1' and i_rd_en2='1' then
        i_data2 <= i_data1;
      end if;
    end if;
  end process;

  -- Track if the temp buffer is being used
  process (reset, wr_clk)
  begin
    if reset='1' then
      temp_valid<='0';
    elsif wr_clk'event and wr_clk='1' then
      if i_full2='1' and i_rd_en2='1' then
        temp_valid <= '1';
      elsif i_full2='0' then
        temp_valid <= '0';
      end if;
    end if;
  end process;
  

  -- Generate the write enable signal
  i_wr_en <= '1' when temp_valid='1' else
             '1' when i_rd_en2='1'   else
             '0';
        
  -- Generate the input data to the read fifo
  i_data3 <= i_data1 when temp_valid='0' else i_data2;


end arch_fifo_wrcount_orig;


----------------------------------------------------------------------------
--  This is basically a test model.  It shows that the wrcount and rdcount
--  FIFO's are really made up of two seperate FIFO's.  But since the *_orig
--  FIFO's are slightly different than the "normal" ones, they are not
--  "pin" compatible.   The *_orig FIFO's are included here as reference
--  and "prior art".
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;


entity fifo_rdcount_orig is
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             fifo_arch  :integer := 0); -- 0=Generic architecture, 1=Xilinx, 2=Xilinx w/carry
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_rdcount_orig;

architecture arch_fifo_rdcount_orig of fifo_rdcount_orig is
  signal i_rd_en	:std_logic;
  signal i_rd_en2	:std_logic;
  signal i_wr_en	:std_logic;
  signal i_data1	:std_logic_vector (data_bits-1 downto 0);
  signal i_data2	:std_logic_vector (data_bits-1 downto 0);
  signal i_data3	:std_logic_vector (data_bits-1 downto 0);
  signal i_count	:std_logic_vector (addr_bits-1 downto 0);
  signal i_full1	:std_logic;
  signal i_empty1	:std_logic;
  signal i_full2	:std_logic;
  signal i_empty2	:std_logic;
  signal temp_valid	:std_logic;

begin
  -- Misc signals
  full <= i_full1;
  empty <= i_empty2;
  count <= i_count;

  -- The Input FIFO
  U1: fifo_async
        generic map (data_bits, addr_bits, block_type, fifo_arch)
        port map (reset,
                  wr_clk, wr_en, wr_data,
                  rd_clk, i_rd_en, i_data1, i_full1, i_empty1);
                  

  -- The output FIFO
  U2: fifo_sync
        generic map (data_bits, addr_bits, block_type)
        port map(reset, rd_clk, i_wr_en, i_data3,
                 rd_en, rd_data, i_count, i_full2, i_empty2);
                
  -- Generate the read enables
  i_rd_en <= '1' when i_empty1='0' and i_full2='0' else '0';

  process (reset, rd_clk)
  begin
    if reset='1' then
      i_rd_en2 <= '0';
    elsif rd_clk'event and rd_clk='1' then
      i_rd_en2 <= i_rd_en;
    end if;
  end process;

  -- Latch the data into a temp buffer if the read FIFO is full
  process (reset, rd_clk)
  begin
    if reset='1' then
      i_data2 <= (others=>'0');
    elsif rd_clk'event and rd_clk='1' then
      if i_full2='1' and i_rd_en2='1' then
        i_data2 <= i_data1;
      end if;
    end if;
  end process;

  -- Track if the temp buffer is being used
  process (reset, rd_clk)
  begin
    if reset='1' then
      temp_valid<='0';
    elsif rd_clk'event and rd_clk='1' then
      if i_full2='1' and i_rd_en2='1' then
        temp_valid <= '1';
      elsif i_full2='0' then
        temp_valid <= '0';
      end if;
    end if;
  end process;
  

  -- Generate the write enable signal
  i_wr_en <= '1' when temp_valid='1' else
             '1' when i_rd_en2='1'   else
             '0';
        
  -- Generate the input data to the read fifo
  i_data3 <= i_data1 when temp_valid='0' else i_data2;


end arch_fifo_rdcount_orig;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;


entity fifo_wrcount is
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             async_size :integer := 16); 
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_wrcount;

architecture arch_fifo_wrcount of fifo_wrcount is
  signal wrptr_bin	:std_logic_vector (addr_bits-1 downto 0);
  signal wrptr		:std_logic_vector (addr_bits-1 downto 0);
  signal wrptr1		:std_logic_vector (addr_bits-1 downto 0);

  signal rdptr_bin	:std_logic_vector (addr_bits-1 downto 0);
  signal rdptr		:std_logic_vector (addr_bits-1 downto 0);
  signal rdptr_max	:std_logic_vector (addr_bits-1 downto 0);
  signal rdptr_max_bin	:std_logic_vector (addr_bits-1 downto 0);

  signal midptr_bin	:std_logic_vector (addr_bits-1 downto 0);
  signal midptr 	:std_logic_vector (addr_bits-1 downto 0);
  signal midptr1	:std_logic_vector (addr_bits-1 downto 0);

  signal wf_count	:std_logic_vector (addr_bits-1 downto 0);
  
  signal wf_full_match	:std_logic;
  signal wf_empty_match	:std_logic;
  signal wf_aempty_match:std_logic;
  signal rf_full_match	:std_logic;
  signal rf_empty_match	:std_logic;

  signal wf_full_int	:std_logic;
  signal wf_empty_int	:std_logic;
  signal rf_full_int	:std_logic;
  signal rf_empty_int	:std_logic;
  
  signal rd_allow	:std_logic;
  signal wr_allow	:std_logic;
  signal mid_allow	:std_logic;

begin
  empty <= rf_empty_int;
  full <= wf_full_int;
  count <= wf_count;

  ---------------------------------------------------------------
  -- Generate the read/write allow signals
  ---------------------------------------------------------------
  rd_allow <= '1' when rd_en='1' and rf_empty_int='0' else '0';
  wr_allow <= '1' when wr_en='1' and wf_full_int='0' else '0';
  mid_allow <= '1' when wf_empty_int='0' and rf_full_int='0' else '0';

  ---------------------------------------------------------------
  -- Instantiate the RAM
  ---------------------------------------------------------------
  fifo_ram: ram_dp
               generic map (addr_bits => addr_bits,
                            data_bits => data_bits,
                            register_out_flag => 1,
                            block_type => block_type)
               port map (reset,
                         wr_clk, wr_allow, wrptr, wr_data,
                         rd_clk, rdptr, rd_data);

  ---------------------------------------------------------------
  --  Generate the write addresses
  ---------------------------------------------------------------
  process (wr_clk, reset)
    variable addr	:std_logic_vector (wrptr_bin'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      wrptr <= bin_to_gray (addr);
      addr := addr + 1;
      wrptr1 <= bin_to_gray (addr);
      addr := addr + 1;
      wrptr_bin <= addr;
    elsif wr_clk'event and wr_clk='1' then
      if wr_allow='1' then
        wrptr     <= wrptr1;
        wrptr1    <= bin_to_gray (wrptr_bin);
        wrptr_bin <= wrptr_bin + 1;
      end if;
    end if;
  end process;

  
  ---------------------------------------------------------------
  --  Generate the read addresses
  ---------------------------------------------------------------
  process (rd_clk, reset)
    variable addr	:std_logic_vector (wrptr_bin'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      rdptr <= bin_to_gray (addr);     
      addr := addr + 1;
      rdptr_bin <= addr;

      addr := addr + async_size;
      rdptr_max_bin <= addr;
      addr := addr - 1;
      rdptr_max <= bin_to_gray(addr);
      
    elsif rd_clk'event and rd_clk='1' then
      if rd_allow='1' then
        rdptr    <= bin_to_gray (rdptr_bin);
        rdptr_bin <= rdptr_bin + 1;

        rdptr_max <= bin_to_gray (rdptr_max_bin);
        rdptr_max_bin <= rdptr_max_bin + 1;
      end if;
    end if;
  end process;


  ---------------------------------------------------------------
  --  Generate the mid addresses
  ---------------------------------------------------------------
  process (wr_clk, reset)
    variable addr	:std_logic_vector (wrptr_bin'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      midptr <= bin_to_gray (addr);
      addr := addr + 1;
      midptr1 <= bin_to_gray (addr);
      addr := addr + 1;
      midptr_bin <= addr;
    elsif wr_clk'event and wr_clk='1' then
      if mid_allow='1' then
        midptr     <= midptr1;
        midptr1    <= bin_to_gray (midptr_bin);
        midptr_bin <= midptr_bin + 1;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------
  -- Calculate all the combinatorial match signals
  ---------------------------------------------------------------
  wf_full_match	  <= '1' when wrptr1  = rdptr     else '0';
  wf_empty_match  <= '1' when wrptr   = midptr    else '0';  -- synced to wr_clk!
  wf_aempty_match <= '1' when wrptr   = midptr1   else '0';  -- synced to wr_clk!
  rf_full_match   <= '1' when midptr1 = rdptr_max else '0';
  rf_empty_match  <= '1' when rdptr   = midptr    else '0';


  ---------------------------------------------------------------
  -- Generate the full/empty flags
  ---------------------------------------------------------------
  --wf_empty_int <= wf_empty_match; -- The small but slow way

  process (wr_clk, reset)  -- The large but fast way
  begin
    if reset='1' then
      wf_empty_int <= '1';
    elsif wr_clk'event and wr_clk='1' then
      if wf_aempty_match='1' and wr_allow='0' and mid_allow='1' then
        wf_empty_int <= '1';
      elsif wf_empty_match='1' and wr_allow='0' then
        wf_empty_int <= '1';
      else
        wf_empty_int <= '0';
      end if;
    end if;
  end process;


  process (rd_clk, rf_empty_match)
  begin
    if rf_empty_match='1' then
      rf_empty_int <= '1';
    elsif rd_clk'event and rd_clk='1' then
      rf_empty_int <= rf_empty_match;
    end if;
  end process;

  --  This version matches the count output, but can result in a
  --  couple of unused memory locations.
  process (wr_clk, reset)
    variable tmp1 :std_logic_vector (count'range);
    variable tmp2 :std_logic_vector (count'range);
  begin
    if reset='1' then
      wf_full_int <= '0';
    elsif wr_clk'event and wr_clk='1' then
      tmp1 := (others=>'0');
      tmp2 := tmp1 + 1;

      if wf_full_int='1' and mid_allow='1' then
        wf_full_int <= '0';      
      elsif wf_count=tmp2 and wr_allow='1' and mid_allow='0' then
        wf_full_int <= '1';
      elsif wf_count=tmp1 then
        wf_full_int <= '1';
      else
        wf_full_int <= '0';      
      end if;
    end if;
  end process;


  process (wr_clk, rf_full_match)
  begin
    if rf_full_match='1' then
      rf_full_int <= '1';
    elsif wr_clk'event and wr_clk='1' then
      rf_full_int <= rf_full_match;
    end if;
  end process;

  ---------------------------------------------------------------
  -- Keep a count of the number of empty entries in the write FIFO
  ---------------------------------------------------------------
  process (wr_clk, reset)
    variable addr :std_logic_vector (wrptr'range);
  begin
    if reset='1' then
      addr := (others=>'1');
      addr := addr - async_size;
      addr := addr + 1;
      wf_count <= addr;
    elsif wr_clk='1' and wr_clk'event then
      if wr_allow='1' and mid_allow='0' then
        wf_count <= wf_count - 1;
      elsif wr_allow='0' and mid_allow='1' then
        wf_count <= wf_count + 1;
      end if;
    end if;
  end process;

end arch_fifo_wrcount;




----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.free_fifo.all;
use work.ram_lib.all;


entity fifo_rdcount is
    generic (data_bits	:integer;
             addr_bits  :integer;
             block_type	:integer := 0;
             async_size :integer := 16); 
    port (reset		:in  std_logic;
          wr_clk	:in  std_logic;
          wr_en		:in  std_logic;
          wr_data	:in  std_logic_vector (data_bits-1 downto 0);
          rd_clk	:in  std_logic;
          rd_en		:in  std_logic;
          rd_data	:out std_logic_vector (data_bits-1 downto 0);
          count		:out std_logic_vector (addr_bits-1 downto 0);
          full		:out std_logic;
          empty		:out std_logic
         );
end fifo_rdcount;

architecture arch_fifo_rdcount of fifo_rdcount is
  signal wrptr_bin	:std_logic_vector (addr_bits-1 downto 0);
  signal wrptr		:std_logic_vector (addr_bits-1 downto 0);
  signal wrptr1		:std_logic_vector (addr_bits-1 downto 0);

  signal rdptr_bin	:std_logic_vector (addr_bits-1 downto 0);
  signal rdptr1		:std_logic_vector (addr_bits-1 downto 0);
  signal rdptr		:std_logic_vector (addr_bits-1 downto 0);

  signal midptr_bin	:std_logic_vector (addr_bits-1 downto 0);
  signal midptr 	:std_logic_vector (addr_bits-1 downto 0);
  signal midptr1	:std_logic_vector (addr_bits-1 downto 0);

  signal rf_count	:std_logic_vector (addr_bits-1 downto 0);
  
  signal wf_full_match	:std_logic;
  signal wf_empty_match	:std_logic;
  signal rf_empty_match	:std_logic;
  signal rf_aempty_match:std_logic;

  signal wf_full_int	:std_logic;
  signal wf_empty_int	:std_logic;
  signal rf_empty_int	:std_logic;
  
  signal rd_allow	:std_logic;
  signal wr_allow	:std_logic;
  signal mid_allow	:std_logic;

begin
  empty <= rf_empty_int;
  full <= wf_full_int;
  count <= rf_count;

  ---------------------------------------------------------------
  -- Generate the read/write allow signals
  ---------------------------------------------------------------
  rd_allow <= '1' when rd_en='1' and rf_empty_int='0' else '0';
  wr_allow <= '1' when wr_en='1' and wf_full_int='0' else '0';
  mid_allow <= '1' when wf_empty_int='0' else '0';

  ---------------------------------------------------------------
  -- Instantiate the RAM
  ---------------------------------------------------------------
  fifo_ram: ram_dp
               generic map (addr_bits => addr_bits,
                            data_bits => data_bits,
                            register_out_flag => 1,
                            block_type => block_type)
               port map (reset,
                         wr_clk, wr_allow, wrptr, wr_data,
                         rd_clk, rdptr, rd_data);

  ---------------------------------------------------------------
  --  Generate the write addresses
  ---------------------------------------------------------------
  process (wr_clk, reset)
    variable addr	:std_logic_vector (wrptr_bin'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      wrptr <= bin_to_gray (addr);
      addr := addr + 1;
      wrptr1 <= bin_to_gray (addr);
      addr := addr + 1;
      wrptr_bin <= addr;
    elsif wr_clk'event and wr_clk='1' then
      if wr_allow='1' then
        wrptr     <= wrptr1;
        wrptr1    <= bin_to_gray (wrptr_bin);
        wrptr_bin <= wrptr_bin + 1;
      end if;
    end if;
  end process;

  
  ---------------------------------------------------------------
  --  Generate the read addresses
  ---------------------------------------------------------------
  process (rd_clk, reset)
    variable addr	:std_logic_vector (wrptr_bin'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      rdptr <= bin_to_gray (addr);     
      addr := addr + 1;
      rdptr1 <= bin_to_gray (addr);     
      addr := addr + 1;
      rdptr_bin <= addr;     
    elsif rd_clk'event and rd_clk='1' then
      if rd_allow='1' then
        rdptr     <= rdptr1;
        rdptr1    <= bin_to_gray (rdptr_bin);
        rdptr_bin <= rdptr_bin + 1;
      end if;
    end if;
  end process;


  ---------------------------------------------------------------
  --  Generate the mid addresses
  ---------------------------------------------------------------
  process (rd_clk, reset)
    variable addr	:std_logic_vector (wrptr_bin'range);
  begin
    if reset='1' then
      addr := (others=>'0');
      midptr <= bin_to_gray (addr);
      addr := addr + 1;
      midptr_bin <= addr;
    elsif rd_clk'event and rd_clk='1' then
      if mid_allow='1' then
        midptr     <= bin_to_gray (midptr_bin);
        midptr_bin <= midptr_bin + 1;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------
  -- Calculate all the match signals and full/empty flags
  ---------------------------------------------------------------
  wf_full_match	  <= '1' when wrptr1 = rdptr  else '0';
  wf_empty_match  <= '1' when wrptr  = midptr else '0';
  rf_empty_match  <= '1' when rdptr  = midptr else '0';  -- synced to rd_clk!
  rf_aempty_match <= '1' when rdptr1 = midptr else '0';  -- synced to rd_clk!


  ---------------------------------------------------------------
  -- Generate the full/empty flags
  ---------------------------------------------------------------
  --rf_empty_int <= rf_empty_match;  -- The slow, but small approach

  process (rd_clk, reset) -- The large, but fast approach
  begin
    if reset='1' then
      rf_empty_int <= '1';
    elsif rd_clk'event and rd_clk='1' then
      if rf_aempty_match='1' and rd_allow='1' and mid_allow='0' then
        rf_empty_int <= '1';
      elsif rf_empty_match='1' and mid_allow='0' then
        rf_empty_int <= '1';
      else
        rf_empty_int <= '0';
      end if;
    end if;
  end process;
    

  process (wr_clk, wf_full_match)
  begin
    if wf_full_match='1' then
      wf_full_int <= '1';
    elsif wr_clk'event and wr_clk='1' then
      wf_full_int <= wf_full_match;
    end if;
  end process;

  process (rd_clk, wf_empty_match)
  begin
    if wf_empty_match='1' then
      wf_empty_int <= '1';
    elsif rd_clk'event and rd_clk='1' then
      wf_empty_int <= wf_empty_match;
    end if;
  end process;

  ---------------------------------------------------------------
  -- Keep a count of the number of empty entries in the read FIFO
  ---------------------------------------------------------------
  process (rd_clk, reset)
  begin
    if reset='1' then
      rf_count <= (others=>'0');
    elsif rd_clk='1' and rd_clk'event then
      if rd_allow='1' and mid_allow='0' then
        rf_count <= rf_count - 1;
      elsif rd_allow='0' and mid_allow='1' then
        rf_count <= rf_count + 1;
      end if;
    end if;
  end process;

end arch_fifo_rdcount;



