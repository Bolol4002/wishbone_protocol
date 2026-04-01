# Wishbone Bus Protocol — Verilog Implementation

A simple, educational implementation of the **Wishbone Bus Protocol** in Verilog, including a Master module, a Slave module, and a testbench. Simulated using [Icarus Verilog](http://iverilog.icarus.com/) with waveform output viewable in [GTKWave](http://gtkwave.sourceforge.net/).

---

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Module Descriptions](#module-descriptions)
  - [Wishbone Master](#wishbone-master)
  - [Wishbone Slave](#wishbone-slave)
  - [Testbench](#testbench)
- [Signal Reference](#signal-reference)
- [Bus Operation](#bus-operation)
  - [Write Cycle](#write-cycle)
  - [Read Cycle](#read-cycle)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Compile](#compile)
  - [Simulate](#simulate)
  - [View Waveforms](#view-waveforms)
- [Simulation Output](#simulation-output)
- [Waveform Signals](#waveform-signals)

---

## Overview

The **Wishbone Bus** is an open-source hardware computer bus intended to let the parts of an integrated circuit communicate with each other. It is widely used in FPGA and ASIC designs, particularly in open-source IP cores (e.g., OpenCores).

This project implements a minimal Wishbone-compatible interface demonstrating:

- A **Master** that initiates bus transactions
- A **Slave** with an internal 256-byte memory that responds to read/write requests
- A **Testbench** that exercises two sequential write transactions and verifies the results

---

## Project Structure

```
wishbone_protocol/
├── wishbone_master.v      # Wishbone Master module
├── wishbone_slave.v       # Wishbone Slave module (256-byte memory)
├── wishbone_tb.v          # Testbench (instantiates Master + Slave)
├── wishbone.vcd           # VCD waveform dump (generated on simulation)
├── wishbone_master.v.out  # Compiled output for master (Icarus Verilog)
├── wishbone_tb.v.out      # Compiled output for testbench (Icarus Verilog)
└── README.md
```

---

## Module Descriptions

### Wishbone Master

**File:** `wishbone_master.v`

The Master initiates bus transactions. It waits for an external `start` pulse, then drives the bus signals (`cyc`, `stb`, `we`, `adr`, `dat_o`) until the Slave acknowledges with `ack`.

| Port     | Direction | Width | Description                              |
|----------|-----------|-------|------------------------------------------|
| `clk`    | Input     | 1     | System clock                             |
| `rst`    | Input     | 1     | Synchronous reset (active high)          |
| `ack`    | Input     | 1     | Acknowledge from Slave                   |
| `dat_i`  | Input     | 8     | Data input from Slave (for reads)        |
| `start`  | Input     | 1     | Pulse high to begin a transaction        |
| `adr_in` | Input     | 8     | Address to access                        |
| `dat_in` | Input     | 8     | Data to write                            |
| `cyc`    | Output    | 1     | Bus cycle active                         |
| `stb`    | Output    | 1     | Transfer strobe                          |
| `we`     | Output    | 1     | Write enable (1 = write, 0 = read)       |
| `dat_o`  | Output    | 8     | Data output to Slave                     |
| `adr`    | Output    | 8     | Address on the bus                       |
| `busy`   | Output    | 1     | High while a transaction is in progress  |

**State behaviour:**
- On `rst`: all outputs cleared.
- On `start` (when not `busy`): asserts `cyc`, `stb`, `we`, latches address and data, sets `busy`.
- On `ack` (while `busy`): de-asserts `cyc`, `stb`, clears `busy`.

---

### Wishbone Slave

**File:** `wishbone_slave.v`

The Slave contains a **256 × 8-bit internal memory**. It responds whenever `cyc` and `stb` are both asserted, performing a write or read based on `we`, and returns `ack` in the same clock cycle.

| Port    | Direction | Width | Description                            |
|---------|-----------|-------|----------------------------------------|
| `clk`   | Input     | 1     | System clock                           |
| `rst`   | Input     | 1     | Synchronous reset (active high)        |
| `cyc`   | Input     | 1     | Bus cycle active (from Master)         |
| `stb`   | Input     | 1     | Transfer strobe (from Master)          |
| `we`    | Input     | 1     | Write enable (from Master)             |
| `adr`   | Input     | 8     | Address (from Master)                  |
| `dat_o` | Input     | 8     | Data from Master (write data)          |
| `ack`   | Output    | 1     | Acknowledge to Master                  |
| `dat_i` | Output    | 8     | Data to Master (read data)             |

**Behaviour:**
- On `rst`: clears `ack`.
- On `cyc && stb`:
  - If `we == 1`: writes `dat_o` into `memory[adr]`.
  - If `we == 0`: reads `memory[adr]` onto `dat_i`.
  - Asserts `ack = 1`.
- Otherwise: de-asserts `ack`.

---

### Testbench

**File:** `wishbone_tb.v`

Instantiates the Master and Slave, wires them together, and drives two sequential **write** transactions:

| Transaction | Address  | Data   |
|-------------|----------|--------|
| Write 1     | `0x10`   | `0xAA` |
| Write 2     | `0x20`   | `0x55` |

After both transactions complete, the testbench reads back the slave's internal memory directly and prints the values to verify correctness. It also dumps a VCD file (`wishbone.vcd`) for waveform inspection.

---

## Signal Reference

| Signal  | Description                                           |
|---------|-------------------------------------------------------|
| `clk`   | 10 ns period system clock (toggled every 5 ns)        |
| `rst`   | Active-high reset, asserted for the first 20 ns       |
| `cyc`   | Indicates an active bus cycle                         |
| `stb`   | Qualifies that a valid transfer is requested          |
| `we`    | Write Enable: `1` = write, `0` = read                 |
| `ack`   | Slave acknowledges the transfer                       |
| `adr`   | 8-bit address bus                                     |
| `dat_o` | 8-bit data driven by the Master (write data)          |
| `dat_i` | 8-bit data driven by the Slave (read data)            |
| `busy`  | Master is currently processing a transaction          |

---

## Bus Operation

### Write Cycle

```
          ____      ____      ____
clk  ____/    \____/    \____/    \____
          ___________
cyc  ____/           \________________
          ___________
stb  ____/           \________________
          ___________
we   ____/           \________________
     ____[ adr/data  ]________________
               ______
ack  __________/    \________________
```

1. Master asserts `cyc = 1`, `stb = 1`, `we = 1`, and drives `adr` and `dat_o`.
2. Slave detects `cyc && stb`, writes data to memory, asserts `ack = 1`.
3. Master detects `ack`, de-asserts `cyc` and `stb`, clears `busy`.

### Read Cycle

1. Master asserts `cyc = 1`, `stb = 1`, `we = 0`, and drives `adr`.
2. Slave detects `cyc && stb && !we`, places `memory[adr]` on `dat_i`, asserts `ack = 1`.
3. Master samples `dat_i` and de-asserts `cyc` and `stb`.

> **Note:** The current testbench only exercises write transactions. Read transactions are supported by the slave hardware.

---

## Getting Started

### Prerequisites

Install **Icarus Verilog**:

- **Windows:** Download the installer from [bleyer.org/icarus](http://bleyer.org/icarus/) or install via a package manager.
- **Linux (Debian/Ubuntu):** `sudo apt-get install iverilog`
- **macOS:** `brew install icarus-verilog`

Optionally install **GTKWave** to view the waveform output:

- **Windows / macOS / Linux:** [gtkwave.sourceforge.net](http://gtkwave.sourceforge.net/)

---

### Compile

```sh
iverilog -o wishbone_sim wishbone_tb.v
```

This compiles the testbench (which includes `wishbone_master.v` and `wishbone_slave.v` via `` `include `` directives) and produces the simulation executable `wishbone_sim`.

---

### Simulate

```sh
vvp wishbone_sim
```

Expected console output:

```
Time    busy cyc stb we ack adr dat_o dat_i
...
Memory[0x10]=0xaa
Memory[0x20]=0x55
```

A `wishbone.vcd` waveform file will also be generated in the working directory.

---

### View Waveforms

```sh
gtkwave wishbone.vcd
```

In GTKWave, add the following signals from the `wishbone_tb` scope to the waveform viewer for a complete picture of the bus transactions:

- `clk`, `rst`
- `busy`, `cyc`, `stb`, `we`, `ack`
- `adr[7:0]`, `dat_o[7:0]`, `dat_i[7:0]`

---

## Simulation Output

The testbench prints a log table every clock cycle showing the state of key signals:

| Column  | Description                        |
|---------|------------------------------------|
| `Time`  | Simulation time in nanoseconds     |
| `busy`  | Master busy flag                   |
| `cyc`   | Bus cycle active                   |
| `stb`   | Strobe signal                      |
| `we`    | Write enable                       |
| `ack`   | Slave acknowledge                  |
| `adr`   | Current address (hex)              |
| `dat_o` | Data from Master (hex)             |
| `dat_i` | Data from Slave (hex)              |

---

## Waveform Signals

Recommended signal grouping in GTKWave:

| Group        | Signals                          |
|--------------|----------------------------------|
| Clock/Reset  | `clk`, `rst`                     |
| Control      | `busy`, `cyc`, `stb`, `we`, `ack`|
| Data Bus     | `adr[7:0]`, `dat_o[7:0]`, `dat_i[7:0]` |

---

## License

This project is released for educational purposes. Feel free to use, modify, and distribute it freely.