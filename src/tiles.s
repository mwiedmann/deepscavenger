.ifndef TILES_S
TILES_S = 1

TRANS_TILE = 58

header_msg: .asciiz "WELCOME TO SCAVENGER        SCORE:"

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
    

update_score:
    ; Point to the score section of mapbase
    lda #<(MAPBASE_L1_ADDR+68)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+68)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    ldx #1
@next_num:
    lda score, x
    jsr get_font_num
    lda num_high
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda num_low
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    dex
    cpx #255
    bne @next_num
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


; Assumes num is in A reg
num_low: .byte 0
num_high: .byte 0

get_font_num:
    pha
    and #%1111 ; remove high part
    clc
    adc #42
    sta num_low
    pla
    ror
    ror
    ror
    ror
    and #%1111 ; remove high part
    clc
    adc #42
    sta num_high
    rts


.endif