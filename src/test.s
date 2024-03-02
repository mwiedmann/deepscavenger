.org $080D
.segment "ONCE"

CHROUT = $FFD2
CHECK = 65536-32

    jmp start

NUM1: .word 65536-31

start:
    sec
    lda NUM1+1  ; compare high bytes
    sbc #>CHECK ; Positive num always 0
    bvc checklt ; the equality comparison is in the Z flag here
    eor #$80   ; the Z flag is affected here
checklt: BMI lt ; if NUM1H < NUM2H then NUM1 < NUM2
    bvc checkgt ; the Z flag was affected only if V is 1
    eor #$80   ; restore the Z flag to the value it had after SBC NUM2H
checkgt: BNE gte ; if NUM1H <> NUM2H then NUM1 > NUM2 (so NUM1 >= NUM2)
    lda NUM1  ; compare low bytes
    sbc #<CHECK
    bcc lt ; if NUM1L < NUM2L then NUM1 < NUM2
gte:
    lda #71 ; Greater
    jsr CHROUT
    rts
lt:
    lda #76 ; Lesser
    jsr CHROUT
    rts