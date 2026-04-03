# Phase 4 required waveform signals (IR, PC, MDR, MAR, R0–R15, HI, LO + mem taps)

set signals [list \
    "Phase4_tb.clock" \
    "Phase4_tb.reset" \
    "Phase4_tb.stop" \
    "Phase4_tb.in_port_data" \
    "Phase4_tb.out_port_data" \
    "Phase4_tb.IR" \
    "Phase4_tb.PC" \
    "Phase4_tb.MDR" \
    "Phase4_tb.MAR" \
    "Phase4_tb.Y" \
    "Phase4_tb.Z" \
    "Phase4_tb.BusMuxOut" \
    "Phase4_tb.CON" \
    "Phase4_tb.Run" \
    "Phase4_tb.IRin_sig" \
    "Phase4_tb.MARin_sig" \
    "Phase4_tb.Zin_sig" \
    "Phase4_tb.HI" \
    "Phase4_tb.LO" \
    "Phase4_tb.R0" \
    "Phase4_tb.R1" \
    "Phase4_tb.R2" \
    "Phase4_tb.R3" \
    "Phase4_tb.R4" \
    "Phase4_tb.R5" \
    "Phase4_tb.R6" \
    "Phase4_tb.R7" \
    "Phase4_tb.R8" \
    "Phase4_tb.R9" \
    "Phase4_tb.R10" \
    "Phase4_tb.R11" \
    "Phase4_tb.R12" \
    "Phase4_tb.R13" \
    "Phase4_tb.R14" \
    "Phase4_tb.R15" \
    "Phase4_tb.mem_089" \
    "Phase4_tb.mem_0A3" \
    "Phase4_tb.mem_088" \
    "Phase4_tb.mem_077" \
]

set num_added [ gtkwave::addSignalsFromList $signals ]
puts "Added $num_added required signals"

gtkwave::/Edit/Set_Trace_Max_Hier 0
gtkwave::/Time/Zoom/Zoom_Full
