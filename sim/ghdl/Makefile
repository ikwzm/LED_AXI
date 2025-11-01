
DUMMY_PLUG_WORK_PATH = ../../Dummy_Plug/sim/ghdl-0.35/dummy_plug
PIPEWORK_WORK_PATH   = ../../PipeWork/sim/ghdl-0.35
SRC_PATH             = ../../src

GHDL       = ghdl
GHDLFLAGS  = --mb-comments -P$(DUMMY_PLUG_WORK_PATH) -P$(PIPEWORK_WORK_PATH)

DUT_COMPONENTS = led_csr    \
                 led4_axi   \

TEST_BENCH     = led4_axi_test_bench \
                 $(END_LIST)

all: DUT $(TEST_BENCH)

clean:
	rm -f *.o *.cf $(TEST_BENCH)

$(TEST_BENCH) : $(addsuffix .o,$(TEST_BENCH)) led4_axi_test.snr
	 $(GHDL) -e $(GHDLFLAGS) --work=WORK $@
	-$(GHDL) -r $(GHDLFLAGS) --work=WORK $@

DUT : $(addsuffix .o,$(DUT_COMPONENTS))

led_csr.o               : $(SRC_PATH)/main/vhdl/led_csr.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=WORK $<

led4_axi.o              : $(SRC_PATH)/main/vhdl/led4_axi.vhd
	 $(GHDL) -a $(GHDLFLAGS) --work=WORK $<

led4_axi_test_bench.o   : $(SRC_PATH)/test/vhdl/led4_axi_test_bench.vhd led4_axi.o
	 $(GHDL) -a $(GHDLFLAGS) --work=WORK $<

led4_axi_test.snr       : $(SRC_PATH)/test/scenarios/led4_axi_test.snr
	cp $(SRC_PATH)/test/scenarios/led4_axi_test.snr led4_axi_test.snr

