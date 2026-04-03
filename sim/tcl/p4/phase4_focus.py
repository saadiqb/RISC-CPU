#!/usr/bin/env python3
import argparse
import re
from pathlib import Path


PRESETS = {
    "phase3_preamble": (0x000, 0x006, "Phase 3 preamble"),
    "branch_tests": (0x007, 0x00D, "Phase 3 branches"),
    "phase3_alu": (0x00E, 0x01D, "Phase 3 ALU/mem"),
    "muldiv": (0x01E, 0x023, "MUL/DIV"),
    "proc_setup": (0x024, 0x028, "Setup + JAL"),
    "phase4_loop": (0x029, 0x038, "Phase 4 loop"),
    "phase4_done": (0x039, 0x03B, "Phase 4 done"),
    "subA": (0x0B2, 0x0B5, "subA procedure"),
}


def parse_vcd_signals(vcd_path):
    scope = []
    name_to_id = {}
    id_to_name = {}
    with open(vcd_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if line.startswith("$scope"):
                parts = line.split()
                scope.append(parts[2])
            elif line.startswith("$upscope"):
                if scope:
                    scope.pop()
            elif line.startswith("$var"):
                parts = line.split()
                if len(parts) >= 5:
                    vid = parts[3]
                    name = parts[4]
                    full = ".".join(scope + [name])
                    name_to_id[full] = vid
                    id_to_name[vid] = full
            elif line.startswith("$enddefinitions"):
                break
    return name_to_id, id_to_name


def parse_int(s):
    s = str(s).strip().lower()
    if s.startswith("0x"):
        return int(s, 16)
    return int(s, 10)


def iter_ir_timeline(vcd_path, ir_id, pc_id, pc_eq=None, pc_min=None, pc_max=None, every=1, max_entries=None):
    cur_time = 0
    ir_val = None
    pc_val = None
    last_ir = None
    entries = []
    seen = 0

    def is_known(binstr):
        return set(binstr) <= {"0", "1"}

    def to_hex(binstr):
        return f"0x{int(binstr, 2):08X}"

    with open(vcd_path, "r", encoding="utf-8", errors="ignore") as f:
        in_defs = True
        for line in f:
            line = line.strip()
            if in_defs:
                if line.startswith("$enddefinitions"):
                    in_defs = False
                continue
            if not line:
                continue
            if line[0] == "#":
                cur_time = int(line[1:])
                continue
            if line[0] == "b":
                parts = line[1:].split()
                if len(parts) != 2:
                    continue
                binstr, vid = parts
                if vid == pc_id:
                    pc_val = binstr
                elif vid == ir_id:
                    ir_val = binstr
                    if ir_val != last_ir and is_known(ir_val):
                        ir_hex = to_hex(ir_val)
                        if pc_val and is_known(pc_val):
                            pc_hex = to_hex(pc_val)
                            pc_int = int(pc_val, 2)
                        else:
                            pc_hex = "unknown"
                            pc_int = None

                        if pc_int is not None:
                            if pc_eq is not None and pc_int != pc_eq:
                                last_ir = ir_val
                                continue
                            if pc_min is not None and pc_int < pc_min:
                                last_ir = ir_val
                                continue
                            if pc_max is not None and pc_int > pc_max:
                                last_ir = ir_val
                                continue
                        elif pc_eq is not None or pc_min is not None or pc_max is not None:
                            last_ir = ir_val
                            continue

                        seen += 1
                        if every > 1 and (seen % every) != 0:
                            last_ir = ir_val
                            continue

                        entries.append((cur_time, ir_hex, pc_hex))
                        if max_entries is not None and len(entries) >= max_entries:
                            break
                        last_ir = ir_val
            else:
                # scalar change; ignore for this script
                continue
    return entries


def write_timeline(timeline, out_path):
    with open(out_path, "w", encoding="utf-8") as f:
        f.write("index,time,IR,PC\n")
        for idx, (t, ir, pc) in enumerate(timeline, start=1):
            f.write(f"{idx},{t},{ir},{pc}\n")


def write_focus_tcl(timeline, index, window, out_path):
    idx = max(1, min(index, len(timeline)))
    start_idx = max(1, idx - window)
    end_idx = min(len(timeline), idx + window)
    start_t, start_ir, start_pc = timeline[start_idx - 1]
    end_t, end_ir, end_pc = timeline[end_idx - 1]

    with open(out_path, "w", encoding="utf-8") as f:
        f.write("# Auto markers for GTKWave\n")
        f.write(f"gtkwave::setNamedMarker A {start_t} \"idx {start_idx} PC={start_pc} IR={start_ir}\"\n")
        f.write(f"gtkwave::setNamedMarker B {end_t} \"idx {end_idx} PC={end_pc} IR={end_ir}\"\n")
        f.write("gtkwave::/Time/Zoom/Zoom_Full\n")
        f.write("# In GTKWave: Time -> Zoom -> Zoom to Markers (A/B)\n")


def write_range_tcl(timeline, out_path, label):
    if not timeline:
        return False
    start_t, start_ir, start_pc = timeline[0]
    end_t, end_ir, end_pc = timeline[-1]
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(f"# {label}\n")
        f.write(f"gtkwave::setNamedMarker A {start_t} \"start PC={start_pc} IR={start_ir}\"\n")
        f.write(f"gtkwave::setNamedMarker B {end_t} \"end PC={end_pc} IR={end_ir}\"\n")
        f.write("gtkwave::/Time/Zoom/Zoom_Full\n")
        f.write("# In GTKWave: Time -> Zoom -> Zoom to Markers (A/B)\n")
    return True


def main():
    ap = argparse.ArgumentParser(description="Generate instruction timeline and GTKWave markers.")
    ap.add_argument("--vcd", default="sim/phase4_tb.vcd", help="Path to VCD file.")
    ap.add_argument("--ir", default="Phase4_tb.DUT.datapath_inst.IR_data", help="IR signal full name.")
    ap.add_argument("--pc", default="Phase4_tb.DUT.datapath_inst.PC_data", help="PC signal full name.")
    ap.add_argument("--index", type=int, default=1, help="1-based instruction index for focus markers.")
    ap.add_argument("--window", type=int, default=1, help="Number of instructions before/after index.")
    ap.add_argument("--timeline", default="sim/phase4_ir_timeline.txt", help="Output timeline CSV.")
    ap.add_argument("--tcl", default="sim/phase4_focus.tcl", help="Output GTKWave markers script.")
    ap.add_argument("--preset", choices=sorted(PRESETS.keys()), help="Generate a zoom script for a preset region.")
    ap.add_argument("--preset-all", action="store_true", help="Generate zoom scripts for all preset regions.")
    ap.add_argument("--preset-len", type=int, default=60, help="Entries per preset window (default 60).")
    ap.add_argument("--preset-out-dir", default="sim", help="Directory for preset outputs.")
    ap.add_argument("--pc-eq", help="Filter: only entries with PC == value (hex or dec).")
    ap.add_argument("--pc-min", help="Filter: only entries with PC >= value (hex or dec).")
    ap.add_argument("--pc-max", help="Filter: only entries with PC <= value (hex or dec).")
    ap.add_argument("--every", type=int, default=1, help="Only keep every Nth entry (default 1).")
    ap.add_argument("--max-entries", type=int, help="Limit number of timeline entries.")
    args = ap.parse_args()

    vcd_path = Path(args.vcd)
    if not vcd_path.exists():
        raise SystemExit(f"VCD not found: {vcd_path}")

    name_to_id, _ = parse_vcd_signals(vcd_path)
    if args.ir not in name_to_id:
        raise SystemExit(f"IR signal not found: {args.ir}")
    if args.pc not in name_to_id:
        raise SystemExit(f"PC signal not found: {args.pc}")

    pc_eq = parse_int(args.pc_eq) if args.pc_eq else None
    pc_min = parse_int(args.pc_min) if args.pc_min else None
    pc_max = parse_int(args.pc_max) if args.pc_max else None

    if args.preset or args.preset_all:
        out_dir = Path(args.preset_out_dir)
        out_dir.mkdir(parents=True, exist_ok=True)

        presets = [args.preset] if args.preset else sorted(PRESETS.keys())
        for key in presets:
            pc_min_p, pc_max_p, label = PRESETS[key]
            timeline = iter_ir_timeline(
                vcd_path,
                name_to_id[args.ir],
                name_to_id[args.pc],
                pc_min=pc_min_p,
                pc_max=pc_max_p,
                max_entries=max(1, args.preset_len),
            )
            timeline_path = out_dir / f"phase4_ir_{key}.txt"
            tcl_path = out_dir / f"phase4_zoom_{key}.tcl"
            write_timeline(timeline, timeline_path)
            ok = write_range_tcl(timeline, tcl_path, label)
            if ok:
                print(f"[{key}] {label}")
                print(f"  timeline: {timeline_path}")
                print(f"  markers:  {tcl_path}")
                print(f"  entries:  {len(timeline)}")
            else:
                print(f"[{key}] {label} -> no entries found")
        return

    timeline = iter_ir_timeline(
        vcd_path,
        name_to_id[args.ir],
        name_to_id[args.pc],
        pc_eq=pc_eq,
        pc_min=pc_min,
        pc_max=pc_max,
        every=max(1, args.every),
        max_entries=args.max_entries,
    )
    if not timeline:
        raise SystemExit("No IR transitions found in VCD.")

    write_timeline(timeline, args.timeline)
    write_focus_tcl(timeline, args.index, args.window, args.tcl)
    print(f"Wrote timeline: {args.timeline}")
    print(f"Wrote markers:  {args.tcl}")
    print(f"Total IR updates: {len(timeline)}")


if __name__ == "__main__":
    main()
