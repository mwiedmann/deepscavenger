.ifndef GEM_S
GEM_S = 1

create_gem_sprites:
    lda #<GEM_LOAD_ADDR
    sta us_img_addr
    lda #>GEM_LOAD_ADDR
    sta us_img_addr+1
    lda #<(GEM_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #GEM_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset+1
next_gem:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    lda #0
    sta param1 ; Not visible
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
    lda #GEM_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #%11110000
    ldy #Entity::_collision
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set enemy sprite num
    sta cs_sprite_num ; pass the sprite_num for the enemy and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
    ldy #Entity::_collision
    lda (active_entity), y
    sta cs_czf
    jsr create_sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    ; Increase the GEM img once we have more than 1 image
    ; Increase the GEM img addr
    clc
    lda us_img_addr
    adc #<GEM_SPRITE_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>GEM_SPRITE_FRAME_SIZE
    sta us_img_addr+1
    lda us_img_addr+2
    adc #0
    sta us_img_addr+2
    lda sp_num
    inc
    sta sp_num
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #8 ; Only 8 gem types, go back to 0
    bne @check_max
    ldx #<GEM_LOAD_ADDR
    stx us_img_addr
    ldx #>GEM_LOAD_ADDR
    stx us_img_addr+1
    ldx #<(GEM_LOAD_ADDR>>16)
    stx us_img_addr+2
@check_max:
    cmp #GEM_COUNT
    beq @done
    jmp next_gem
@done:
    rts


dg_x: .word 0
dg_y: .word 0

drop_gem_from_active_entity:
    ldy #Entity::_x
    lda (active_entity), y
    sta dg_x
    ldy #Entity::_x+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta dg_x+1
    ldy #Entity::_y
    lda (active_entity), y
    sta dg_y
    ldy #Entity::_y+1
    lda (active_entity), y
    clc
    adc #>(16<<5)
    sta dg_y+1
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset+1
@next_entity:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    ldy #Entity::_visible
    lda (active_entity), y
    cmp #0
    bne @skip_entity
    ; Found a free gem
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    lda dg_x
    ldy #Entity::_x
    sta (active_entity), y
    lda dg_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda dg_y
    ldy #Entity::_y
    sta (active_entity), y
    lda dg_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    ldx #0
    bra @done
@skip_entity:
    clc
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #GEM_COUNT
    bne @next_entity
@done:
    rts

.endif
