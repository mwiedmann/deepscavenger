.ifndef TILES_S
TILES_S = 1

.include "x16.inc"
.include "config.inc"

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

; Create 2 tiles
; 1 black, 1 another color
create_tiles:
    lda #<TILEBASE_L1_ADDR
    sta VERA_ADDR_LO
    lda #>TILEBASE_L1_ADDR
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

.endif