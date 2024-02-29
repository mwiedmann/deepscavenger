.org $080D
.segment "ONCE"

.include "x16.inc"
.include "config.inc"

    jmp start

timebyte: .byte 0
shipx: .word 600<<5
shipy: .word 440<<5
ship_pixelx: .word 0
ship_pixely: .word 0
ship_velx: .byte 0
ship_vely: .byte 0

;0=0, 1=22.5, 2=45, 3=67.5, 4=90, etc.
ship_ang: .byte 0
ship_vel_ang_x: .byte 0, 3, 6, 7, 8, 7, 6, 3, 0, 256-3, 256-6, 256-7, 256-8, 256-7, 256-6, 256-3
ship_vel_ang_y: .byte 8, 7, 6, 3, 0, 256-3, 256-6, 256-7, 256-8, 256-7, 256-6, 256-3, 0, 3, 6, 7

default_irq: .word 0
waitflag: .byte 0

.include "config.s"
.include "tiles.s"
.include "irq.s"
.include "sprites.s"
.include "pal.s"

start:
    jsr irq_config
    jsr config
    jsr load_pal
    jsr create_tiles
    jsr load_ship
    jsr clear_tiles
    jsr create_sprite
@move:
    jsr move_sprite
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    lda #0
    sta waitflag
    bra @move

point_to_mapbase:
    pha
    lda #<MAPBASE_L1_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_L1_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    pla
    rts

move_sprite:
    lda #0
    jsr JOYGET
    pha
    bit #%1000
    bne @check_y_down
    ; User is pressing up
    lda shipy
    sec
    sbc #SPRITE_SPEED
    sta shipy
    lda shipy+1
    sbc #0
    sta shipy+1
    jmp @check_x_left
@check_y_down:
    bit #%100
    bne @check_x_left
    lda shipy
    clc
    adc #SPRITE_SPEED
    sta shipy
    lda shipy+1
    adc #0
    sta shipy+1
@check_x_left:
    pla
    bit #%10
    bne @check_x_right
    lda shipx
    sec
    sbc #SPRITE_SPEED
    sta shipx
    lda shipx+1
    sbc #0
    sta shipx+1
    jmp @update_sprite
@check_x_right:
    bit #%1
    bne @update_sprite
    lda shipx
    clc
    adc #SPRITE_SPEED
    sta shipx
    lda shipx+1
    adc #0
    sta shipx+1
@update_sprite:
    lda shipx
    sta ship_pixelx
    lda shipx+1
    sta ship_pixelx+1
    lda shipy
    sta ship_pixely
    lda shipy+1
    sta ship_pixely+1
    ldx #0
@shift_x:
    ; The shipx/y is a larger number (shifted up 5 bits) to simulate a fractional number
    ; We need to shift it back down to get to the actual pixel position
    clc
    lda ship_pixelx+1
    ror
    sta ship_pixelx+1
    lda ship_pixelx
    ror
    sta ship_pixelx
    inx
    cpx #5
    bne @shift_x
    ldx #0
@shift_y:
    clc
    lda ship_pixely+1
    ror
    sta ship_pixely+1
    lda ship_pixely
    ror
    sta ship_pixely
    inx
    cpx #5
    bne @shift_y
    ; ship_pixelx/y should have the actual pixel values now
    jsr point_to_sprite
    lda VERA_DATA0 ; skip byte
    lda VERA_DATA0 ; skip byte
    lda ship_pixelx
    sta VERA_DATA0
    lda ship_pixelx+1
    sta VERA_DATA0
    lda ship_pixely
    sta VERA_DATA0
    lda ship_pixely+1
    sta VERA_DATA0
@done:
    rts

