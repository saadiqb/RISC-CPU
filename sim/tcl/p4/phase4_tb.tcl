# GTKWave script to auto-load required Phase 4 signals

set signals [list \
    "Phase4_tb.clock" \
    "Phase4_tb.reset" \
    "Phase4_tb.stop" \
    "Phase4_tb.in_port_data" \
    "Phase4_tb.out_port_data" \
    "Phase4_tb.DUT.datapath_inst.IR_data" \
    "Phase4_tb.DUT.datapath_inst.PC_data" \
    "Phase4_tb.DUT.datapath_inst.MDR_data" \
    "Phase4_tb.DUT.datapath_inst.MAR_data" \
    "Phase4_tb.DUT.datapath_inst.HI_data" \
    "Phase4_tb.DUT.datapath_inst.LO_data" \
    "Phase4_tb.DUT.datapath_inst.R0.q" \
    "Phase4_tb.DUT.datapath_inst.R1.q" \
    "Phase4_tb.DUT.datapath_inst.R2.q" \
    "Phase4_tb.DUT.datapath_inst.R3.q" \
    "Phase4_tb.DUT.datapath_inst.R4.q" \
    "Phase4_tb.DUT.datapath_inst.R5.q" \
    "Phase4_tb.DUT.datapath_inst.R6.q" \
    "Phase4_tb.DUT.datapath_inst.R7.q" \
    "Phase4_tb.DUT.datapath_inst.R8.q" \
    "Phase4_tb.DUT.datapath_inst.R9.q" \
    "Phase4_tb.DUT.datapath_inst.R10.q" \
    "Phase4_tb.DUT.datapath_inst.R11.q" \
    "Phase4_tb.DUT.datapath_inst.R12.q" \
    "Phase4_tb.DUT.datapath_inst.R13.q" \
    "Phase4_tb.DUT.datapath_inst.R14.q" \
    "Phase4_tb.DUT.datapath_inst.R15.q" \
]

set num_added [ gtkwave::addSignalsFromList $signals ]
puts "Added $num_added signals to waveform"

gtkwave::/Edit/Set_Trace_Max_Hier 0
gtkwave::/Time/Zoom/Zoom_Full
