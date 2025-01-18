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
    lda #12
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #2
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%11011000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000100
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set enemy sprite num
    sta cs_sprite_num ; pass the sprite_num for the enemy and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
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
    inc sp_num
    inc sp_entity_count
    lda sp_entity_count
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
    adc #>(8<<5)
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
    jsr set_gem_vel
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
    inc sp_entity_count
    lda sp_entity_count
    cmp #GEM_COUNT
    bne @next_entity
@done:
    rts


set_gem_vel:
    ; We will set the x vel somewhat "randomly" (based on x pos)
    lda dg_x
    and #1
    cmp #1
    beq @odd_x
    ldy #Entity::_vel_x 
    lda #<(65535-1)
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    lda #>(65535-1)
    sta (active_entity), y
    bra @x_done
@odd_x:
    ldy #Entity::_vel_x
    lda #1
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    lda #0
    sta (active_entity), y
@x_done:
    ; We will set the y vel somewhat "randomly" (based on y pos)
    lda dg_y
    and #1
    cmp #1
    beq @odd_y
    ldy #Entity::_vel_y 
    lda #<(65535-1)
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    lda #>(65535-1)
    sta (active_entity), y
    bra @y_done
@odd_y:
    ldy #Entity::_vel_y
    lda #1
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    lda #0
    sta (active_entity), y
@y_done:
    rts


.endif
