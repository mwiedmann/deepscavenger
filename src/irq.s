.ifndef IRQ_S
IRQ_S = 1

irq_routine:
    lda VERA_ISR
    and #%11110000 ; We just need the collision flags
    sta hc_mask ; Save in case this is a collision
    lda VERA_ISR
    and #%100
    beq @check_vsync
    ; Collision
    sta VERA_ISR ; Clear the collision
    jsr handle_collision
    jmp @continue
@check_vsync:
    lda VERA_ISR
    and #1
    beq @continue
    ; sta VERA_ISR ; Clear the VSYNC IRQ
    lda #1
    sta waitflag ; Signal that its ok to draw now
    lda accelwait
    inc
    sta accelwait
@continue:
    jmp (default_irq)

irq_config:
    sei
    ; First, capture the default IRQ handler
    ; This is so we can call it after our custom handler
    lda IRQ_FUNC_ADDR
    sta default_irq
    lda IRQ_FUNC_ADDR+1
    sta default_irq+1
    ; Now replace it with our custom handler
    lda #<irq_routine
    sta IRQ_FUNC_ADDR
    lda #>irq_routine
    sta IRQ_FUNC_ADDR+1
    ; Turn on Sprite collisions and VSYNC
    lda #%101
    sta VERA_IEN
    cli
    rts

.endif