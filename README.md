# galpal - Verilog GAL and PAL models

These models are designed to assist in simulating obsolete 5V GAL and PAL series parts.

## Usage

### .jed to Verilog

To build a Verilog model from a JEDEC fusemap (`*.jed`) file:

```bash
perl galpal.pl MODEL_NAME model.jed >model.v
```

The `MODEL_NAME` is the desired top-level Verilog module name to be created in `model.v`.

Generated models only require the `galpal_22V10.v` or `galpal_16R8.v` helper models for instantiation (in the `rtl/` directory).

Example 22V10 and 16R8 JEDEC fusemaps are in the `test/` directory.

### .pld to Verilog

To build a model from a PLD functional description (`*.pld`), you can use [GALasm](https://github.com/daveho/GALasm) to compile from
the PLD description to a JEDEC fuse map, then convert to a Verilog wrapper, as follows:

```bash
galasm -c -f -p model.pld
perl galpal.pl MODEL_NAME model.jed >model.v
```

## DIP Pin Ordering

### 22V10 (PAL22V10, GAL22V10, GAL22LV10, etc)

| DIP | Pin | Model Signal |
| --- | --- | ------------ |
| 1 | `I/CLK` | `I[0]` |
| 2 | `I` | `I[1]` |
| 3 | `I` | `I[2]` |
| 4 | `I` | `I[3]` |
| 5 | `I` | `I[4]` |
| 6 | `I` | `I[5]` |
| 7 | `I` | `I[6]` |
| 8 | `I` | `I[7]` |
| 9 | `I` | `I[8]` |
| 10| `I` | `I[9]` |
| 11| `I` | `I[10]` |
| 12| `GND` | `GND` |
| 13| `I` | `I[11]` |
| 14| `I/O/Q` | `IOQ[0]` |
| 15| `I/O/Q` | `IOQ[1]` |
| 16| `I/O/Q` | `IOQ[2]` |
| 17| `I/O/Q` | `IOQ[3]` |
| 18| `I/O/Q` | `IOQ[4]` |
| 19| `I/O/Q` | `IOQ[5]` |
| 20| `I/O/Q` | `IOQ[6]` |
| 21| `I/O/Q` | `IOQ[7]` |
| 22| `I/O/Q` | `IOQ[8]` |
| 23| `I/O/Q` | `IOQ[9]` |
| 24| `VCC` | `VCC` |

### 16R8 (PAL16R8)

| DIP | Pin | Model Signal |
|---- | --- | ------------ |
| 1 | `CLK` | `CLK` |
| 2 | `I1` | `I[1]` |
| 3 | `I2` | `I[2]` |
| 4 | `I3` | `I[3]` |
| 5 | `I4` | `I[4]` |
| 6 | `I5` | `I[5]` |
| 7 | `I6` | `I[6]` |
| 8 | `I7` | `I[7]` |
| 9 | `I8` | `I[8]` |
| 10| `GND` |` GND` |
| 11| `_OE` |` _OE` |
| 12| `O1` | `O[1]` |
| 13| `O2` | `O[2]` |
| 14| `O3` | `O[3]` |
| 15| `O4` | `O[4]` |
| 16| `O5` | `O[5]` |
| 17| `O6` | `O[6]` |
| 18| `O7` | `O[7]` |
| 19| `O8` | `O[8]` |
| 20| `VCC` | `VCC` |
