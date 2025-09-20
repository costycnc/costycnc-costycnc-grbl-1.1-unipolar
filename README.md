# CostyCNC GRBL 1.1 – Unipolar Motors Firmware

**Customized GRBL 1.1h firmware adapted for unipolar stepper motors.**

This project is a fork of the original GRBL 1.1h firmware, modified to work specifically with **unipolar stepper motors**.  
It includes adjustments for axis direction and supports different baud rates for serial communication.

---

## Features

- GRBL 1.1h core firmware with unipolar motor support  
- Two firmware versions for axis correction:  
  - `grbl1.1h_dr_.hex` – fixes axis movement when Y moves in the opposite direction  
  - `grbl1.1h_st_.hex` – standard behavior  
- Supports two baud rates:  
  - 250000 (250k)  
  - 9600 (9.6k)  
- Compatible with standard CNC control software  
- Easy to flash onto Arduino-based CNC controllers  

---

## Installation

1. Connect your Arduino-based CNC controller to the PC.  
2. Select the firmware version that matches your axis setup (`dr` or `st`).  
3. Use a programmer or Arduino IDE to flash the `.hex` file.  
4. Set the correct baud rate in your CNC control software (250k or 9600).  

> Note: Install `grbl1.1h_dr_.hex` if your Y axis moves in the opposite direction; the standard firmware (`st`) works if axes are correct.

---

## File Descriptions

| File | Description |
|------|-------------|
| grbl1.1h_dr_250k.hex | Unipolar firmware with axis correction, 250000 baud |
| grbl1.1h_dr_9.6k.hex | Unipolar firmware with axis correction, 9600 baud |
| grbl1.1h_st_250k.hex | Standard unipolar firmware, 250000 baud |
| grbl1.1h_st_9.6k.hex | Standard unipolar firmware, 9600 baud |

---

## Resources

- Original GRBL 1.1h: [https://github.com/gnea/grbl/releases/tag/v1.1h.20190825](https://github.com/gnea/grbl/releases/tag/v1.1h.20190825)

---

## License

This project is based on GRBL 1.1h and inherits the original license. Please check the [GRBL license](https://github.com/gnea/grbl/blob/master/LICENSE.md) for details.






# costycnc-costycnc-grbl-1.1-unipolar

the difference between grbl1.1h_dr_.hex and grbl1.1h_st_.hex (st and dr) is that if have installed first firmware and axe y move down (incontrary) when click y+ ... need to 

installsecond firmware and will see that axe x working corectly!

250k and 9.6k mean that working with 250000 bauds and 9600 bauds respectively.

original https://github.com/gnea/grbl/releases/tag/v1.1h.20190825

![alt text](https://forum.lightburnsoftware.com/uploads/default/original/2X/6/6a5f22524050223896f839532358658b9ee4d2d5.jpeg)
