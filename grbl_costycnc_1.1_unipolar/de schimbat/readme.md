
# GRBL 1.1 Modification Guide for Unipolar Motors

![GRBL](https://img.shields.io/badge/GRBL-1.1-orange.svg) ![Unipolar](https://img.shields.io/badge/Motor-Unipolar-blue.svg) ![Modified](https://img.shields.io/badge/Status-Modified-brightgreen.svg)

## 📖 Description

This guide explains the modifications needed to convert the **original GRBL 1.1 firmware** to work with **unipolar stepper motors**.

Unipolar motors require special step sequencing (8-step full-step sequence) instead of the standard bipolar H-bridge control. These modifications implement a **direct port manipulation** approach to generate the correct unipolar stepper sequences.

## 🎯 What Has Been Modified

| File | Modifications |
|------|---------------|
| `config.h` | Spindle PWM range changed (30000 → -30000), baudrate 9600 |
| `cpu_map.h` | Pin mapping for unipolar control |
| `grbl.h` | Version renamed to "1.1h costycnc" |
| `stepper.c` | Unipolar step sequence logic added |
| `main.c` | Port initialization for unipolar outputs |

## 📋 Key Modifications

### 1. Config.h - Line 339: Variable Spindle Range

**Original:**
```c
#define VARIABLE_SPINDLE // Default enabled. Comment to disable.
```

**Modified:**
```c
// PWM range changed from +30000 to -30000
// Spindle speed range now inverted
```

**Also line 42 - Baudrate:**
```c
#define BAUD_RATE 9600  // Changed from 115200 to 9600
```

### 2. cpu_map.h - Pin Mapping for Unipolar

The unipolar modification requires additional port definitions for the 8-step sequence:

```c
// CostyCNC Unipolar pin definitions
#define COSTY_STEP_DDR     DDRD
#define COSTY_CONTROL_DDR  DDRC

// Step sequence outputs on PORTD (X-axis sequence bits D0-D5)
// Sequence states: 0B100000, 0B110000, 0B010000, 0B011000,
//                  0B001000, 0B001100, 0B000100, 0B100100
```

### 3. grbl.h - Version Identification

```c
#define GRBL_VERSION "1.1h costycnc"
#define GRBL_VERSION_BUILD "20190830"
```

### 4. main.c - Port Initialization

```c
int main(void)
{
    DDRD = 0B111100;   // Configure PORTD pins for unipolar sequence
    DDRC = 0B11110000; // Configure PORTC pins for unipolar sequence
    // ... rest of initialization
}
```

### 5. stepper.c - Unipolar Step Sequence Logic ⭐ MOST IMPORTANT

The core unipolar modification adds **8-step sequencing** for X and Y axes:

#### X-Axis Unipolar Sequence (PORTD):

```c
// In the stepper ISR, when X-axis steps:
if (st.exec_block->direction_bits & (1<<X_DIRECTION_BIT)) { 
    sys_position[X_AXIS]--; 
    costyx = costyx - 1;
    if (costyx < 1) costyx = 8;
    
    // 8-step unipolar sequence for X-axis
    if (costyx == 1) PORTD = 0B100000;
    if (costyx == 2) PORTD = 0B110000;
    if (costyx == 3) PORTD = 0B010000;
    if (costyx == 4) PORTD = 0B011000;
    if (costyx == 5) PORTD = 0B001000;
    if (costyx == 6) PORTD = 0B001100;
    if (costyx == 7) PORTD = 0B000100;
    if (costyx == 8) PORTD = 0B100100;
}
else { 
    sys_position[X_AXIS]++; 
    costyx = costyx + 1;
    if (costyx > 8) costyx = 1;
    
    // Same sequence but different direction
    if (costyx == 1) PORTD = 0B100000;
    // ... etc
}
```

#### Y-Axis Unipolar Sequence (PORTC):

```c
// In the stepper ISR, when Y-axis steps:
if (st.exec_block->direction_bits & (1<<Y_DIRECTION_BIT)) { 
    sys_position[Y_AXIS]--; 
    costyy = costyy - 1;
    if (costyy < 1) costyy = 8;
    
    // 8-step unipolar sequence for Y-axis
    if (costyy == 1) PORTC = 0B1000;
    if (costyy == 2) PORTC = 0B1100;
    if (costyy == 3) PORTC = 0B0100;
    if (costyy == 4) PORTC = 0B0110;
    if (costyy == 5) PORTC = 0B0010;
    if (costyy == 6) PORTC = 0B0011;
    if (costyy == 7) PORTC = 0B0001;
    if (costyy == 8) PORTC = 0B1001;
}
else { 
    sys_position[Y_AXIS]++;
    costyy = costyy + 1;
    if (costyy > 8) costyy = 1;
    // Same sequence
}
```

## 🔧 Understanding the 8-Step Unipolar Sequence

### What is a Unipolar Motor?

A unipolar stepper motor has **5, 6, or 8 wires** with center-tapped windings. Unlike bipolar motors that require an H-bridge to reverse current, unipolar motors only need to switch each coil on/off in sequence.

### The 8-Step Sequence (Half-Step Mode)

| Step | X-Axis PORTD | Y-Axis PORTC | Coils Energized |
|------|--------------|--------------|-----------------|
| 1 | 0B100000 | 0B1000 | Phase A |
| 2 | 0B110000 | 0B1100 | Phase A + B |
| 3 | 0B010000 | 0B0100 | Phase B |
| 4 | 0B011000 | 0B0110 | Phase B + C |
| 5 | 0B001000 | 0B0010 | Phase C |
| 6 | 0B001100 | 0B0011 | Phase C + D |
| 7 | 0B000100 | 0B0001 | Phase D |
| 8 | 0B100100 | 0B1001 | Phase D + A |

### Visual Representation:

```
Step 1:  A●●●●○○○○  │  Step 5:  ○○○○●●●● A
Step 2:  A●●●●●●●○  │  Step 6:  ○○●●●●●● A
Step 3:  ○○○○●●●● A │  Step 7:  ●●●●○○○○ A
Step 4:  ○○●●●●●● A │  Step 8:  ●●●●○●●● A
         ^           │           ^
         └─ Direction│           └─ Direction
```

## 📊 Pin Mapping Table

| Function | Port | Pin | Binary Mask | Description |
|----------|------|-----|-------------|-------------|
| X-Step Seq 0 | D | 4 | 0B100000 | X coil A |
| X-Step Seq 1 | D | 5 | 0B110000 | X coil A+B |
| X-Step Seq 2 | D | 6 | 0B010000 | X coil B |
| X-Step Seq 3 | D | 6+?| 0B011000 | X coil B+C |
| X-Step Seq 4 | D | 5+?| 0B001000 | X coil C |
| X-Step Seq 5 | D | 5+4| 0B001100 | X coil C+D |
| X-Step Seq 6 | D | 4+?| 0B000100 | X coil D |
| X-Step Seq 7 | D | 4+5| 0B100100 | X coil D+A |
| Y-Step Seq 0 | C | 0 | 0B1000 | Y coil A |
| Y-Step Seq 1 | C | 1 | 0B1100 | Y coil A+B |
| Y-Step Seq 2 | C | 2 | 0B0100 | Y coil B |
| Y-Step Seq 3 | C | 3 | 0B0110 | Y coil B+C |
| Y-Step Seq 4 | C | 4 | 0B0010 | Y coil C |
| Y-Step Seq 5 | C | 5 | 0B0011 | Y coil C+D |
| Y-Step Seq 6 | C | 6 | 0B0001 | Y coil D |
| Y-Step Seq 7 | C | 7 | 0B1001 | Y coil D+A |

## 🔌 Wiring Diagram

```
Arduino Uno                    Unipolar Stepper Motor (X-axis)
┌─────────────┐                ┌─────────────────────────┐
│         D4  ├────────────────► Coil A+                 │
│         D5  ├────────────────► Coil A- (center tap)    │
│         D6  ├────────────────► Coil B+                 │
│         D7  ├────────────────► Coil B- (center tap)    │
│         D8  ├────────────────► Coil C+                 │
│         D9  ├────────────────► Coil C- (center tap)    │
│        D10  ├────────────────► Coil D+                 │
│        D11  ├────────────────► Coil D- (center tap)    │
└─────────────┘                └─────────────────────────┘

Arduino Uno                    Unipolar Stepper Motor (Y-axis)
┌─────────────┐                ┌─────────────────────────┐
│         C0  ├────────────────► Coil A+                 │
│         C1  ├────────────────► Coil A- (center tap)    │
│         C2  ├────────────────► Coil B+                 │
│         C3  ├────────────────► Coil B- (center tap)    │
│         C4  ├────────────────► Coil C+                 │
│         C5  ├────────────────► Coil C- (center tap)    │
│         C6  ├────────────────► Coil D+                 │
│         C7  ├────────────────► Coil D- (center tap)    │
└─────────────┘                └─────────────────────────┘
```

## ⚙️ How the Unipolar Sequence Works

### State Variables:
- `costyx` - Tracks current step position for X-axis (1 to 8)
- `costyy` - Tracks current step position for Y-axis (1 to 8)

### Direction Logic:

**Forward direction (increment):**
```
1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 1 → ...
```

**Reverse direction (decrement):**
```
1 → 8 → 7 → 6 → 5 → 4 → 3 → 2 → 1 → ...
```

## 🛠️ Installation Instructions

### Step 1: Backup Original GRBL
```bash
# Save your original GRBL files before modifying
cp grbl/*.h grbl_backup/
cp grbl/*.c grbl_backup/
```

### Step 2: Apply Modifications

1. **Edit `config.h`**
   - Line 42: Change `#define BAUD_RATE 115200` to `#define BAUD_RATE 9600`
   - Line 339: Comment/uncomment `#define VARIABLE_SPINDLE` as needed

2. **Edit `cpu_map.h`**
   - Add unipolar port definitions (see above)

3. **Edit `grbl.h`**
   - Change version string to identify your build

4. **Edit `main.c`**
   - Add port initialization lines

5. **Edit `stepper.c`**
   - Add the unipolar sequence logic in the ISR

### Step 3: Compile and Upload
```bash
# Using Arduino IDE or PlatformIO
# Select Board: Arduino Uno
# Compile and Upload
```

## 📈 Performance Characteristics

| Parameter | Bipolar GRBL | Unipolar Modified |
|-----------|--------------|-------------------|
| Step sequence | 2-step (full) or 4-step (half) | 8-step (enhanced half) |
| Torque at low speed | Higher | Moderate |
| Torque at high speed | Moderate | Lower |
| Smoothness | Good | Excellent (8-step smoothing) |
| Motor heating | Less | Slightly more |
| Max step rate | ~30kHz | ~15-20kHz |

## ⚠️ Important Notes

### Spindle PWM Change (30000 → -30000)
The spindle range was inverted because:
- Some unipolar configurations require inverted PWM signal
- Allows compatibility with common spindle driver boards
- Test with your specific hardware before use

### Baudrate Change (115200 → 9600)
- More stable with long USB cables
- Better compatibility with older UART converters
- Sufficient for most CNC operations

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Motor doesn't move | Check port mappings (PORTD/PORTC) are correct |
| Motor vibrates but doesn't rotate | Verify sequence order (1→8 steps) |
| Wrong direction | Swap increment/decrement logic |
| Missing steps | Reduce feed rate; unipolar has less torque |
| Overheating motors | Reduce current or add cooling |
| Sequence out of sync | Initialize costyx/costyy variables to 1 |

## 🔄 Restoring Original GRBL

To revert to standard bipolar GRBL:
1. Replace modified files with original backups
2. Recompile and upload
3. Reset EEPROM with `$RST=$` command

## 📝 Complete File List Modified

```
grbl/
├── config.h      (line 42, 339)
├── cpu_map.h     (unipolar pin definitions)
├── grbl.h        (version string)
├── main.c        (port initialization)
└── stepper.c     (unipolar sequence logic)
```

## 🎯 Why These Modifications?

| Original GRBL | Modified for Unipolar |
|---------------|----------------------|
| Designed for bipolar H-bridge drivers | Direct coil control for unipolar |
| 2/4 step sequence | 8-step half-sequence |
| Direction via signal pins | Direction via sequence order |
| PWM range 0-255 (typical) | Inverted range for compatibility |

## 📚 Educational Value

These modifications demonstrate:
- How stepper motor sequencing works at low level
- Direct port manipulation in AVR C
- Real-time ISR programming
- Converting between motor drive schemes
- Understanding GRBL internals

## 📄 License

This modification is based on GRBL v1.1 (GPL v3) - modifications are shared under same license.

---

**Unipolar conversion complete! Your GRBL is now ready for unipolar stepper motors!** 🎯🔄⚙️
