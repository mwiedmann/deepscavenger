.ifndef TILES_S
TILES_S = 1

TRANS_TILE = 58

header_msg: .asciiz "WELCOME TO SCAVENGER"

clear_tiles:
    jsr point_to_mapbase
    lda #TRANS_TILE ; Empty
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


show_header:
    jsr point_to_mapbase
    ldx #0
@next_char:
    lda header_msg, x
    cmp #0
    beq @done
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    inx
    bra @next_char
@done:
    rts
    

; Assumes char is in A reg
get_font_char:
    cmp #193
    bcc @non_letter
    sec
    sbc #193
    rts
@non_letter:
    sec
    sbc #6
    rts

.endif