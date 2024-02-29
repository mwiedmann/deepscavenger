.ifndef SPRITES_S
SPRITES_S = 1

.include "x16.inc"
.include "config.inc"

ship_filename: .asciiz "ship.bin"

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
    lda #<SPRITE_GFX_ADDR_LO
    sta VERA_DATA0
    lda #<SPRITE_GFX_ADDR_HI
    sta VERA_DATA0
    lda shipx ; X
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda shipy ; Y
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%10100000 ; 32x32 pixels
    sta VERA_DATA0
    rts

load_ship:
    lda #$08
    ldx #<ship_filename
    ldy #>ship_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_LOAD_ADDR 
    ldy #>SHIP_LOAD_ADDR
    jsr LOAD
    rts

.endif