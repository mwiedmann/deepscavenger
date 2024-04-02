.zeropage
    active_entity: .res 2
    active_exp: .res 2
    comp_entity1: .res 2
    comp_entity2: .res 2
    param1: .res 2
    param2: .res 2
    hold: .res 2

.segment "STARTUP"
    jmp start

.segment "ONCE"

.include "x16.inc"
.include "config.inc"
.include "entities.inc"
.include "oneshot.inc"
.include "zsmkit.inc"

.segment "CODE"

timebyte: .byte 0

entities: .res .sizeof(Entity)*(ENTITY_COUNT-1) ; We tack on ship after this
ship: .tag Entity

; Precalculated sin/cos (adjusted for a pixel velocity I want) for each angle
ship_vel_ang_x: .word 0,       3,       6,       7,       8, 7, 6, 3, 0, 65535-3, 65535-6, 65535-7, 65535-8, 65535-7, 65535-6, 65535-3
ship_vel_ang_y: .word 65535-8, 65535-7, 65535-6, 65535-3, 0, 3, 6, 7, 8, 7,       6,       3,       0,       65535-3, 65535-6, 65535-7

; What sprite frame to use for each angle
ship_frame_ang: .byte  0,         1,         2,         3,         4,         3,          2,        1,         0,         1,         2,         3,         4,         3,         2,         1

; We make use of the V/H-flip on the sprite to get reuse of the 5 frames. These are precalced for easy use
ship_flip_ang: .byte   %00001000, %00001000, %00001000, %00001000, %00001000, %00001010, %00001010, %00001010, %00001010, %00001011, %00001011, %00001011, %00001001, %00001001, %00001001, %00001001

; These are the V/H-Flip bits we use for each angle
; VFLip 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
; HFlip 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1

oneshots: .res .sizeof(Oneshot) * ONESHOT_SPRITE_COUNT

default_irq: .word 0
waitflag: .byte 0
rotatewait: .byte 0
thrustwait: .byte 0
firewait: .byte 0
accelwait: .byte 0

joy_a: .byte 0

score: .byte 0,0
storm_count: .word 0
hit_warp: .byte 0
gem_count: .byte 0
ship_dead: .byte 0
level: .byte 0

.include "helpers.s"
.include "sound.s"
.include "config.s"
.include "tiles.s"
.include "irq.s"
.include "loading.s"
.include "sprites.s"
.include "wait.s"
.include "convodata.s"
.include "convo.s"
.include "entities.s"
.include "ship.s"
.include "astsml.s"
.include "astbig.s"
.include "gem.s"
.include "gate.s"
.include "warp.s"
.include "enemy.s"
.include "pal.s"
.include "score.s"
.include "oneshot.s"

start:
    jsr sound_init
    jsr config
    jsr load_mainpal
    jsr load_sprites
    jsr load_sounds
    jsr irq_config
    jsr init_oneshots
@restart_game:
    jsr clear_tiles
    jsr update_score
    jsr create_gate_sprite
    jsr create_astsml_sprites
    jsr create_astbig_sprites
    jsr create_gem_sprites
    jsr create_warp_sprite
    jsr create_enemy_sprites
    ; jsr show_next_convo
    jsr show_header
    jsr launch_enemy
    ; Reset our counters now that we are ready to accept input
    lda #0
    sta rotatewait
    sta thrustwait
    sta firewait
    sta accelwait
    sta gem_count
    lda #120 ; Ship will warp in after a few seconds
    sta ship_dead
@move:
    jsr check_storm
    lda ship_dead
    cmp #0
    beq @ship_ok
    ; Ship dead, see if can come back yet
    sec
    sbc #1
    sta ship_dead
    cmp #30 ; Flash the warp for a moment before bringing in the ship
    bne @skip_show_warp
    pha
    jsr show_warp
    pla
@skip_show_warp:
    cmp #1 ; Hide the warp just before bringing in the ship
    bne @skip_hide_warp
    pha
    jsr create_warp_sprite
    jsr check_gems ; Warp may need to stay on
    pla
@skip_hide_warp:
    cmp #0
    bne @skip_ship
    ; Bring ship back
    jsr create_ship
@ship_ok:
    jsr move_ship
@skip_ship:
    jsr move_entities
    jsr update_oneshots
    lda hit_warp
    cmp #1
    bne @waiting
    jsr next_level
    bra @restart_game
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    lda #0
    sta waitflag
    bra @move


next_level:
    inc level
    lda #0
    sta hit_warp
    sta rotatewait
    sta thrustwait
    sta firewait
    sta accelwait
    sta storm_count
    sta storm_count+1
    lda level
    and #2
    cmp #2
    bne @no_astbig_inc ; Only increase on even levels
    lda launch_amount
    cmp #ASTBIG_COUNT ; Max astbig count
    beq @no_astbig_inc
    inc
    sta launch_amount
@no_astbig_inc:
    rts

point_to_mapbase:
    lda #<MAPBASE_L1_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_L1_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    rts


thrusting: .byte 0

move_ship:
    jsr JOYGET
    sta joy_a ; hold the joystick A state
    lda thrustwait
    cmp #0 ; We only thrust the ship every few ticks (otherwise it takes off SUPER fast)
    beq @thrust_ready
    sec
    sbc #1
    sta thrustwait
    bra @check_rotation
@thrust_ready:
    lda #0
    sta thrusting
    lda joy_a
    bit #%1000 ; See if pushing up (thrust)
    bne @check_rotation ; Skip thrust and jump to check rotation
    ldx #1
    stx thrusting
    ; User is pressing up
    ; Shift the ship ang (mult 2) because ship_vel_ang_x are .word
    ldx #SHIP_THRUST_TICKS
    stx thrustwait ; Reset thrust ticks
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
    lda rotatewait
    cmp #0 ; We only rotate the ship every few ticks (otherwise it spins SUPER fast)
    beq @rotate_ready
    sec
    sbc #1
    sta rotatewait
    bra @check_fire
@rotate_ready:
    lda joy_a
    bit #%10 ; Pressing left?
    bne @check_x_right
    ldx #SHIP_ROTATE_TICKS
    stx rotatewait ; Reset rotate ticks
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
    bne @check_fire
    ; User is pressing right
    ldx #SHIP_ROTATE_TICKS
    stx rotatewait ; Reset rotate ticks
    lda ship+Entity::_ang ; Inc the angle
    clc
    adc #1
    cmp #16 ; See if over max of 15
    bne @save_angle
    lda #0 ; Back to 0 if exceeded max
@save_angle:
    sta ship+Entity::_ang
@check_fire:
    lda firewait
    cmp #0 ; We only fire every few ticks
    beq @fire_ready
    sec
    sbc #1
    sta firewait
    bra @done
@fire_ready:
    lda joy_a
    bit #%100 ; Pressing down (fire)?
    bne @done
    ldx #SHIP_FIRE_TICKS
    stx firewait ; Reset fire ticks
    jsr fire_laser
    jsr set_ship_as_active
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
    rts

pixel_crash_dir: .byte 0 ; x=0, y=1

; param1 = visible
check_entity_bounds:
    lda #0
    sta pixel_crash_dir
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
    lda #1
    sta pixel_crash_dir
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
    ldy #Entity::_ob_behavior
    lda (active_entity), y
    cmp #0
    beq @reset
    lda pixel_crash_dir
    cmp #0
    bne @check_y_wrap
@wrap:
    ldy #Entity::_x+1
    lda (active_entity), y
    ; bit #0 ; Check negative, means exited left side (<0)
    bpl @right_wrap
    lda #>(639<<5)
    sta (active_entity), y
    ldy #Entity::_x
    lda #<(639<<5)
    sta (active_entity), y
    bra @final_update
@right_wrap:
    ldy #Entity::_x+1
    lda #0
    sta (active_entity), y
    ldy #Entity::_x
    sta (active_entity), y
    bra @final_update
@check_y_wrap:
    ldy #Entity::_y+1
    lda (active_entity), y
    ; bit #0 ; Check negative, means exited top side (<0)
    bpl @down_wrap
    lda #>(479<<5)
    sta (active_entity), y
    ldy #Entity::_y
    lda #<(479<<5)
    sta (active_entity), y
    bra @final_update
@down_wrap:
    ldy #Entity::_y+1
    lda #0
    sta (active_entity), y
    ldy #Entity::_y
    sta (active_entity), y
@wrap_done:
    bra @final_update
@reset:
    jsr reset_active_entity
    lda param1
    sta pts_sprite_num
    jsr update_sprite
@final_update:
@pixels_ok:
    rts
