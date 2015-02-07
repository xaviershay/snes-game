; http://wiki.superfamicom.org/snes/show/Registers
.ENUM $2100 EXPORT
reg_inidisp db
.ENDE

.ENUM $2121 EXPORT
reg_cgadd db
reg_cgdata db
.ENDE

.DEFINE reg_interrupt_enable $4200
.EXPORT reg_interrupt_enable

; This is listed as PPU register. Why do we read this for joypad ready? Why not
; IO port?
.DEFINE reg_joy_status $4212
.EXPORT reg_joy_status

.DEFINE reg_joy1_h $4219
.EXPORT reg_joy1_h
