# Pad Map

## Overview
This document defines the GPIO pad assignments for the AES_SHA Caravel user project. The Caravel user project wrapper provides 38 bidirectional GPIO pads (`mprj_io[37:0]`) that can be configured for various purposes.

**Note**: Pads `mprj_io[4:0]` are reserved for Caravel management and should not be used.

## Pad Configuration

For this cryptographic accelerator project, **no external GPIO pads are required** since:
- AES and SHA256 peripherals are accessed entirely via the Wishbone bus
- All control, data input/output, and status monitoring occur through memory-mapped registers
- Interrupts are routed internally via `user_irq[2:0]` signals

## Default Configuration

All user project pads are configured as **inputs** with output drivers disabled:

| Pad Range | Configuration | Usage |
|-----------|---------------|-------|
| mprj_io[37:5] | Input (OEB=1) | Unused, tied to input mode |
| mprj_io[4:0] | Reserved | Caravel management (do not modify) |

### Pad Configuration Code

In `user_project_wrapper.v`:

```verilog
assign mprj_io_out[37:5] = 33'b0;
assign mprj_io_oeb[37:5] = {33{1'b1}};
```

## Interrupt Routing

Instead of GPIO pads, this design uses Caravel's dedicated interrupt lines:

| Signal | Source | Description |
|--------|--------|-------------|
| user_irq[0] | PIC | Consolidated interrupt from all peripherals |
| user_irq[1] | - | Reserved (unused) |
| user_irq[2] | - | Reserved (unused) |

The Programmable Interrupt Controller (PIC) consolidates interrupts from both AES and SHA256 peripherals into a single output (`user_irq[0]`), with programmable priority and masking.

## Future Expansion

If external connectivity is required in future versions, the following pads could be assigned:

### Example: Debug/Status LEDs (Optional)

| Pad | Signal | Direction | Description |
|-----|--------|-----------|-------------|
| mprj_io[5] | AES_BUSY | Output | AES engine busy indicator |
| mprj_io[6] | SHA_BUSY | Output | SHA engine busy indicator |
| mprj_io[7] | IRQ_OUT | Output | Active interrupt indicator |

### Example: External Control (Optional)

| Pad | Signal | Direction | Description |
|-----|--------|-----------|-------------|
| mprj_io[8] | AES_EN | Input | External AES enable |
| mprj_io[9] | SHA_EN | Input | External SHA enable |

## Modification Guide

To add GPIO functionality:

1. **Define signal in user_project.v**:
   ```verilog
   module user_project (
       // ...existing ports...
       output wire gpio_out,
       input  wire gpio_in,
       output wire gpio_oe
   );
   ```

2. **Connect in user_project_wrapper.v**:
   ```verilog
   // For output pad at mprj_io[N]
   assign mprj_io_out[N] = gpio_out;
   assign mprj_io_oeb[N] = ~gpio_oe;  // Active-low OEB
   
   // For input pad at mprj_io[M]
   assign gpio_in = mprj_io_in[M];
   assign mprj_io_out[M] = 1'b0;
   assign mprj_io_oeb[M] = 1'b1;  // Disable output
   ```

3. **Update this documentation** with the new pad assignments.

## Summary

This design requires **no external GPIO pads** for normal operation. All peripheral access occurs via:
- **Wishbone bus** for register access
- **user_irq[0]** for interrupt signaling

This approach minimizes pad usage and keeps the external interface simple while providing full cryptographic acceleration capabilities.
