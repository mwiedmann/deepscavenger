gem_start_x: .word 100<<5, 200<<5, 300<<5, 400<<5, 500<<5
gem_start_y: .word 350<<5, 350<<5, 350<<5, 350<<5, 350<<5

create_gem_sprites:
    lda #<GEM_LOAD_ADDR
    sta us_img_addr
    lda #>GEM_LOAD_ADDR
    sta us_img_addr+1
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
    clc
    lda sp_entity_count ; Use this to get an index into gem_start_?
    rol
    tax
    lda gem_start_x, x
    ldy #Entity::_x
    sta (active_entity), y
    lda gem_start_x+1, x
    ldy #Entity::_x+1
    sta (active_entity), y
    lda gem_start_y, x
    ldy #Entity::_y
    sta (active_entity), y
    lda gem_start_y+1, x
    ldy #Entity::_y+1
    sta (active_entity), y
    jsr move_entity ; Update the pixel positions
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #GEM_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #32
    ldy #Entity::_size
    sta (active_entity), y
    lda #%11000000
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
    lda #%10100000
    sta cs_size ; 32x32
    lda #%11001100
    sta cs_czf
    jsr create_sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    ; Increase the GEM img once we have more than 1 image
    ; ; Increase the GEM img addr
    ; clc
    ; lda us_img_addr
    ; adc #<GEM_SPRITE_FRAME_SIZE
    ; sta us_img_addr
    ; lda us_img_addr+1
    ; adc #>GEM_SPRITE_FRAME_SIZE
    ; sta us_img_addr+1
    lda sp_num
    inc
    sta sp_num
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #GEM_COUNT
    beq @done
    jmp next_gem
@done:
    rts


launch_gems:
    jsr launch_gem
    jsr launch_gem
    jsr launch_gem
    jsr launch_gem
    jsr launch_gem
    rts


launch_gem:
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