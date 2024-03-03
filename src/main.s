.zeropage
    active_entity: .res 2
    param1: .res 2
    param2: .res 2

.org $080D
.segment "ONCE"

.include "x16.inc"
.include "config.inc"
.include "entities.inc"

    jmp start

timebyte: .byte 0

ship: .tag Entity

; Precalculated sin/cos (adjusted for a pixel velocity I want) for each angle
ship_vel_ang_x: .word 0,       3,       6,       7,       8, 7, 6, 3, 0, 65535-3, 65535-6, 65535-7, 65535-8, 65535-7, 65535-6, 65535-3
ship_vel_ang_y: .word 65535-8, 65535-7, 65535-6, 65535-3, 0, 3, 6, 7, 8, 7,       6,       3,       0,       65535-3, 65535-6, 65535-7

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
rotatewait: .byte 0
thrustwait: .byte 0

ZEROPAGE = $30

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
    jsr set_ship_as_active
    jsr reset_ship_entity
    jsr clear_tiles
    ; pass the sprite_num for the ship and create its sprite
    lda ship+Entity::_sprite_num
    sta param1
    jsr create_sprite
@move:
    jsr move_ship
    jsr set_ship_as_active
    jsr move_entity
    jsr check_entity_bounds
    lda ship+Entity::_sprite_num
    sta param1
    jsr update_sprite
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


move_ship:
    lda #0
    jsr JOYGET
    pha ; Push the joystick state so we can use it later
    ldx thrustwait
    cpx #SHIP_THRUST_TICKS ; We only thrust the ship every few ticks (otherwise it takes off SUPER fast)
    bne @check_rotation
    ldx #0 ; clear the thrustwait
    stx thrustwait
    bit #%1000 ; See if pushing up (thrust)
    bne @check_rotation ; Skip thrust and jump to check rotation
    ; User is pressing up
    ; Shift the ship ang (mult 2) because ship_vel_ang_x are .word
    clc
    lda ship+Entity::_ang
    rol
    tax ; We now have a 0-31 index based on 0-15 angle
    ; First increase the x velocity
    lda ship+Entity::_vel_x
    clc
    adc ship_vel_ang_x, x ; x thrust based on angle (lo byte)
    sta ship+Entity::_vel_x
    lda ship+Entity::_vel_x+1
    adc ship_vel_ang_x+1, x ; x thrust based on angle (hi byte)
    sta ship+Entity::_vel_x+1
    ; Second increase the y velocity
    lda ship+Entity::_vel_y
    clc
    adc ship_vel_ang_y, x ; y thrust based on angle (lo byte)
    sta ship+Entity::_vel_y
    lda ship+Entity::_vel_y+1
    adc ship_vel_ang_y+1, x ; y thrust based on angle (hi byte)
    sta ship+Entity::_vel_y+1
    ; Do we need to check the max velocity (we can just cap the x/y individually)?
    ; They must stay on screen so its unlikely high speed will matter...they will crash
@check_rotation:
    pla ; Pull the joystick state off the stack
    ldx rotatewait
    cpx #SHIP_ROTATE_TICKS ; We only rotate the ship every few ticks (otherwise it spins SUPER fast)
    bne @done
    ldx #0 ; clear the rotatewait
    stx rotatewait
    bit #%10 ; Pressing left?
    bne @check_x_right
    ; User is pressing left
    lda ship+Entity::_ang
    sec
    sbc #1
    cmp #255 ; See if below min of 0
    bne @save_angle
    lda #15 ; Wrap around to 15 if below 0
    jmp @save_angle
@check_x_right:
    bit #%1 ; Pressing right?
    bne @done
    ; User is pressing right
    lda ship+Entity::_ang ; Inc the angle
    clc
    adc #1
    cmp #16 ; See if over max of 15
    bne @save_angle
    lda #0 ; Back to 0 if exceeded max
@save_angle:
    sta ship+Entity::_ang
@done:
    rts


move_entity:
    ; active_entity holds the address of the entity to move
    ; Add velocity to y position
    ldy #Entity::_y ; Point to _y lo bit
    lda (active_entity), y ; Get the _y (lo bit)
    ldy #Entity::_vel_y ; Get the _vel_y (lo bit)
    clc
    adc (active_entity), y ; Add the _vel_y (lo bit, moves entity y position)
    ldy #Entity::_y ; Point back to _y (lo bit) so we can update it
    sta (active_entity), y ; Store the updated _y (lo bit)
    ldy #Entity::_pixel_y ; Point to _pixel_y (lo bit) so we can update it
    sta (active_entity), y ; Copy _y to _pixel_y (lo bit)
    ldy #Entity::_y+1 ; Point to _y hi bit
    lda (active_entity), y ; Get the _y (hi bit)
    ldy #Entity::_vel_y+1 ; Point to the _vel_y (hi bit)
    adc (active_entity), y ; Add the _vel_y (hi bit, moves entity y position)
    ldy #Entity::_y+1 ; Point back to _y (hi bit) so we can update it
    sta (active_entity), y ; Store the updated _y (hi bit)
    ldy #Entity::_pixel_y+1 ; Point to _pixel_y (hi bit) so we can update it
    sta (active_entity), y ; Copy _y to _pixel_y (hi bit)
    ; Add velocity to x position
    ldy #Entity::_x ; Point to _x lo bit
    lda (active_entity), y ; Get the _x (lo bit)
    ldy #Entity::_vel_x ; Get the _vel_x (lo bit)
    clc
    adc (active_entity), y ; Add the _vel_x (lo bit, moves entity x position)
    ldy #Entity::_x ; Point back to _x (lo bit) so we can update it
    sta (active_entity), y ; Store the updated _x (lo bit)
    ldy #Entity::_pixel_x ; Point to _pixel_x (lo bit) so we can update it
    sta (active_entity), y ; Copy _x to _pixel_x (lo bit)
    ldy #Entity::_x+1 ; Point to _x hi bit
    lda (active_entity), y ; Get the _x (hi bit)
    ldy #Entity::_vel_x+1 ; Point to the _vel_x (hi bit)
    adc (active_entity), y ; Add the _vel_x (hi bit, moves entity x position)
    ldy #Entity::_x+1 ; Point back to _x (hi bit) so we can update it
    sta (active_entity), y ; Store the updated _x (hi bit)
    ldy #Entity::_pixel_x+1 ; Point to _pixel_x (hi bit) so we can update it
    sta (active_entity), y ; Copy _x to _pixel_x (hi bit)
    ldx #0
@shift_x:
    ; The ship+Entity::_x/y is a larger number (shifted up 5 bits) to simulate a fractional number
    ; We need to shift it back down to get to the actual pixel position
    clc
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    ror
    sta (active_entity), y
    ldy #Entity::_pixel_x
    lda (active_entity), y
    ror
    sta (active_entity), y
    inx
    cpx #5
    bne @shift_x
    ldx #0
@shift_y:
    clc
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    ror
    sta (active_entity), y
    ldy #Entity::_pixel_y
    lda (active_entity), y
    ror
    sta (active_entity), y
    inx
    cpx #5
    bne @shift_y


check_entity_bounds:
    ; ship+Entity::_pixel_x/y should have the actual pixel values now
    ; Make sure they are still on screen...crash if not!
    ; branches to LABEL2 if NUM1 >= NUM2
    ldy #Entity::_pixel_x+1
    lda (active_entity), y ; compare high bytes
    CMP #>640
    BCC @pixel_x_ok ; if NUM1H < NUM2H then NUM1 < NUM2
    BNE @pixel_crash ; if NUM1H <> NUM2H then NUM1 > NUM2 (so NUM1 >= NUM2)
    ldy #Entity::_pixel_x
    lda (active_entity), y ; compare low bytes
    CMP #<640
    BCS @pixel_crash ; if NUM1L >= NUM2L then NUM1 >= NUM2
@pixel_x_ok:
    ; Check y pixel
    ldy #Entity::_pixel_y+1
    lda (active_entity), y  ; compare high bytes
    CMP #>480
    BCC @pixels_ok ; if NUM1H < NUM2H then NUM1 < NUM2
    BNE @pixel_crash ; if NUM1H <> NUM2H then NUM1 > NUM2 (so NUM1 >= NUM2)
    ldy #Entity::_pixel_y
    lda (active_entity), y  ; compare low bytes
    CMP #<480
    BCS @pixel_crash ; if NUM1L >= NUM2L then NUM1 >= NUM2
    jmp @pixels_ok
@pixel_crash:
    ; Put player back in middle of screen and stop their ship
    jsr reset_ship_entity
@pixels_ok:
    rts


update_sprite:
    jsr point_to_sprite
    ldx ship+Entity::_ang ; Ship's angle (0-15)
    ldy ship_frame_ang, x ; Sprite frame based on angle (0-4)
    lda ship_frame_addr_lo, y ; Frame addr lo
    sta VERA_DATA0 ; Write the lo addr for the sprite frame based on ang
    lda ship_frame_addr_hi, y ; Frame addr hi
    sta VERA_DATA0 ; Write the hi addr for the sprite frame based on ang
    lda ship+Entity::_pixel_x
    sta VERA_DATA0
    lda ship+Entity::_pixel_x+1
    sta VERA_DATA0
    lda ship+Entity::_pixel_y
    sta VERA_DATA0
    lda ship+Entity::_pixel_y+1
    sta VERA_DATA0
    lda ship_flip_ang, x
    sta VERA_DATA0
    rts

