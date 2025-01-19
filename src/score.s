.ifndef SCORE_S
SCORE_S = 1

amount_to_add: .byte 0,0,0

clear_amount_to_add:
    lda #0
    sta amount_to_add
    sta amount_to_add+1
    sta amount_to_add+2
    rts

add_points:
    sed
    sec
    lda score
    sbc amount_to_add
    sta score
    lda score+1
    sbc amount_to_add+1
    sta score+1
    lda score+2
    sbc amount_to_add+2
    sta score+2
    cld
    cmp #$99
    bne @done
    lda #0
    sta score
    sta score+1
    sta score+2
    lda #1
    sta winner
@done:
    rts

.endif