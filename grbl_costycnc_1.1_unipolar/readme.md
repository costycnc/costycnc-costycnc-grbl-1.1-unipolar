
system.c line 43 to 68 comented (skip)     
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
