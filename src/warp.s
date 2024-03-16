.ifndef WARP_S
WARP_S = 1

create_warp_sprite:
    lda #<WARP_LOAD_ADDR
    sta us_img_addr
    lda #>WARP_LOAD_ADDR
    sta us_img_addr+1
    ldx #<(.sizeof(Entity)*WARP_ENTITY_NUM)
    stx sp_offset
    ldx #>(.sizeof(Entity)*WARP_ENTITY_NUM)
    stx sp_offset+1
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    lda #1
    sta param1 ;visible
    jsr reset_active_entity
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #WARP_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #%00000000
    ldy #Entity::_collision
    sta (active_entity), y
    lda #64
    ldy #Entity::_size
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #<((320-32)<<5)
    ldy #Entity::_x
    sta (active_entity), y
    lda #>((320-32)<<5)
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #<((240-32)<<5)
    ldy #Entity::_y
    sta (active_entity), y
    lda #>((240-32)<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    lda #WARP_SPRITE_NUM
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set warp sprite num
    sta cs_sprite_num ; pass the sprite_num for the warp and create its sprite
    lda #%11110000 ; 64x64
    sta cs_size
    lda #%00000000
    sta cs_czf
    jsr create_sprite
    rts

.endif
