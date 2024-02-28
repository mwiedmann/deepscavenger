.org $080D
.segment "ONCE"

.include "x16.inc"
.include "config.inc"

    jmp start

timebyte: .byte 0
spritex: .word 600
spritey: .word 440
default_irq: .word 0
waitflag: .byte 0

start:
    jsr irq_config
    jsr config
    jsr create_tiles
    jsr clear_tiles
    jsr create_sprite
@move:
    jsr move_sprite
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    lda #0
    sta waitflag
    bra @move

irq_routine:
    lda VERA_ISR
    and #1
    beq @continue
    lda #1
    sta waitflag ; Signal that its ok to draw now
    ora VERA_ISR
    sta VERA_ISR
@continue:
    jmp (default_irq)

irq_config:
    sei
    ; First, capture the default IRQ handler
    ; This is so we can call it after our custom handler
    lda IRQ_FUNC_ADDR
    sta default_irq
    lda IRQ_FUNC_ADDR+1
    sta default_irq+1
    ; Now replace it with our custom handler
    lda #<irq_routine
    sta IRQ_FUNC_ADDR
    lda #>irq_routine
    sta IRQ_FUNC_ADDR+1
    ; Turn on VSYNC
    lda #1
    sta VERA_IEN
    cli
    rts

config:
    lda #VERA_DC_VIDEO_BITS
    sta VERA_DC_VIDEO
    lda #VERA_L1_CONFIG_BITS
    sta VERA_L1_CONFIG
    lda #VERA_L1_MAPBASE_BITS
    sta VERA_L1_MAPBASE
    lda #VERA_L1_TILEBASE_BITS
    sta VERA_L1_TILEBASE
    rts

; Create 2 tiles
; 1 black, 1 another color
create_tiles:
    lda #<TILEBASE_ADDR
    sta VERA_ADDR_LO
    lda #>TILEBASE_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET

    ldx #0
    lda #0
@loop:
    sta VERA_DATA0
    inx
    cpx #0
    bne @loop
    inc ; Inc the tile color
    cmp #TILE_COUNT ; stop after this many tiles
    bne @loop
    rts

point_to_mapbase:
    pha
    lda #<MAPBASE_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    pla
    rts

clear_tiles:
    jsr point_to_mapbase
    lda #0
    ldy #0
@outer:
    ldx #0
@loop:
    sta VERA_DATA0
    sta VERA_DATA0
    inx
    cpx #TILES_PER_ROW
    bmi @loop
@next_row:
    iny
    cpy #TILES_PER_COL
    bmi @outer
    rts

point_to_sprite:
    lda #<SPRITE_ADDR
    sta VERA_ADDR_LO
    lda #>SPRITE_ADDR
    sta VERA_ADDR_MID
    lda #(VERA_ADDR_HI_INC_BITS+1) ; Sprites are in 2nd bank of VRAM
    sta VERA_ADDR_HI_SET
    rts

create_sprite:
    jsr point_to_sprite
    lda #SPRITE_GFX_ADDR_LO
    sta VERA_DATA0
    lda #SPRITE_GFX_ADDR_HI
    sta VERA_DATA0
    lda spritex ; X
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda spritey ; Y
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%10100000 ; 32x32 pixels
    sta VERA_DATA0
    rts

move_sprite:
    lda #0
    jsr JOYGET
    pha
    bit #%1000
    bne @check_y_down
    lda spritey
    sec
    sbc #SPRITE_SPEED
    sta spritey
    lda spritey+1
    sbc #0
    sta spritey+1
    jmp @check_x_left
@check_y_down:
    bit #%100
    bne @check_x_left
    lda spritey
    clc
    adc #SPRITE_SPEED
    sta spritey
    lda spritey+1
    adc #0
    sta spritey+1
@check_x_left:
    pla
    bit #%10
    bne @check_x_right
    lda spritex
    sec
    sbc #SPRITE_SPEED
    sta spritex
    lda spritex+1
    sbc #0
    sta spritex+1
    jmp @update_sprite
@check_x_right:
    bit #%1
    bne @update_sprite
    lda spritex
    clc
    adc #SPRITE_SPEED
    sta spritex
    lda spritex+1
    adc #0
    sta spritex+1
@update_sprite:
    jsr point_to_sprite
    lda VERA_DATA0 ; skip byte
    lda VERA_DATA0 ; skip byte
    lda spritex
    sta VERA_DATA0
    lda spritex+1
    sta VERA_DATA0
    lda spritey
    sta VERA_DATA0
    lda spritey+1
    sta VERA_DATA0
@done:
    rts

