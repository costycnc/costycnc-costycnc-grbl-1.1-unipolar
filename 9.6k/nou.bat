echo off
cls
set /p UserInputPath= Insert your port where costycnc is connected (example com1)


mode %UserInputPath% BAUD=9600 PARITY=n DATA=8
    echo E > %UserInputPath%
avrdude -p m328p -b 57600 -P %UserInputPath% -c arduino -U flash:w:1.1h_x0_y0_9.6k.hex 

pause 