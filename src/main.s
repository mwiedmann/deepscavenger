.org $080D
.segment "ONCE"

.include "x16.inc"
.include "config.inc"

    jmp start

timebyte: .byte 0
shipx: .word 320<<5
shipy: .word 240<<5
ship_pixelx: .word 0
ship_pixely: .word 0
ship_velx: .word 0
ship_vely: .word 0

ship_ang: .byte 0 ;0=0, 1=22.5, 2=45, 3=67.5, 4=90, 5=112.5, etc.

; Precalculated sin/cos (adjusted for a pixel velocity I want) for each angle
ship_vel_ang_x: .byte 0, 3, 6, 7, 8, 7, 6, 3, 0, 256-3, 256-6, 256-7, 256-8, 256-7, 256-6, 256-3
ship_vel_ang_y: .byte 8, 7, 6, 3, 0, 256-3, 256-6, 256-7, 256-8, 256-7, 256-6, 256-3, 0, 3, 6, 7

; What sprite frame to use for each angle
ship_frame_ang: .byte  0,         1,         2,         3,         4,         3,          2,        1,         0,         1,         2,         3,         4,         3,         2,         1

; We make use of the V/H-flip on the sprite to get reuse of the 5 frames. These are precalced for easy use
ship_flip_ang: .byte   %00001100, %00001100, %00001100, %00001100, %00001100, %00001110, %00001110, %00001110, %00001110, %00001111, %00001111, %00001111, %00001101, %00001101, %00001101, %00001101

; These are the V/H-Flip bits we use for each angle
; VFLip 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
; HFlip 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1

; Precalculated the lo/hi bit-shifted addrs for the sprite images for each frame
ship_frame_addr_lo: .byte <(SHIP_LOAD_ADDR >> 5), <((SHIP_LOAD_ADDR+SHIP_SPRITE_SIZE) >> 5), <((SHIP_LOAD_ADDR+(SHIP_SPRITE_SIZE*2)) >> 5), <((SHIP_LOAD_ADDR+(SHIP_SPRITE_SIZE*3)) >> 5), <((SHIP_LOAD_ADDR+(SHIP_SPRITE_SIZE*4)) >> 5)
ship_frame_addr_hi: .byte %10000000 | (SHIP_LOAD_ADDR >> 13), %10000000 | ((SHIP_LOAD_ADDR+SHIP_SPRITE_SIZE) >> 13), %10000000 | ((SHIP_LOAD_ADDR+(SHIP_SPRITE_SIZE*2)) >> 13), %10000000 | ((SHIP_LOAD_ADDR+(SHIP_SPRITE_SIZE*3)) >> 13), %10000000 | ((SHIP_LOAD_ADDR+(SHIP_SPRITE_SIZE*4)) >> 13)

default_irq: .word 0
waitflag: .byte 0
waitcount: .byte 0

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
    pha ; Push the joystick state so we can use it later
    bit #%1000
    bne @check_y_down
    ; User is pressing up
    lda ship_vely
    sec
    sbc #SHIP_ACCEL
    sta ship_vely
    lda ship_vely+1
    sbc #0
    sta ship_vely+1
    jmp @check_rotation
@check_y_down:
    bit #%100
    bne @check_rotation
    lda ship_vely
    clc
    adc #SHIP_ACCEL
    sta ship_vely
    lda ship_vely+1
    adc #0
    sta ship_vely+1
@check_rotation:
    pla ; Pull the joystick state off the stack
    ldx waitcount
    cpx #SHIP_ROTATE_TICKS
    bne @add_velocity
    ldx #0 ; clear the waitcount
    stx waitcount
    bit #%10 ; Pressing left?
    bne @check_x_right
    lda ship_ang
    sec
    sbc #1
    cmp #255 ; See if below min of 0
    bne @save_angle
    lda #15 ; Wrap around to 15 if below 0
    jmp @save_angle
@check_x_right:
    bit #%1 ; Pressing right?
    bne @add_velocity
    lda ship_ang ; Inc the angle
    clc
    adc #1
    cmp #16 ; See if over max of 15
    bne @save_angle
    lda #0 ; Back to 0 if exceeded max
@save_angle:
    sta ship_ang
@add_velocity:
    ; Add velocity to y position
    lda shipy
    clc
    adc ship_vely
    sta shipy
    lda shipy+1
    adc ship_vely+1
    sta shipy+1
    ; Add velocity to x position
    lda shipx
    clc
    adc ship_velx
    sta shipx
    lda shipx+1
    adc ship_velx+1
    sta shipx+1
    ; Update sprite position
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
    ldx ship_ang ; Ship's angle (0-15)
    ldy ship_frame_ang, x ; Sprite frame based on angle (0-4)
    lda ship_frame_addr_lo, y ; Frame addr lo
    sta VERA_DATA0 ; Write the lo addr for the sprite frame based on ang
    lda ship_frame_addr_hi, y ; Frame addr hi
    sta VERA_DATA0 ; Write the hi addr for the sprite frame based on ang
    lda ship_pixelx
    sta VERA_DATA0
    lda ship_pixelx+1
    sta VERA_DATA0
    lda ship_pixely
    sta VERA_DATA0
    lda ship_pixely+1
    sta VERA_DATA0
    lda ship_flip_ang, x
    sta VERA_DATA0
@done:
    rts

