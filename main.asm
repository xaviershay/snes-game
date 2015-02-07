;== Include memorymap, header info, and SNES initialization routines
.INCLUDE "header.asm"
.INCLUDE "init.asm"
.INCLUDE "constants.asm"

;========================
; Start
;========================

.ENUM $0000
current_color db
.ENDE

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Start:
  Snes_Init           ; Init Snes :)

  stz reg_cgadd       ; Edit color 0, which is the screen color
  stz current_color

  ; Temporary different initial color
  lda $04
  sta current_color

  ; TODO: This should happen on vblank
  jsl paint_background

  lda #$0F
  sta reg_inidisp     ; Turn on screen, full brightness

forever:
  wai
  jmp forever

; TODO: Not sure this is even getting called
VBlank:
  lda $4212	; get joypad status
  and #%00000001	; if joy is not ready
  bne VBlank	; wait
  lda $4219	; read joypad (BYSTudlr)
  beq ++; if zero, we're done

  lda current_color
  inc A
  inc A
  cmp #06
  bcc +
  and #0
+ sta current_color

  jsl paint_background
++ rti

paint_background:
  stz reg_cgadd       ; Edit color 0, which is the screen color
  ldx current_color
  inx
  lda :colors,x
  sta reg_cgdata
  dex
  lda :colors,x
  sta reg_cgdata
  rtl

colors:

.DB %00000011, %11100000 ; Green
.DB %00000000, %00011111 ; Red
.DB %01111100, %00000000 ; Blue

.ENDS
