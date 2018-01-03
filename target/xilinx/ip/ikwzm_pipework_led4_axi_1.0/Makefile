
TOP=../../../..
COPY=cp

TARGET= src/led4_axi.vhd \
        src/led_csr.vhd  \
        src/pipework.vhd \
	$(ENDLIST)

src : $(TARGET)

src/led4_axi.vhd : $(TOP)/src/main/vhdl/led4_axi.vhd
	$(COPY) $< $@

src/led_csr.vhd  : $(TOP)/src/main/vhdl/led_csr.vhd
	$(COPY) $< $@

src/pipework.vhd : $(TOP)/PipeWork/src/components/components.vhd
	$(TOP)/PipeWork/tools/vhdl-archiver.rb \
	--library Work                         \
	--top LED4_AXI                         \
	$(TOP)/src/main/vhdl                   \
	--library PipeWork                     \
	--use "QUEUE_ARBITER(INTEGER_ARCH)"    \
	--archive $@                           \
	$(TOP)/PipeWork/src                    \
	$(ENDLIST)

