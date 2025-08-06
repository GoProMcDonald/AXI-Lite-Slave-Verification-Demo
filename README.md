# AXI-Lite Slave Verification Demo

This project demonstrates a simple, modular, synthesizable AXI-Lite slave register file and a SystemVerilog testbench to verify its functionality. It uses a standard 5-channel AXI-Lite interface and is organized into a clear three-file structure.

## 📁 File Structure


├── design_axi_regs.sv # AXI-Lite slave DUT (4-register addressable block)
├── axi_tasks.sv # Encapsulated write/read tasks (used in testbench)
├── tb_axi_regs.sv # Top-level testbench to stimulate the DUT


## 🔧 DUT Description

The DUT (`axi_lite_slave_regs`) implements:

- A 4-entry register file, each 32 bits wide (`regfile[4]`)
- Full support for all **5 AXI-Lite channels**:
  - AW (write address)
  - W  (write data)
  - B  (write response)
  - AR (read address)
  - R  (read data)
- **WSTRB support** for byte-level write masking
- **Address decoding** using `awaddr[3:2]`, `araddr[3:2]`
- **Illegal address handling** with `SLVERR` and `DEAD_BEEF` return

## ▶️ Simulation Scenarios

The testbench performs:

1. Write 4 values to `reg[0]` ~ `reg[3]`  
2. Read back from each address and print the result  
3. Read from an **invalid address** and expect `32'hDEAD_BEEF`  

Simulation output sample:
reg[0] = 0xA5A50000
reg[1] = 0xA5A50001
reg[2] = 0xA5A50002
reg[3] = 0xA5A50003
Read invalid addr: 0xDEAD_BEEF


## 🧪 Testbench Features

- Modular `axi_write` / `axi_read` tasks in `axi_tasks_pkg`
- Protocol-accurate handshake behavior (`wait`, `@(posedge clk)`)
- Byte-level WSTRB write support
- Clean waveform generation support (e.g. `EPWave` / `GTKWave`)
- Compatible with Icarus, Questa, Riviera, VCS, etc.

## ✅ How to Run

### Using Icarus Verilog + GTKWave:

```bash
# Compile
iverilog -g2012 -o sim.vvp tb_axi_regs.sv design_axi_regs.sv

# Run
vvp sim.vvp

# View waveform
gtkwave dump.vcd
Be sure to include in your testbench:
$dumpfile("dump.vcd");
$dumpvars(0, tb_axi_regs);
inside the initial block to generate the waveform.

📊 Waveform Screenshot (optional)

Shows valid read/write handshakes, register values, and protocol timing.

💡 Next Steps
This project is designed to be the foundation for:

Migrating to a UVM-based AXI-Lite verification platform

Adding functional coverage and SystemVerilog assertions

Replacing DUT with memory-mapped IPs or protocol bridges
