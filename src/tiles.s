.ifndef TILES_S
TILES_S = 1

clear_tiles:
    jsr point_to_mapbase
    lda #42 ; Empty
    ldy #0
@outer:
    ldx #0
@loop:
    sta VERA_DATA0
    sta VERA_DATA0
    inx
    cpx #TILES_PER_ROW
    bne @loop
@next_row:
    iny
    cpy #TILES_PER_COL
    bne @outer
    rts

.endif