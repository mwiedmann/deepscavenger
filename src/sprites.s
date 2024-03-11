.ifndef SPRITES_S
SPRITES_S = 1

.include "x16.inc"
.include "config.inc"

active_sprite: .word 0
sprite_offset: .word 0

sp_offset: .word 0
sp_num: .byte 0
sp_entity_count: .byte 0

us_img_addr: .word 0
us_frame: .byte 0
us_ang: .byte 0
us_visible: .byte 0

; NOTE: This is limited to 31 sprites because we only do 8bit sprite offset calc (shifting)
; param1: sprite number

point_to_sprite:
    lda #<SPRITE_ADDR
    sta active_sprite
    lda #>SPRITE_ADDR
    sta active_sprite+1
    lda param1 ; Get sprite num from param1
    ldx #0
@mult_8: ; Mult sprite num by 8 to get the memory offset of that sprite
    clc
    rol
    inx
    cpx #3
    bne @mult_8
    sta sprite_offset
    lda #0
    sta sprite_offset+1
    ; sprite_offset now ready to add to the active_sprite
    clc
    lda active_sprite
    adc sprite_offset
    sta active_sprite
    lda active_sprite+1
    adc sprite_offset+1
    sta active_sprite+1
    ; We have the address of the sprite...point to to
    lda active_sprite
    sta VERA_ADDR_LO
    lda active_sprite+1
    sta VERA_ADDR_MID
    lda #(VERA_ADDR_HI_INC_BITS+1) ; Sprites are in 2nd bank of VRAM
    sta VERA_ADDR_HI_SET
    rts

; param1: sprite_num
create_sprite:
    jsr point_to_sprite
    lda #0
    sta VERA_DATA0
    lda #%10000000
    sta VERA_DATA0
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%10100000 ; 32x32 pixels
    sta VERA_DATA0
    rts

update_sprite:
    jsr point_to_sprite
    ldy #Entity::_has_ang ; Does sprite change based on angle?
    lda (active_entity), y
    ldx #0
    cmp #0
    beq update_ang_frame
    ldy #Entity::_ang ; Entity's angle (0-15)
    lda (active_entity), y
    sta us_ang
    tax
update_ang_frame:
    lda ship_frame_ang, x ; Sprite frame based on angle (0-4)
    sta us_frame ; us_frame now has the sprite frame number
    ldy #Entity::_visible ; Entity visibility
    lda (active_entity), y
    sta us_visible

    ; Load the image addr so we can add to and bit shift it
    ldy #Entity::_image_addr
    lda (active_entity), y
    sta us_img_addr
    ldy #Entity::_image_addr+1
    lda (active_entity), y
    sta us_img_addr+1
    ldx #0
@move_frame:
    cpx us_frame
    beq @frame_slide_done
    clc
    lda us_img_addr
    adc #<DEFAULT_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>DEFAULT_FRAME_SIZE
    sta us_img_addr+1
    inx
    bra @move_frame
@frame_slide_done:
    ldx #0
@start_shift: ; Shift the image addr bits as sprites use bits 12:5 and 16:13 (we default 16 to 0)
    clc
    lda us_img_addr+1
    ror
    sta us_img_addr+1
    lda us_img_addr
    ror
    sta us_img_addr
    inx
    cpx #5
    bne @start_shift

    ; Do the addr calc on the fly (>>5)
    lda us_img_addr ; Frame addr lo
    sta VERA_DATA0 ; Write the lo addr for the sprite frame based on ang
    lda us_img_addr+1 ; Frame addr hi
    ora #%10000000 ; Keep the 256 color mode on
    sta VERA_DATA0 ; Write the hi addr for the sprite frame based on ang
    
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sta VERA_DATA0
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sta VERA_DATA0
    ldx us_ang
    lda ship_flip_ang, x
    ldy us_visible
    cpy #1
    beq @write_flip
    and #%11110011 ; Hide entity, z-depth=0
@write_flip:
    sta VERA_DATA0
    rts

; param1 = visible
reset_active_entity:
    lda #<(320<<5)
    ldy #Entity::_x
    sta (active_entity), y
    lda #>(320<<5)
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #<(240<<5)
    ldy #Entity::_y
    sta (active_entity), y
    lda #>(240<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    lda #<320
    ldy #Entity::_pixel_x
    sta (active_entity), y
    lda #>320
    ldy #Entity::_pixel_x+1
    sta (active_entity), y
    lda #<240
    ldy #Entity::_pixel_y
    sta (active_entity), y
    lda #>240
    ldy #Entity::_pixel_y+1
    sta (active_entity), y
    lda #0
    ldy #Entity::_vel_x
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    ldy #Entity::_vel_y
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    lda param1
    ldy #Entity::_visible
    sta (active_entity), y
    rts


accel_entity:
    ldy #Entity::_ang
    lda (active_entity), y
    clc
    rol ; Shift the ship ang (mult 2) because ship_vel_ang_x are .word
    tax ; We now have a 0-31 index based on 0-15 angle
    ; First increase the x velocity
    ldy #Entity::_vel_x
    lda (active_entity), y
    clc
    adc ship_vel_ang_x, x ; x thrust based on angle (lo byte)
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    lda (active_entity), y
    adc ship_vel_ang_x+1, x ; x thrust based on angle (hi byte)
    sta (active_entity), y
    ; Second increase the y velocity
    ldy #Entity::_vel_y
    lda (active_entity), y
    clc
    adc ship_vel_ang_y, x ; y thrust based on angle (lo byte)
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    lda (active_entity), y
    adc ship_vel_ang_y+1, x ; y thrust based on angle (hi byte)
    sta (active_entity), y
    rts


move_entities:
    ldx #0
    stx sp_entity_count
    ldx #0
    stx sp_offset
@next_entity:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc #0
    sta active_entity+1
    ldy #Entity::_visible
    lda (active_entity), y
    cmp #0
    beq @skip_entity ; Skip if not visible
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS ; We only thrust entities every few ticks (otherwise they take off SUPER fast)
    bne @skip_accel
    ldy #Entity::_has_accel
    lda (active_entity), y
    cmp #0
    beq @skip_accel
    jsr accel_entity
@skip_accel:
    jsr move_entity
    lda #0
    sta param1 ; make entity not visible if out of bounds
    jsr check_entity_bounds
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
@skip_entity:
    clc
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #ENTITY_COUNT
    bne @next_entity
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS
    bne @done
    lda #0
    sta accelwait
@done:
    rts

.endif
