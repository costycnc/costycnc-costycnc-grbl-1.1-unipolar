
# Control Pin Parasite Activation Fix

![Status](https://img.shields.io/badge/Status-Fixed-brightgreen.svg) ![Issue](https://img.shields.io/badge/Issue-Parasite%20Pins-red.svg) ![Solution](https://img.shields.io/badge/Solution-Comment%20Out-blue.svg)

## 📖 Description

This document explains why specific lines of code were **commented out / deactivated** in the `system_control_get_state()` function.

The issue: **Control pins were activating by themselves (parasite activation)** without any physical button being pressed!

## 🐛 The Problem

### Original problematic code:

```c
uint8_t system_control_get_state()
{
  uint8_t control_state = 0;
  uint8_t pin = (CONTROL_PIN & CONTROL_MASK) ^ CONTROL_MASK;
  #ifdef INVERT_CONTROL_PIN_MASK
    pin ^= INVERT_CONTROL_PIN_MASK;
  #endif
  if (pin) {
    #ifdef ENABLE_SAFETY_DOOR_INPUT_PIN
      if (bit_istrue(pin,(1<<CONTROL_SAFETY_DOOR_BIT))) { control_state |= CONTROL_PIN_INDEX_SAFETY_DOOR; }
    #else
      // THIS LINE WAS CAUSING PROBLEMS ↓↓↓
      if (bit_istrue(pin,(1<<CONTROL_FEED_HOLD_BIT))) { control_state |= CONTROL_PIN_INDEX_FEED_HOLD; }
    #endif
    if (bit_istrue(pin,(1<<CONTROL_RESET_BIT))) { control_state |= CONTROL_PIN_INDEX_RESET; }
    if (bit_istrue(pin,(1<<CONTROL_CYCLE_START_BIT))) { control_state |= CONTROL_PIN_INDEX_CYCLE_START; }
  }
  return(control_state);
}
```

### What was happening:

The function was reading control pins (Feed Hold, Reset, Cycle Start, Safety Door) and **activating them randomly** - even when no button was physically pressed!

## 🔍 Root Causes of Parasite Activations

| Cause | Explanation |
|-------|-------------|
| **Missing pull-up/pull-down resistors** | Pins float to random values without proper resistors |
| **Incorrect logic inversion** | `INVERT_CONTROL_PIN_MASK` might invert when it shouldn't |
| **Wrong bit mask** | `CONTROL_MASK` may include unused pins |
| **Normally closed (NC) pins** | An NC pin with nothing connected reads as 1 (triggered) |
| **Electrical noise** | Interference on unconnected pins |
| **Pin not initialized** | Reading a pin before setting its mode |

## ✅ The Solution

All problematic control pin readings were **commented out**:

```c
uint8_t system_control_get_state()
{
  uint8_t control_state = 0;
  /*
  uint8_t pin = (CONTROL_PIN & CONTROL_MASK) ^ CONTROL_MASK;
  #ifdef INVERT_CONTROL_PIN_MASK
    pin ^= INVERT_CONTROL_PIN_MASK;
  #endif
  if (pin) {
    #ifdef ENABLE_SAFETY_DOOR_INPUT_PIN
      if (bit_istrue(pin,(1<<CONTROL_SAFETY_DOOR_BIT))) { control_state |= CONTROL_PIN_INDEX_SAFETY_DOOR; }
    #else
      //if (bit_istrue(pin,(1<<CONTROL_FEED_HOLD_BIT))) { control_state |= CONTROL_PIN_INDEX_FEED_HOLD; }
    #endif
    if (bit_istrue(pin,(1<<CONTROL_RESET_BIT))) { control_state |= CONTROL_PIN_INDEX_RESET; }
    if (bit_istrue(pin,(1<<CONTROL_CYCLE_START_BIT))) { control_state |= CONTROL_PIN_INDEX_CYCLE_START; }
  }
  */
  return(control_state);  // Always returns 0 - no phantom activations!
}
```

### What the fix does:

- Disables ALL control pin readings
- Function always returns `0` (no button pressed)
- Eliminates all parasite/false activations

## 📊 Before vs After

| Situation | BEFORE (original) | AFTER (commented) |
|-----------|-------------------|-------------------|
| Feed Hold | Activates randomly | ✅ Never activates |
| Reset | Triggers by itself | ✅ Never triggers |
| Cycle Start | Starts without command | ✅ Never starts automatically |
| Safety Door | False alarms possible | ✅ No false alarms |
| Machine stability | Unpredictable | ✅ Rock solid |

## ⚠️ Side Effect of This Fix

By commenting out these lines, **all physical control buttons are disabled**. The machine will no longer respond to:
- Feed Hold button
- Reset button  
- Cycle Start button
- Safety Door input

The machine can only be controlled via software/G-code commands.

## 🔧 Better Solutions (if you want to re-enable later)

Instead of commenting everything out, consider these more elegant fixes:

### Solution 1: Add pull-up resistors

```c
// In initialization code:
pinMode(CONTROL_FEED_HOLD_PIN, INPUT_PULLUP);
pinMode(CONTROL_RESET_PIN, INPUT_PULLUP);
pinMode(CONTROL_CYCLE_START_PIN, INPUT_PULLUP);
```

### Solution 2: Add debounce delay

```c
if (bit_istrue(pin, (1<<CONTROL_FEED_HOLD_BIT))) {
    delay(50);  // Debounce delay
    if (bit_istrue(pin, (1<<CONTROL_FEED_HOLD_BIT))) {
        control_state |= CONTROL_PIN_INDEX_FEED_HOLD;
    }
}
```

### Solution 3: Verify pins are defined

```c
#ifdef CONTROL_FEED_HOLD_PIN_DEFINED
    if (bit_istrue(pin, (1<<CONTROL_FEED_HOLD_BIT))) {
        control_state |= CONTROL_PIN_INDEX_FEED_HOLD;
    }
#endif
```

### Solution 4: Add pin verification

```c
// Only read if pin is actually connected
if (pin != 0xFF) {  // 0xFF = no pins configured
    if (bit_istrue(pin, (1<<CONTROL_FEED_HOLD_BIT))) {
        control_state |= CONTROL_PIN_INDEX_FEED_HOLD;
    }
}
```

### Solution 5: Fix inversion mask

```c
// Check if inversion is correct
#ifdef INVERT_CONTROL_PIN_MASK
    // Make sure the mask matches your hardware
    #if INVERT_CONTROL_PIN_MASK != 0x00
        pin ^= INVERT_CONTROL_PIN_MASK;
    #endif
#endif
```

## 🎯 Summary

| Aspect | Detail |
|--------|--------|
| **Problem** | Control pins activating randomly (parasite activation) |
| **Symptoms** | Random feed holds, resets, cycle starts without user input |
| **Root cause** | Floating pins, incorrect inversion, missing pull-ups |
| **Fix applied** | Commented out all control pin reading code |
| **Result** | No more phantom activations |
| **Trade-off** | Physical control buttons are disabled |

## 📝 Why "Parasite" Activation?

The term "parasite" is appropriate because:
- The activation appears from **nowhere** (like a parasite)
- It **feeds on** electrical noise or floating pin states
- It **attaches itself** to the normal control flow
- It causes **unwanted behavior** that doesn't originate from user input

## 🔧 When to Remove the Comments

Only uncomment these lines when:
1. ✅ Pull-up/pull-down resistors are properly installed
2. ✅ Pin inversion masks are correctly configured
3. ✅ All control pins are properly wired
4. ✅ Debounce logic is added
5. ✅ You have tested each pin individually

## 📄 License

This documentation is for educational purposes - use at your own risk!

---

**Parasite pins eliminated! Machine now stable!** 🎯🔧🛡️

system.c line 43 to 57 commented (skip)  

	// Returns control pin state as a uint8 bitfield. Each bit indicates the input pin state, where
	// triggered is 1 and not triggered is 0. Invert mask is applied. Bitfield organization is
    	// defined by the CONTROL_PIN_INDEX in the header file.
    	 uint8_t system_control_get_state()
    	{
      uint8_t control_state = 0;
      /*
     uint8_t pin = (CONTROL_PIN & CONTROL_MASK) ^ CONTROL_MASK;
     #ifdef INVERT_CONTROL_PIN_MASK
    pin ^= INVERT_CONTROL_PIN_MASK;
     #endif
  
     if (pin) {
	  printString("bla");
    #ifdef ENABLE_SAFETY_DOOR_INPUT_PIN
      if (bit_istrue(pin,(1<<CONTROL_SAFETY_DOOR_BIT))) { control_state |= CONTROL_PIN_INDEX_SAFETY_DOOR; }
    #else
      if (bit_istrue(pin,(1<<CONTROL_FEED_HOLD_BIT))) {
		  //control_state |= CONTROL_PIN_INDEX_FEED_HOLD; 
		  	  printString("bla_hold");
		  }
    #endif
    if (bit_istrue(pin,(1<<CONTROL_RESET_BIT))) { 
	//control_state |= CONTROL_PIN_INDEX_RESET; 
    	  printString("bla_reset");
    }
    if (bit_istrue(pin,(1<<CONTROL_CYCLE_START_BIT))) { 
	control_state |= CONTROL_PIN_INDEX_CYCLE_START; 
	printString("bla_start");
	}
    }
    */ 
       return(control_state);
    }

