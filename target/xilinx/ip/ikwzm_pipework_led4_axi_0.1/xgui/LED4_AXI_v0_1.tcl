# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0 [ipgui::add_page $IPINST -name "Page 0" -layout vertical]
	set Component_Name [ipgui::add_param $IPINST -parent $Page0 -name Component_Name]
	set DEFAULT_SEQ_LAST [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_LAST]
	set DEFAULT_SEQ_5 [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_5]
	set DEFAULT_SEQ_4 [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_4]
	set DEFAULT_SEQ_3 [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_3]
	set DEFAULT_SEQ_2 [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_2]
	set DEFAULT_SEQ_1 [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_1]
	set DEFAULT_SEQ_0 [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_SEQ_0]
	set DEFAULT_TIMER [ipgui::add_param $IPINST -parent $Page0 -name DEFAULT_TIMER]
	set AUTO_START [ipgui::add_param $IPINST -parent $Page0 -name AUTO_START]
	set C_ID_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_ID_WIDTH]
	set C_DATA_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_DATA_WIDTH]
	set C_ADDR_WIDTH [ipgui::add_param $IPINST -parent $Page0 -name C_ADDR_WIDTH]
}

proc update_PARAM_VALUE.DEFAULT_SEQ_LAST { PARAM_VALUE.DEFAULT_SEQ_LAST } {
	# Procedure called to update DEFAULT_SEQ_LAST when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_LAST { PARAM_VALUE.DEFAULT_SEQ_LAST } {
	# Procedure called to validate DEFAULT_SEQ_LAST
	return true
}

proc update_PARAM_VALUE.DEFAULT_SEQ_5 { PARAM_VALUE.DEFAULT_SEQ_5 } {
	# Procedure called to update DEFAULT_SEQ_5 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_5 { PARAM_VALUE.DEFAULT_SEQ_5 } {
	# Procedure called to validate DEFAULT_SEQ_5
	return true
}

proc update_PARAM_VALUE.DEFAULT_SEQ_4 { PARAM_VALUE.DEFAULT_SEQ_4 } {
	# Procedure called to update DEFAULT_SEQ_4 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_4 { PARAM_VALUE.DEFAULT_SEQ_4 } {
	# Procedure called to validate DEFAULT_SEQ_4
	return true
}

proc update_PARAM_VALUE.DEFAULT_SEQ_3 { PARAM_VALUE.DEFAULT_SEQ_3 } {
	# Procedure called to update DEFAULT_SEQ_3 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_3 { PARAM_VALUE.DEFAULT_SEQ_3 } {
	# Procedure called to validate DEFAULT_SEQ_3
	return true
}

proc update_PARAM_VALUE.DEFAULT_SEQ_2 { PARAM_VALUE.DEFAULT_SEQ_2 } {
	# Procedure called to update DEFAULT_SEQ_2 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_2 { PARAM_VALUE.DEFAULT_SEQ_2 } {
	# Procedure called to validate DEFAULT_SEQ_2
	return true
}

proc update_PARAM_VALUE.DEFAULT_SEQ_1 { PARAM_VALUE.DEFAULT_SEQ_1 } {
	# Procedure called to update DEFAULT_SEQ_1 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_1 { PARAM_VALUE.DEFAULT_SEQ_1 } {
	# Procedure called to validate DEFAULT_SEQ_1
	return true
}

proc update_PARAM_VALUE.DEFAULT_SEQ_0 { PARAM_VALUE.DEFAULT_SEQ_0 } {
	# Procedure called to update DEFAULT_SEQ_0 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_SEQ_0 { PARAM_VALUE.DEFAULT_SEQ_0 } {
	# Procedure called to validate DEFAULT_SEQ_0
	return true
}

proc update_PARAM_VALUE.DEFAULT_TIMER { PARAM_VALUE.DEFAULT_TIMER } {
	# Procedure called to update DEFAULT_TIMER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DEFAULT_TIMER { PARAM_VALUE.DEFAULT_TIMER } {
	# Procedure called to validate DEFAULT_TIMER
	return true
}

proc update_PARAM_VALUE.AUTO_START { PARAM_VALUE.AUTO_START } {
	# Procedure called to update AUTO_START when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AUTO_START { PARAM_VALUE.AUTO_START } {
	# Procedure called to validate AUTO_START
	return true
}

proc update_PARAM_VALUE.C_ID_WIDTH { PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to update C_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ID_WIDTH { PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to validate C_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to update C_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to validate C_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to update C_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to validate C_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_ADDR_WIDTH { MODELPARAM_VALUE.C_ADDR_WIDTH PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_DATA_WIDTH { MODELPARAM_VALUE.C_DATA_WIDTH PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DATA_WIDTH}] ${MODELPARAM_VALUE.C_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ID_WIDTH { MODELPARAM_VALUE.C_ID_WIDTH PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ID_WIDTH}] ${MODELPARAM_VALUE.C_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.AUTO_START { MODELPARAM_VALUE.AUTO_START PARAM_VALUE.AUTO_START } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AUTO_START}] ${MODELPARAM_VALUE.AUTO_START}
}

proc update_MODELPARAM_VALUE.DEFAULT_TIMER { MODELPARAM_VALUE.DEFAULT_TIMER PARAM_VALUE.DEFAULT_TIMER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_TIMER}] ${MODELPARAM_VALUE.DEFAULT_TIMER}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_0 { MODELPARAM_VALUE.DEFAULT_SEQ_0 PARAM_VALUE.DEFAULT_SEQ_0 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_0}] ${MODELPARAM_VALUE.DEFAULT_SEQ_0}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_1 { MODELPARAM_VALUE.DEFAULT_SEQ_1 PARAM_VALUE.DEFAULT_SEQ_1 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_1}] ${MODELPARAM_VALUE.DEFAULT_SEQ_1}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_2 { MODELPARAM_VALUE.DEFAULT_SEQ_2 PARAM_VALUE.DEFAULT_SEQ_2 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_2}] ${MODELPARAM_VALUE.DEFAULT_SEQ_2}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_3 { MODELPARAM_VALUE.DEFAULT_SEQ_3 PARAM_VALUE.DEFAULT_SEQ_3 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_3}] ${MODELPARAM_VALUE.DEFAULT_SEQ_3}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_4 { MODELPARAM_VALUE.DEFAULT_SEQ_4 PARAM_VALUE.DEFAULT_SEQ_4 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_4}] ${MODELPARAM_VALUE.DEFAULT_SEQ_4}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_5 { MODELPARAM_VALUE.DEFAULT_SEQ_5 PARAM_VALUE.DEFAULT_SEQ_5 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_5}] ${MODELPARAM_VALUE.DEFAULT_SEQ_5}
}

proc update_MODELPARAM_VALUE.DEFAULT_SEQ_LAST { MODELPARAM_VALUE.DEFAULT_SEQ_LAST PARAM_VALUE.DEFAULT_SEQ_LAST } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DEFAULT_SEQ_LAST}] ${MODELPARAM_VALUE.DEFAULT_SEQ_LAST}
}

