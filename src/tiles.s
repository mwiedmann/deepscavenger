.ifndef TILES_S
TILES_S = 1

TRANS_TILE = 58

header_msg: .asciiz "    DEBT:"

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
    ; skip a few spaces
    lda #TRANS_TILE ; Empty
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    jsr display_level
    lda #TRANS_TILE ; Empty
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    jsr display_lives
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

game_over_text: .asciiz "GAME OVER"

show_game_over:
    lda #10
    sta mb_y
    lda #16
    sta mb_x
    jsr point_to_convo_mapbase
    ldx #0
@next_char:
    lda game_over_text, x
    cmp #0
    beq @found_null
    ; Write the char
    phx
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    plx
    inx
    bra @next_char
@found_null:
    rts

update_score:
    ; Point to the score section of mapbase
    lda #<(MAPBASE_L1_ADDR+64)
    sta VERA_ADDR_LO
    lda #>(MAPBASE_L1_ADDR+64)
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    ldx #2
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