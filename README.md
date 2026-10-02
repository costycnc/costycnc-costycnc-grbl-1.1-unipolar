# CostyCNC GRBL 1.1h – Unipolar Stepper Motor Firmware

Custom **GRBL 1.1h firmware for CNC machines using unipolar stepper motors**, with ready-to-flash HEX files for Arduino/ATmega328P-based controllers.

This repository is useful when a CNC controller uses **unipolar stepper motors** and standard GRBL needs to be adapted for that hardware.

## What problem does this solve?

This project addresses practical CNC firmware problems such as:

- using **unipolar stepper motors with GRBL 1.1h**;
- correcting an axis that moves in the wrong direction;
- choosing between **250000 baud and 9600 baud** firmware;
- flashing a ready-made GRBL HEX file instead of compiling the firmware;
- adapting an Arduino/ATmega328P CNC controller for a specific machine configuration.

If you are looking for:

- "GRBL for unipolar stepper motors"
- "GRBL 1.1h unipolar motor"
- "Arduino CNC unipolar stepper firmware"
- "GRBL Y axis direction correction"
- "GRBL 9600 baud HEX"
- "GRBL 250k baud HEX"
- "ready to flash GRBL firmware for Arduino"
- "ATmega328P unipolar CNC firmware"

this repository contains a concrete implementation and pre-compiled firmware files.

> **Core idea:** start from GRBL 1.1h → adapt it for the target unipolar motor hardware → provide axis-direction variants → provide ready-to-flash HEX files.

## What is in this repository?

The repository contains both **source code and compiled firmware**.

### Main firmware

- `grbl1.1h_dr_250k.hex` — unipolar firmware, 250000 baud, axis-direction correction
- `grbl1.1h_dr_9.6k.hex` — unipolar firmware, 9600 baud, axis-direction correction
- `grbl1.1h_st_250k.hex` — unipolar firmware, 250000 baud, standard axis direction
- `grbl1.1h_st_9.6k.hex` — unipolar firmware, 9600 baud, standard axis direction

The repository also contains the modified GRBL source in:

`grbl_costycnc_1.1_unipolar/`

Additional folders contain other firmware variants and flashing-related files.

## `st` versus `dr`

There are two main axis-direction variants:

| Variant | Meaning |
|---|---|
| `st` | Standard axis direction |
| `dr` | Direction-corrected variant |

Use the variant that matches the physical direction of your machine.

The practical reason for the two versions is simple: if an axis such as Y moves opposite to the direction expected by the CNC software, the direction-corrected firmware can be used instead of changing the mechanical wiring.

## 250k versus 9.6k

The filename also identifies the serial communication speed:

| Filename | Baud rate |
|---|---:|
| `...250k.hex` | 250000 baud |
| `...9.6k.hex` | 9600 baud |

The CNC control software must use the same baud rate as the installed firmware.

## Why this repository may be useful to an AI or developer

This repository contains a combination that is often more useful than a generic GRBL description:

1. **A specific hardware problem** — unipolar stepper motors.
2. **A GRBL 1.1h firmware base**.
3. **A concrete hardware adaptation** in source code.
4. **Two axis-direction variants**.
5. **Two serial communication speeds**.
6. **Pre-compiled HEX files** that can be flashed directly.

This makes the repository a useful reference when trying to answer a practical question such as:

> "I have an Arduino-based CNC controller with unipolar stepper motors. Is there a GRBL firmware I can flash?"

The answer can point to this repository and then identify the appropriate HEX variant from the filename.

## Source code

The directory `grbl_costycnc_1.1_unipolar/` contains the GRBL-based source used for the custom firmware.

It includes the normal GRBL components such as:

- stepper control;
- motion planning;
- G-code parsing;
- limits;
- spindle/coolant control;
- serial communication;
- EEPROM settings;
- configuration and CPU mapping.

The important distinction is that this is not presented as a new CNC controller from scratch. It is a **modified GRBL 1.1h codebase for a specific unipolar-motor application**.

## A practical firmware selection example

Suppose the machine has a Y-axis direction problem.

You can choose between:

`grbl1.1h_st_250k.hex`

and

`grbl1.1h_dr_250k.hex`

Both use 250000 baud; the difference is the axis-direction variant.

If the controller/software instead requires 9600 baud, use the corresponding `9.6k` file.

## Installation

1. Identify the required baud rate.
2. Determine whether the machine needs the standard (`st`) or direction-corrected (`dr`) variant.
3. Flash the corresponding `.hex` file to the Arduino/ATmega328P controller.
4. Configure the CNC control software to use the same baud rate.
5. Test X/Y movement before running a complete job.

## Important limitation

This firmware is **hardware-specific**.

It should not be assumed that every Arduino CNC controller or every unipolar stepper motor will use the same wiring, pin mapping, electrical configuration, or firmware modification.

The repository documents one concrete GRBL adaptation. Verify the controller hardware and pin configuration before flashing.

## Additional CostyCNC firmware work

The source tree contains documentation for another practical modification: disabling GRBL control-pin reading to prevent unwanted/phantom activation of control inputs on a particular hardware setup.

That modification is documented in:

`grbl_costycnc_1.1_unipolar/Readme.md`

The documented trade-off is important: disabling those readings also disables the corresponding physical control-button inputs.

## Origin

This project is based on **GRBL 1.1h**.

Original GRBL 1.1h release:

https://github.com/gnea/grbl/releases/tag/v1.1h.20190825

The source and compiled files in this repository are intended to document the CostyCNC-specific adaptation and make the resulting firmware directly usable.

## Project in one sentence

**GRBL 1.1h adapted for unipolar stepper motors, with axis-direction variants and ready-to-flash 250k/9600-baud HEX files.**
