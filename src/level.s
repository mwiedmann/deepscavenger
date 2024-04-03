.ifndef LEVEL_S
LEVEL_S = 1

level_text: .asciiz "FIELD "

show_level:
    jsr clear_tiles
    lda #10
    sta mb_y
    lda #15
    sta mb_x
    jsr point_to_convo_mapbase
    ldx #0
@next_char:
    lda level_text, x
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
    jsr convert_level
    lda level_temp+1
    jsr get_font_num
    lda num_low
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda level_temp
    jsr get_font_num
    lda num_high
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda num_low
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
@loop:
    lda #180
    sta wc
    jsr wait_count
    jsr clear_tiles
    rts

level_temp: .word 0

convert_level:
    sed
    lda #0
    sta level_temp
    sta level_temp+1
    ldx level
@next:
    cpx #0
    beq @done
    clc
    lda level_temp
    adc #1
    sta level_temp
    lda level_temp+1
    adc #0
    sta level_temp+1
    dex
    bra @next
@done:
    cld
    rts

.endif