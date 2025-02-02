.ifndef LEVEL_S
LEVEL_S = 1

level_text: .asciiz "FIELD "
extra_ship_text: .asciiz "EXTRA SHIP!!!"

show_level:
    jsr clear_tiles
    jsr check_extra_ship
    lda #10
    sta mb_y
    lda #16
    sta mb_x
    jsr point_to_convo_mapbase
    jsr display_level
@loop:
    lda #180
    sta wc
    jsr wait_count
    jsr clear_tiles
    rts

check_extra_ship:
    lda level
    and #2
    cmp #2
    bne @done
    ; extra ship
    inc lives
    lda #14
    sta mb_x
    lda #12
    sta mb_y
    jsr point_to_convo_mapbase
    ldx #0
@next_char:
    lda extra_ship_text, x
    cmp #0
    beq @done
    ; Write the char
    phx
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    plx
    inx
    bra @next_char
@done:
    rts


display_level:
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
    ; Only show 2 digits
    ; lda num_low
    ; sta VERA_DATA0
    ; lda #0
    ; sta VERA_DATA0
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