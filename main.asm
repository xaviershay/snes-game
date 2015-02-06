;== Include memorymap, header info, and SNES initialization routines
.INCLUDE "header.asm"
.INCLUDE "init.asm"

;========================
; Start
;========================

.BANK 0 SLOT 0
.ORG 0
.SECTION "MainCode"

Start:
        Snes_Init            ; Init Snes :)

        stz $2121           ; Edit color 0 - snes' screen color you can write it in binary or hex
        lda #%00011111      ; binary is more visual, but if you wanna be cool, use hex ;)
        sta $2122
        stz $2122           ; second byte has no data, so we write a 0

        lda #$0F            ; = 00001111
        sta $2100           ; Turn on screen, full brightness

forever:
        jmp forever

.ENDS
