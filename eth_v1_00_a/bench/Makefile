tmp/.done.%.vhd. : ../hdl/vhdl/%.vhd
	ncvhdl -v93 $<
	@touch $@

tmp/.done.%.vhd. : %.vhd
	ncvhdl -v93 $<
	@touch $@

all: elab

#cores/topmodules
RTL_SRC3 = eth.vhd
RTL_SRC2 = ethtx_core.vhd ethrx_core.vhd
#tx components
RTL_SRC1 = ethtx_byte_to_mii.vhd ethtx_clk_sampler.vhd
RTL_SRC1+= ethtx_regfile.vhd ethtx_statemachine.vhd 
RTL_SRC1+= ethtx_word_to_byte.vhd
#rx components
RTL_SRC1+= ethrx_clk_sampler.vhd ethrx_mii_to_byte.vhd 
RTL_SRC1+= ethrx_byte_to_word.vhd ethrx_statemachine.vhd
RTL_SRC1+= ethrx_debug.vhd ethrx_regfile.vhd
#building blocks
RTL_SRC0 = blockram_dp.vhd blockram_fifo.vhd crc.vhd fdre.vhd ramlib_sim.vhd freefifo.vhd

RTL_SRC = $(RTL_SRC0) $(RTL_SRC1) $(RTL_SRC2) $(RTL_SRC3)
RTL_TRG: $(RTL_SRC:%.vhd=tmp/.done.%.vhd.)


BENCH_ENTITY=bench_eth
BENCH_ARCH=sim
BENCH=$(BENCH_ENTITY):$(BENCH_ARCH)

SIM_SRC = tb_debug_functions.vhd tb_opb_packet_loopback.vhd tb_mii_receiver_model.vhd $(BENCH_ENTITY).vhd
SIM_TRG: $(SIM_SRC:%.vhd=tmp/.done.%.vhd.) RTL_TRG

vcom:
	vcom $(RTL_SRC:%.vhd=../hdl/vhdl/%.vhd) $(SIM_SRC)

vsim: vcom
	vsim -do "run 500 us" $(BENCH_ENTITY)

tmp/.done.elab.: SIM_TRG
	ncelab -v93 $(BENCH)
	touch tmp/.done.elab.

elab: tmp/.done.elab.

sim: elab
	ncsim -gui $(BENCH)

simrun: elab
	ncsim -run -exit $(BENCH)

cleaner:
	rm -rf -- tmp work worklib

clean: cleaner
	mkdir tmp
	mkdir worklib
	vlib work
