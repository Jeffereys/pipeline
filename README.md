# RV32I Pipelined Processor (5-Stage)

This project implements a modular 5-stage pipelined RISC-V processor (RV32I base ISA) in SystemVerilog. It is designed to be synthesized for FPGAs or simulated for instruction-level debugging.

---

## 📁 Folder Structure

rv32i_pipeline/ ├── top_level/ │ └── pipeline_top.sv │ └── top_level.sv ├── stages/ │ └── rv32_if_top.sv │ └── rv32_id_top.sv │ └── rv32_ex_top.sv │ └── rv32_mem_top.sv │ └── rv32_wb_top.sv ├── pipeline_registers/ │ └── id_ex_reg.sv │ └── ex_mem_reg.sv │ └── mem_wb_reg.sv ├── components/ │ └── alu.sv │ └── rv32i_regs.sv │ └── dual_port_ram.sv │ └── memory_io_unit.sv │ └── branch_unit.sv ├── control/ │ └── rv32_decoder.sv │ └── control_unit.sv │ └── imm_decoder.sv │ └── hazard_unit.sv (optional) ├── debug/ │ └── debug_tap.sv ├── test/ │ └── tb_pipeline.sv │ └── ram.hex └── README.md


yaml
---

## 🧠 Pipeline Stages

- **IF**: Instruction Fetch from dual-port RAM.
- **ID**: Instruction Decode, forwarding, control decoding.
- **EX**: ALU execution, branch target calculation.
- **MEM**: Memory access with byte enables and aligned transfers.
- **WB**: Writeback to register file.

---

## 🔧 Features

- Modular, clean structure for synthesis and simulation
- Dual-port RAM for instruction + data access
- Hazard resolution via:
  - Data forwarding (EX/MEM/WB to ID/EX)
  - Load-use hazard stall detection
- Full support for:
  - Arithmetic/Logic ops
  - Jumps and Branches
  - Loads/Stores with alignment
  - LUI/AUIPC
  - `EBREAK` to halt pipeline

---

## 📜 Example Test Program (`ram.hex`)

```assembly
# ram.hex
@00000000
00100093   # ADDI x1, x0, 1
00200113   # ADDI x2, x0, 2
002081b3   # ADD x3, x1, x2
00000073   # EBREAK


▶️ Simulation
Use the testbench tb_pipeline.sv:

shell
Copy
Edit
# Compile and run
vlog +acc tb_pipeline.sv
vsim tb_pipeline
run -all
Output will include pipeline debug trace from debug_tap.sv

Future Work
Support for multiplication/division (RV32M)

CSR and interrupt logic (RV32I extensions)

I/O-mapped peripherals (GPIO, UART)

Branch prediction and out-of-order extensions

👤 Authors
Designed by: [Your Name]

Based on UT Arlington CSE4372/5392 project structure

📄 License
MIT License

yaml
Copy
Edit

---

Let me know if you'd like a Quartus or Vivado project wrapper, or to export this as a zip

📦 Expected Files in the Same Directory:
python
Copy
Edit
tb_pipeline.sv
pipeline_top.sv
dual_port_ram.sv
ram.hex

