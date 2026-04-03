# RISC-CPU Phase 4 Simulation Notes

This README lists the commands used to compile, simulate, and view waveforms for the Phase 4 testbench, including targeted and full-run VCDs. It also explains what each command does.

## 1) Compile (required before any simulation)

```bash
iverilog -g2012 -o sim/phase4_tb.out sim/Phase4_tb.v HDL/*.v HDL/ALU/*.v
```

**What it does:** Compiles the Phase 4 testbench and HDL into a runnable simulation binary (`sim/phase4_tb.out`).

---

## 2) Full simulation + full VCD (manual scrolling)

```bash
vvp sim/phase4_tb.out +dump=sim/phase4_tb_min.vcd
gtkwave sim/phase4_tb_min.vcd -S sim/phase4_required_signals.tcl
```

**What it does:**  
- Runs the full testbench and dumps all required signals into `sim/phase4_tb_min.vcd`.  
- Opens GTKWave and auto-loads the required signals list.

---

## 3) Targeted instruction window (small VCDs)

Use these when you want a clean waveform for a single instruction.

```bash
vvp sim/phase4_tb.out +addr=0x00000007 +window=10 +dump=sim/brmi.vcd
gtkwave sim/brmi.vcd -S sim/phase4_required_signals.tcl
```

**What it does:**  
- Starts dumping only when the instruction at address `0x00000007` is fetched.  
- Captures `window` cycles (10 cycles × 20 ns = 200 ns), then stops.  
- Opens the small VCD in GTKWave with required signals.

### Available match modes (pick one)

- `+addr=<hex>`: match instruction address (MAR during IRin)
- `+ir=<hex>`: match full IR value
- `+pc=<hex>`: match PC at IRin

### Window control

- `+window=<cycles>`: number of cycles to capture after match (suggested 8–12)

---

## 4) Signal list auto-load

```bash
gtkwave sim/phase4_tb_min.vcd -S sim/phase4_required_signals.tcl
```

**What it does:** Opens GTKWave and loads the required signals (IR/PC/MDR/MAR, R0–R15, HI/LO, CON, Run, IRin/MARin/Zin, and memory taps including `mem_077`, `mem_088`, `mem_089`, `mem_0A3`).

---

## 5) Optional: generate instruction windows from VCD

These helper files give you approximate time windows per unique instruction:

```bash
# After running a full VCD (phase4_tb_min.vcd)
python sim/phase4_focus.py --preset-all
```

**What it does:** Generates timeline/marker files for segments of the program.  
This is optional; manual scrolling in GTKWave is also fine.

---

## 6) Example: run all unique instruction windows (manual list)

If you want one VCD per instruction, use the targeted mode with the address list from the program. Example:

```bash
vvp sim/phase4_tb.out +addr=0x00000000 +window=10 +dump=sim/ldi.vcd
vvp sim/phase4_tb.out +addr=0x00000002 +window=10 +dump=sim/ld.vcd
vvp sim/phase4_tb.out +addr=0x00000007 +window=10 +dump=sim/br.vcd
vvp sim/phase4_tb.out +addr=0x0000000A +window=10 +dump=sim/nop.vcd
```

**What it does:** Creates small, easy-to-capture VCDs for each instruction.

---

## Notes / Quick reminders

- Clock period is **20 ns**.  
- Program is loaded in `sim/Phase4_tb.v` by writing directly into `memory[]`.  
- Memory init required by Phase 4:  
  - `mem[0x89]=0xA7`, `mem[0xA3]=0x68`, `mem[0x88]=0x0000000A` (inner loop), `mem[0x77]` is updated by the program.  
- Outer loop count is controlled by the `ldi R2` instruction in the program (currently set to 8).  

