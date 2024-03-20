.ifndef WAIT_S
WAIT_S = 1

wc: .byte 0
wc_temp: .byte 0

wait_count:
    lda wc
    sta wc_temp
@next:
    cmp #0
    beq @done
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    lda #0
    sta waitflag
    lda wc_temp
    sec
    sbc #1
    sta wc_temp
    bra @next
@done:
    rts
    
.endif
