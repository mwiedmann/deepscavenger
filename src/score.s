.ifndef SCORE_S
SCORE_S = 1

amount_to_add: .byte 0,0

clear_amount_to_add:
    lda #0
    sta amount_to_add
    sta amount_to_add+1
    rts

add_points:
    sed
    clc
    lda score
    adc amount_to_add
    sta score
    lda score+1
    adc amount_to_add+1
    sta score+1
    cld
    rts

.endif