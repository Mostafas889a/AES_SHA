# Integration Notes

## Overview
This document provides technical details for integrating the AES_SHA cryptographic accelerators into the Caravel SoC framework.

## System Architecture

```
Caravel Management SoC
        |
        | (Wishbone B4 Classic)
        v
user_project_wrapper
        |
        v
    user_project
        |
        +-- Wishbone Bus Splitter (3 peripherals)
        |       |
        |       +-- [0] EF_AES_WB (0x3000_0000)
        |       +-- [1] EF_SHA256_WB (0x3001_0000)
        |       +-- [2] WB_PIC (0x3002_0000)
        |
        +-- Programmable Interrupt Controller
                |
                +-- IRQ[0] <-- AES
                +-- IRQ[1] <-- SHA256
                |
                v
            user_irq[0] --> Caravel IRQ system
```

## Clock and Reset

### Clock Domain
- **Single clock domain**: `wb_clk_i` from Caravel management SoC
- **Target frequency**: 40 MHz (25ns period)
- All peripherals operate synchronously on `wb_clk_i`
- **No clock gating** implemented at top level
- IP cores (AES, SHA256) have internal clock gating via GCLK registers

### Reset Architecture
- **Reset signal**: `wb_rst_i` (active-high, synchronous)
- Reset is distributed unmodified to all peripherals
- All state machines and registers reset properly on `wb_rst_i` assertion
- Recommended reset duration: minimum 10 clock cycles

### Timing Constraints
- **Setup time**: All registers meet setup/hold at 40 MHz
- **Wishbone timing**: Single-cycle acknowledgment for all peripherals
- **Critical paths**: Managed within IP cores (AES, SHA256)

## Wishbone Bus Integration

### Bus Topology
```
Master (Caravel) --> wishbone_bus_splitter --> 3 Slaves
```

### Bus Splitter Configuration
```verilog
wishbone_bus_splitter #(
    .NUM_PERIPHERALS(3),
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32),
    .SEL_WIDTH(4),
    .ADDR_SEL_LOW_BIT(16)  // Decode bits [19:16]
) bus_splitter (
    // Master interface from Caravel
    .m_wb_clk_i(wb_clk_i),
    .m_wb_rst_i(wb_rst_i),
    // ...
);
```

### Address Decoding
- **Decode bits**: `wbs_adr_i[19:16]` selects peripheral
- **Window size**: 64KB (0x10000) per peripheral
- **Non-power-of-2 peripherals**: Enables automatic error detection

| Peripheral | Select Value | Base Address | End Address |
|-----------|--------------|--------------|-------------|
| AES       | 3'h0         | 0x3000_0000  | 0x3000_FFFF |
| SHA256    | 3'h1         | 0x3001_0000  | 0x3001_FFFF |
| PIC       | 3'h2         | 0x3002_0000  | 0x3002_FFFF |
| Invalid   | 3'h3-3'h7    | -            | Returns ERR |

### Wishbone Protocol Compliance
- **Bus standard**: Wishbone B4 Classic
- **Cycle type**: Classic (single transaction)
- **Data width**: 32 bits
- **Address width**: 32 bits
- **Byte enable**: 4-bit `wbs_sel_i` for byte-lane writes
- **Timing**: All slaves respond with ACK in 1 cycle
- **Error handling**: Invalid addresses return `wbs_err_o`

### Signal Routing Rules
1. **`wbs_cyc_i`**: Routed unmodified to all peripherals (never gated)
2. **`wbs_stb_i`**: Gated by address decode for peripheral selection
3. **`wbs_ack_o`**: OR-ed from all peripheral responses
4. **`wbs_dat_o`**: Multiplexed based on peripheral selection

## Interrupt System

### Interrupt Flow
```
AES IRQ ----+
            |
SHA256 IRQ -+---> WB_PIC ---> user_irq[0] ---> Caravel IRQ Controller
            |
(14 more) --+
```

### PIC Configuration
- **IRQ sources**: 16 total (only 2 used: AES, SHA256)
- **Priority levels**: 4 (0=highest, 3=lowest)
- **Trigger modes**: Edge (rising) or Level (high)
- **Masking**: Per-IRQ enable + global enable
- **Output**: Single consolidated IRQ to `user_irq[0]`

### Interrupt Handling Sequence
1. Peripheral asserts IRQ line
2. PIC latches interrupt (if enabled and unmasked)
3. PIC performs priority arbitration
4. PIC asserts `user_irq[0]` to Caravel
5. Firmware reads PIC MIS register to identify source
6. Firmware services interrupt
7. Firmware writes IC register to clear interrupt

## Power Management

### Power Domains
- **User project power**: `vccd1` (digital 1.8V) / `vssd1` (ground)
- All peripherals powered by `vccd1/vssd1`
- **No connection** to `vccd2/vssd2` or analog supplies

### Power Optimization
- **Clock gating**: Available in AES and SHA256 via GCLK registers
- **Dynamic power**: Peripherals idle when not accessed
- **Leakage**: Minimized by SKY130 HD standard cells

## IP Core Integration

### EF_AES Integration
- **IP version**: v1.1.0
- **Wrapper**: `EF_AES_WB` (Wishbone wrapper)
- **Source**: `/nc/ip/EF_AES/v1.1.0/`
- **Features**: AES-128/192/256, encrypt/decrypt
- **Latency**: ~10-14 cycles per block (depends on key size)
- **IRQ**: Asserted when result valid

### EF_SHA256 Integration
- **IP version**: v1.1.0
- **Wrapper**: `EF_SHA256_WB` (Wishbone wrapper)
- **Source**: `/nc/ip/EF_SHA256/v1.1.0/`
- **Features**: SHA-256/SHA-224 hashing
- **Block size**: 512 bits (16 x 32-bit words)
- **Latency**: ~64 cycles per block
- **IRQ**: Asserted when digest valid

### WB_PIC Integration
- **Source**: `/workspace/AES_SHA/verilog/rtl/WB_PIC.v`
- **Features**: 16 IRQ sources, 4-level priority, edge/level triggers
- **Response time**: Single-cycle ACK

## IP Linker Configuration

Located at `/workspace/AES_SHA/ip/link_IPs.json`:

```json
{
  "EF_AES": {
    "version": "v1.1.0",
    "enabled": true
  },
  "EF_SHA256": {
    "version": "v1.1.0",
    "enabled": true
  }
}
```

Run IP linker to mount IPs:
```bash
python /nc/agent_tools/ipm_linker/ipm_linker.py \
    --file /workspace/AES_SHA/ip/link_IPs.json \
    --project-root /workspace/AES_SHA
```

## Verification Strategy

### Simulation Environment
- **Testbench framework**: cocotb (Python-based)
- **Simulator**: Icarus Verilog / Verilator
- **Caravel integration**: caravel-cocotb

### Test Coverage
1. **AES tests**:
   - AES-128 encrypt/decrypt
   - AES-256 encrypt/decrypt
   - Known answer tests (NIST vectors)
   - Interrupt generation

2. **SHA256 tests**:
   - Single block hash
   - Multi-block hash
   - Known answer tests (NIST vectors)
   - Interrupt generation

3. **System tests**:
   - Wishbone bus compliance
   - Address decode and error handling
   - Interrupt priority and masking
   - Concurrent peripheral access

### Test Execution
```bash
cd /workspace/AES_SHA/verilog/dv/cocotb
python cocotb_tests.py
```

## Physical Design Considerations

### Macro Hierarchy
1. **user_project** (first-level macro)
   - Contains: AES, SHA256, PIC, bus splitter
   - Hardened separately with OpenLane
   
2. **user_project_wrapper** (top-level)
   - Instantiates user_project as hard macro
   - Connects to Caravel padframe
   - Final GDS for user project area

### Floorplan
- **Die area**: TBD during physical design
- **Utilization target**: 40-50%
- **Aspect ratio**: 1:1 (square)
- **Macro placement**: Automatic (OpenLane)

### Power Distribution
- **Power strategy**: USE_POWER_PINS
- **Internal rails**: vccd1/vssd1 only
- **PDN**: Standard cell rails + macro rings

### Design Rules
- **Technology**: SKY130A
- **Library**: sky130_fd_sc_hd (high density)
- **Metal layers**: M1-M5 (M6+ reserved for top level)

## Synthesis Guidelines

### RTL Synthesis
```bash
yosys -p "
    read_verilog user_project.v;
    synth -top user_project;
    stat;
"
```

### Linting
```bash
verilator --lint-only --Wno-EOFNEWLINE \
    -Wall user_project.v \
    --top-module user_project
```

## Debugging and Bringup

### Firmware Debug
1. **Register access test**: Read/write STATUS registers
2. **Clock gate check**: Enable GCLK before operation
3. **Interrupt test**: Enable PIC and verify IRQ assertion
4. **AES test**: Encrypt known plaintext, verify result
5. **SHA test**: Hash known message, verify digest

### Common Issues
- **No ACK**: Check address decode, ensure peripheral selected
- **Wrong data**: Verify byte order (little-endian)
- **No IRQ**: Enable PIC global enable + per-IRQ mask
- **AES/SHA hangs**: Check GCLK enable, verify INIT/NEXT sequence

### Debug Registers
- All peripherals have STATUS registers for health monitoring
- PIC RIS register shows raw interrupt state
- Use Logic Analyzer (LA) for real-time signal observation

## Performance Characteristics

### AES Performance
- **Encryption throughput**: ~286 Mbps @ 40 MHz (128-bit key)
- **Latency**: ~10 cycles (INIT) + 10 cycles (NEXT)
- **Key setup**: Performed once per key change

### SHA-256 Performance
- **Hash throughput**: ~320 Mbps @ 40 MHz
- **Latency**: ~64 cycles per 512-bit block
- **Multi-block**: INIT once, NEXT for each subsequent block

## References
- [EF_AES Documentation](/nc/ip/EF_AES/v1.1.0/README.md)
- [EF_SHA256 Documentation](/nc/ip/EF_SHA256/v1.1.0/README.md)
- [Wishbone B4 Specification](https://cdn.opencores.org/downloads/wbspec_b4.pdf)
- [Caravel Documentation](https://caravel-harness.readthedocs.io/)
