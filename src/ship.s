create_ship:
    jsr set_ship_as_active
    lda #0
    sta param1 ; ship should not be visible to start
    jsr reset_active_entity
    lda #SHIP_SPRITE_NUM ; Ship sprite num
    ldy #Entity::_sprite_num
    sta (active_entity), y
    lda #SHIP_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #32
    ldy #Entity::_size
    sta (active_entity), y
    lda #%10000000
    ldy #Entity::_collision
    sta (active_entity), y
    lda #1 ; Ship visibility on
    ldy #Entity::_visible
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y ; Ship wraps around screen
    ldy #Entity::_has_ang
    sta (active_entity), y ; Ship sprite has angle based frames
    lda #<SHIP_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>SHIP_LOAD_ADDR ; Ship img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    ; pass the sprite_num for the ship and create its sprite
    lda ship+Entity::_sprite_num
    sta cs_sprite_num
    lda #%10100000 ; 32x32
    sta cs_size
    lda #%10001100
    sta cs_czf
    jsr create_sprite
    jsr create_laser_sprites
    rts

fire_laser:
    ldx #0
    stx sp_entity_count
    stx sp_offset
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
    ; Found a free laser
    ; Move it to the ship position and launch it!
    ldy #0 ; copy bytes 0-12
@copy:
    lda ship, y
    sta (active_entity), y
    iny
    cpy #13
    bne @copy
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    ldx #0
@initial_accel:
    ; Accelerate the laser a few times to get it started moving
    phx
    jsr accel_entity
    plx
    inx
    cpx #5
    bne @initial_accel
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
    cmp #LASER_COUNT
    bne @next_entity
@done:
    rts


set_ship_as_active:
    lda #<ship
    sta active_entity
    lda #>ship
    sta active_entity+1
    rts


create_laser_sprites:
    ldx #0
    stx sp_entity_count
    ldx #LASER_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*LASER_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*LASER_ENTITY_NUM_START)
    stx sp_offset+1
@next_laser:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc sp_offset+1
    sta active_entity+1
    lda #0
    sta param1
    jsr reset_active_entity
    lda #<LASER_LOAD_ADDR ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda #>LASER_LOAD_ADDR ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #LASER_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #32
    ldy #Entity::_size
    sta (active_entity), y
    lda #%01000000
    ldy #Entity::_collision
    sta (active_entity), y
    lda #1
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
    lda #%01001100
    sta cs_czf
    jsr create_sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    lda sp_num
    inc
    sta sp_num
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #LASER_COUNT
    bne @next_laser
    rts