.ifndef HELPERS_S
HELPERS_S = 1

inc_param1:
    clc
    lda param1
    adc #1
    sta param1
    lda param1+1
    adc #0
    sta param1+1
    rts

.endif