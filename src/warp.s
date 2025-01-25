.ifndef WARP_S
WARP_S = 1

create_warp_sprite:
    lda #<WARP_LOAD_ADDR
    sta us_img_addr
    lda #>WARP_LOAD_ADDR
    sta us_img_addr+1
    lda #<(WARP_LOAD_ADDR>>16)
    sta us_img_addr+2
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
    lda #0
    sta param1 ;visible
    jsr reset_active_entity
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda us_img_addr+2 ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #WARP_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #%10000000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000001
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #32
    ldy #Entity::_size
    sta (active_entity), y
    lda #24
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #4
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    lda #3
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #<((320-16)<<5)
    ldy #Entity::_x
    sta (active_entity), y
    lda #>((320-16)<<5)
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #<((240-16)<<5)
    ldy #Entity::_y
    sta (active_entity), y
    lda #>((240-16)<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    lda #WARP_SPRITE_NUM
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set warp sprite num
    sta cs_sprite_num ; pass the sprite_num for the warp and create its sprite
    lda #%10100000 ; 32x32
    sta cs_size
    jsr create_sprite
    jsr create_safe_area
    rts

create_safe_area:
    ldx #<(.sizeof(Entity)*SAFE_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*SAFE_ENTITY_NUM_START)
    stx sp_offset+1
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    lda #0
    sta param1 ;visible
    jsr reset_active_entity
    lda #SAFE_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #%00110110
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%10000000
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #64
    ldy #Entity::_size
    sta (active_entity), y
    lda #128
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #0
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    lda #3
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #<((320-64)<<5)
    ldy #Entity::_x
    sta (active_entity), y
    lda #>((320-64)<<5)
    ldy #Entity::_x+1
    sta (active_entity), y
    lda #<((240-64)<<5)
    ldy #Entity::_y
    sta (active_entity), y
    lda #>((240-64)<<5)
    ldy #Entity::_y+1
    sta (active_entity), y
    lda #SAFE_SPRITE_NUM_START
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set safe sprite num
    rts

show_warp:
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
    ldy #Entity::_visible
    sta (active_entity), y
    rts

enable_safe_area:
    ldx #<(.sizeof(Entity)*SAFE_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*SAFE_ENTITY_NUM_START)
    stx sp_offset+1
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    rts
.endif
