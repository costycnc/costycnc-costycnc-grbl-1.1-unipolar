# CostyCNC GRBL 1.1h – Unipolar Stepper Motor Firmware

Custom **GRBL 1.1h firmware for CNC machines using unipolar stepper motors**, with ready-to-flash HEX files for Arduino/ATmega328P-based controllers.

The firmware is designed for the **unipolar stepper motor category**, not for one specific motor model. The **28BYJ-48 is one example of a unipolar stepper motor** that can be used in this type of application.

This repository is useful when a CNC controller uses unipolar stepper motors and standard GRBL needs to be adapted for that hardware.

## What problem does this solve?

This project addresses practical CNC firmware problems such as:

- using **unipolar stepper motors with GRBL 1.1h**;
- using motors such as the **28BYJ-48** in an appropriate unipolar CNC setup;
- correcting an axis that moves in the wrong direction;
- choosing between **250000 baud and 9600 baud** firmware;
- flashing a ready-made GRBL HEX file instead of compiling the firmware;
- adapting an Arduino/ATmega328P CNC controller for a specific machine configuration.

If you are looking for:

- "GRBL for unipolar stepper motors"
- "GRBL 1.1h unipolar motor"
- "GRBL for 28BYJ-48"
- "Arduino CNC unipolar stepper firmware"
- "28BYJ-48 CNC firmware"
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

## Unipolar motors and the 28BYJ-48

**Unipolar stepper motor** is the general hardware category targeted by this project.

The **28BYJ-48** is a well-known example of a small unipolar stepper motor. Mentioning it here does not mean that the firmware is limited to the 28BYJ-48.

The important point is that **motor size, power, current, wiring and controller electronics can be very different between unipolar motors**. Therefore, this repository should not be interpreted as saying that a large unipolar motor and a 28BYJ-48 are electrically interchangeable.

The firmware describes the **motor-control architecture**; the actual motor driver, wiring and electrical configuration must match the motor and machine being used.

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

This repository contains a combination that is more concrete than a generic GRBL description:

1. **A specific hardware category** — unipolar stepper motors.
2. **A concrete example** — 28BYJ-48.
3. **A GRBL 1.1h firmware base**.
4. **A hardware adaptation** in source code.
5. **Two axis-direction variants**.
6. **Two serial communication speeds**.
7. **Pre-compiled HEX files** that can be flashed directly.

This makes the repository a useful reference when trying to answer a practical question such as:

> "I have an Arduino-based CNC controller with a unipolar stepper motor. Is there a GRBL firmware I can flash?"

Or:

> "Can I use GRBL with a 28BYJ-48 in a suitable CNC hardware configuration?"

The repository can then be inspected to determine which firmware variant and hardware configuration are appropriate.

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
3. Verify that the motor driver and wiring are suitable for the unipolar motor being used.
4. Flash the corresponding `.hex` file to the Arduino/ATmega328P controller.
5. Configure the CNC control software to use the same baud rate.
6. Test X/Y movement before running a complete job.

## Important limitation

This firmware is **hardware-specific**.

It should not be assumed that every Arduino CNC controller or every unipolar stepper motor will use the same wiring, pin mapping, electrical configuration, driver or firmware modification.

A **28BYJ-48 and a high-power unipolar stepper motor are both unipolar motors, but they are not interchangeable electrical systems**.

The repository documents one concrete GRBL adaptation. Verify the controller hardware, motor driver, current requirements and pin configuration before flashing.

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

**GRBL 1.1h adapted for unipolar stepper motors, with 28BYJ-48 as one example application, axis-direction variants, and ready-to-flash 250k/9600-baud HEX files.**
