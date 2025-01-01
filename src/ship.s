.ifndef SHIP_S
SHIP_S = 1

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
    lda #%11100000
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
    lda #<(SHIP_LOAD_ADDR>>16) ; Ship img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    ; pass the sprite_num for the ship and create its sprite
    lda ship+Entity::_sprite_num
    sta cs_sprite_num
    lda #%10100000 ; 32x32
    sta cs_size
    ldy #Entity::_collision
    lda (active_entity), y
    sta cs_czf
    jsr create_sprite
    jsr create_laser_sprites
    rts

fire_laser:
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*LASER_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*LASER_ENTITY_NUM_START)
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
    jsr sound_shoot
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
    lda #LASER_DESTROY_TICKS
    ldy #Entity::_destroy_ticks
    sta (active_entity), y
    ; adjust position by 8 since missiles are smaller
    clc
    ldy #Entity::_x
    lda (active_entity), y
    adc #<(8<<5)
    sta (active_entity), y
    ldy #Entity::_x+1
    lda (active_entity), y
    adc #>(8<<5)
    sta (active_entity), y
    clc
    ldy #Entity::_y
    lda (active_entity), y
    adc #<(8<<5)
    sta (active_entity), y
    ldy #Entity::_y+1
    lda (active_entity), y
    adc #>(8<<5)
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
    inc sp_entity_count
    lda sp_entity_count
    cmp #LASER_COUNT
    bne @next_entity
@done:
    jsr move_entity ; Move it once to get some distance from ship
    rts


set_ship_as_active:
    lda #<ship
    sta active_entity
    lda #>ship
    sta active_entity+1
    rts

thrusting_ship_img:
    lda #<SHIP_THRUST_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_THRUST_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_THRUST_LOAD_ADDR>>16)
    sta us_img_addr+2
    rts

normal_ship_img:
    lda #<SHIP_LOAD_ADDR
    sta us_img_addr
    lda #>SHIP_LOAD_ADDR
    sta us_img_addr+1
    lda #<(SHIP_LOAD_ADDR>>16)
    sta us_img_addr+2
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
    lda #<(LASER_LOAD_ADDR>>16) ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    jsr set_laser_attr
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
    inc sp_num
    inc sp_entity_count
    lda sp_entity_count
    cmp #LASER_COUNT
    bne @next_laser
    rts

set_laser_attr:
    lda #LASER_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #%00010000
    ldy #Entity::_collision
    sta (active_entity), y
    lda #1
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    ldy #Entity::_ob_behavior
    sta (active_entity), y ; Laser wraps around screen
    rts
.endif
