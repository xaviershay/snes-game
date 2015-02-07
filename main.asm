;== Include memorymap, header info, and SNES initialization routines
.INCLUDE "header.asm"
.INCLUDE "init.asm"
.INCLUDE "constants.asm"
.INCLUDE "VRAM/LoadGraphics.asm"

;========================
; Start
;========================

.ENUM $0100
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

  rep #%00110000 ; 8-bit A, 16-bit X/Y. Assumed by following macros.

  ; Load Palette for our tiles
  LoadPalette BG_Palette, 0, 16

  ; Load Tile data to VRAM
  LoadBlockToVRAM Tiles, $0000, $0020	; 2 tiles, 2bpp, = 32 bytes

  ; TODO WHAT DOES THIS DO
  lda #$80
  sta $2115
  ldx #$0400	; 5AF
  stx $2116
  lda #$01
  sta $2118

  jsr SetupVideo
  ;jsl paint_background ; Initial paint

  lda #$0F
  sta reg_inidisp ; Turn on screen, full brightness

  lda #%10000001	; enable NMI and joypad
  sta reg_interrupt_enable

forever:
  wai
  jmp forever

SetupVideo:
    php

    lda #$00
    sta $2105           ; Set Video mode 0, 8x8 tiles, 4 color BG1/BG2/BG3/BG4

    lda #$04            ; Set BG1's Tile Map offset to $0400 (Word address)
    sta $2107           ; And the Tile Map size to 32x32

    stz $210B           ; Set BG1's Character VRAM offset to $0000 (word address)

    lda #$01            ; Enable BG1
    sta $212C

    lda #$FF
    sta $210E
    sta $210E

    plp
    rts

Tiles:
    .db $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
    .db $FF, $00, $DB, $00, $DB, $00, $DB, $00, $FF, $00, $7E, $00, $00, $00, $FF, $00

BG_Palette:
    .db $FF, $03, $00, $00, $00, $00, $00, $00

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
  cmp #(const_num_colors*2)
  bcc +
  and #0

+ sta current_color

  jsl paint_background

++ rti

paint_background:
  stz reg_cgadd       ; Edit color 0, which is the screen color
  ldx current_color
  lda Colors.l,x
  sta reg_cgdata
  lda Colors.l+1,x
  sta reg_cgdata
  rtl

Colors:

.INCLUDE "gen/colors.asm"

.ENDS
