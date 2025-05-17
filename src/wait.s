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
@initial:
    jsr joy1
    cmp #255
    bne @initial ; If pressing when they arrive, wait for a release. We want a full button press/release
@loop:
    jsr joy1
    cmp #255
    bne @release
    bra @loop ; Wait for press
@release:
    jsr joy1
    cmp #255 ; Wait for release
    bne @release
    rts

joy1:
    lda #0
    jsr JOYGET
    sta joy_a ; hold the joystick A state
    stx joy_x ; hold the joystick X state
    lda #1
    jsr JOYGET
    and joy_a
    sta joy_a
    txa
    and joy_x
    sta joy_x
    lda joy_a
    rts

.endif
