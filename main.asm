;== Include memorymap, header info, and SNES initialization routines
.INCLUDE "header.asm"
.INCLUDE "init.asm"
.INCLUDE "constants.asm"

;========================
; Start
;========================

.ENUM $0000
current_color db
joypad1 db
joypad1_new db
joypad1_delta_on db
.ENDE

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Start:
  Snes_Init

  ; Zero out memory
  stz current_color.l
  stz joypad1.l

  jsl paint_background ; Initial paint

  lda #$0F
  sta reg_inidisp ; Turn on screen, full brightness

  lda #%10000001	; enable NMI and joypad
  sta reg_interrupt_enable

forever:
  wai
  jmp forever

; VBlank is called every frame (NMI interrupt)
VBlank:
  ; ===== INPUT PROCESSING
  ; Loop until joypad registers are ready to be read
  lda reg_joy_status
  and #%00000001
  bne VBlank

  lda reg_joy1_h ; read BYSTudlr bits from joypad

  ; Figure out any buttons that have just been depressed, store in delta_on
  sta joypad1_new
  eor joypad1
  and joypad1_new
  sta joypad1_delta_on
  lda joypad1_new
  sta joypad1

  ; ===== LOGIC
  ; If B has not been newly pressed, skip to end.
  lda joypad1_delta_on
  and #%10000000
  beq ++

  ; Increment color twice because each color is 2 bytes long.
  lda current_color
  inc A
  inc A

  ; If color is greater than 6 (3 colors) reset to 0
  cmp #06
  bcc +
  and #0

+ sta current_color

  jsl paint_background

++ rti

paint_background:
  stz reg_cgadd       ; Edit color 0, which is the screen color
  ldx current_color
  lda Colors.l+1,x
  sta reg_cgdata
  lda Colors.l,x
  sta reg_cgdata
  rtl

Colors:

.DB %00000011, %11100000 ; Green
.DB %00000000, %00011111 ; Red
.DB %01111100, %00000000 ; Blue

.ENDS
