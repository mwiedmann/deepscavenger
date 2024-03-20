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
    
watch_for_joystick_press:
@loop:
    lda #0
    jsr JOYGET
    cmp #255
    bne @release
    bra @loop ; Wait for press
@release:
    lda #0
    jsr JOYGET
    cmp #255 ; Wait for release
    bne @release
    rts

.endif
