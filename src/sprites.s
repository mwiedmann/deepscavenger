.ifndef SPRITES_S
SPRITES_S = 1

.include "x16.inc"
.include "config.inc"

ship_filename: .asciiz "ship.bin"
active_sprite: .word 0
sprite_offset: .word 0;

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
    lda #<SPRITE_GFX_ADDR_LO
    sta VERA_DATA0
    lda #<SPRITE_GFX_ADDR_HI
    sta VERA_DATA0
    lda ship+Entity::_x ; X
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda ship+Entity::_y ; Y
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%10100000 ; 32x32 pixels
    sta VERA_DATA0
    rts


load_ship:
    lda #$08
    ldx #<ship_filename
    ldy #>ship_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_LOAD_ADDR 
    ldy #>SHIP_LOAD_ADDR
    jsr LOAD
    rts


reset_ship_entity:
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
    lda #0
    ldy #Entity::_vel_x
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    ldy #Entity::_vel_y
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    lda #7
    ldy #Entity::_sprite_num
    sta (active_entity), y
    rts


set_ship_as_active:
    lda #<ship
    sta active_entity
    lda #>ship
    sta active_entity+1
    rts
    
.endif