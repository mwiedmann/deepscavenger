.ifndef ENEMY_S
ENEMY_S = 1

create_enemy_sprites:
    lda #<ENEMY_LOAD_ADDR
    sta us_img_addr
    lda #>ENEMY_LOAD_ADDR
    sta us_img_addr+1
    lda #<(ENEMY_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #ENEMY_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*ENEMY_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ENEMY_ENTITY_NUM_START)
    stx sp_offset+1
next_enemy:
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
    lda #ENEMY_TYPE
    ldy #Entity::_type
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
    lda #%11000100
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00010000
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda #1
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set enemy sprite num
    sta cs_sprite_num ; pass the sprite_num for the enemy and create its sprite
    lda #%10100000
    sta cs_size ; 32x32
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
    cmp #ENEMY_COUNT
    beq @done
    jmp next_enemy
@done:
    rts


create_enemy_laser_sprites:
    lda #<ENEMY_LASER_LOAD_ADDR
    sta us_img_addr
    lda #>ENEMY_LASER_LOAD_ADDR
    sta us_img_addr+1
    lda #<(ENEMY_LASER_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #ENEMY_LASER_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*ENEMY_LASER_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ENEMY_LASER_ENTITY_NUM_START)
    stx sp_offset+1
next_enemy_laser:
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
    lda #ENEMY_LASER_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y ; Laser wraps around screen
    lda #16
    ldy #Entity::_size
    lda #10
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #3
    ldy #Entity::_coll_adj
    sta (active_entity), y
    sta (active_entity), y
    lda #%10100100
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00001000
    ldy #Entity::_collision_id
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
    lda #%01010000
    sta cs_size ; 16x16
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
    cmp #ENEMY_LASER_COUNT
    beq @done
    jmp next_enemy_laser
@done:
    rts

enemy_ang_index: .byte 4
enemy_x: .word 100<<5
enemy_y: .word 100<<5

launch_enemy_top:
    lda #4
    sta enemy_ang_index
    lda #<(0<<5)
    sta enemy_x
    lda #>(0<<5)
    sta enemy_x+1
    lda #<(120<<5)
    sta enemy_y
    lda #>(120<<5)
    sta enemy_y+1
    jsr launch_enemy
    rts

launch_enemy_bottom:
    lda #12
    sta enemy_ang_index
    lda #<(0<<5)
    sta enemy_x
    lda #>(0<<5)
    sta enemy_x+1
    lda #<(348<<5)
    sta enemy_y
    lda #>(348<<5)
    sta enemy_y+1
    jsr launch_enemy
    rts

launch_enemy:
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*ENEMY_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ENEMY_ENTITY_NUM_START)
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
    jsr found_free_enemy
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
    cmp #ENEMY_COUNT
    bne @next_entity
@done:
    rts

found_free_enemy:
    ; Clear any existing velocity
    lda #0
    ldy #Entity::_vel_x
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    ldy #Entity::_vel_y
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    lda enemy_x
    ldy #Entity::_x
    sta (active_entity), y
    lda enemy_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda enemy_y
    ldy #Entity::_y
    sta (active_entity), y
    lda enemy_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    ; Set its angle and accel once to get it going
    ; enemy_ang_index
    lda enemy_ang_index
    ldy #Entity::_ang
    sta (active_entity), y
    ; Accelerate the enemy to get it started moving
    ldx #0
@accel:
    phx
    jsr accel_entity
    plx
    inx
    cpx #7
    bne @accel
    rts

fel_x: .word 0
fel_y: .word 0
fel_vel_x: .word 0
fel_vel_y: .word 0
fel_ang_index: .byte 0
fel_offset: .word 0
fel_entity_count: .byte 0
fel_entity_hold: .word 0

fire_enemy_laser:
    ; Hold the active entity so we can restore it later
    lda active_entity
    sta fel_entity_hold
    lda active_entity+1
    sta fel_entity_hold+1
    ldx #0
    stx fel_entity_count
    ldx #<(.sizeof(Entity)*ENEMY_LASER_ENTITY_NUM_START)
    stx fel_offset
    ldx #>(.sizeof(Entity)*ENEMY_LASER_ENTITY_NUM_START)
    stx fel_offset+1
@next_entity:
    clc
    lda #<entities
    adc fel_offset
    sta active_entity
    lda #>entities
    adc fel_offset+1
    sta active_entity+1
    ldy #Entity::_visible
    lda (active_entity), y
    cmp #0
    bne @skip_entity
    jsr found_free_enemy_laser
    bra @done
@skip_entity:
    clc
    lda fel_offset
    adc #.sizeof(Entity)
    sta fel_offset
    lda fel_offset+1
    adc #0
    sta fel_offset+1
    inc fel_entity_count
    lda fel_entity_count
    cmp #ENEMY_LASER_COUNT
    bne @next_entity
@done:
    ; Restore the active entity
    lda fel_entity_hold
    sta active_entity
    lda fel_entity_hold+1
    sta active_entity+1
    rts


found_free_enemy_laser:
    ; Copy velocity
    lda fel_vel_x
    ldy #Entity::_vel_x
    sta (active_entity), y
    lda fel_vel_x+1
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    lda fel_vel_y
    ldy #Entity::_vel_y
    sta (active_entity), y
    lda fel_vel_y+1
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    lda #ENEMY_LASER_DESTROY_TICKS
    ldy #Entity::_destroy_ticks
    sta (active_entity), y
    lda fel_x
    ldy #Entity::_x
    sta (active_entity), y
    lda fel_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda fel_y
    ldy #Entity::_y
    sta (active_entity), y
    lda fel_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    ; Set its angle 
    lda fel_ang_index
    ldy #Entity::_ang
    sta (active_entity), y
    ; Accelerate the enemy laser to get it started moving
    ldx #0
@accel:
    phx
    jsr accel_entity
    plx
    inx
    cpx #5
    bne @accel
    jsr move_entity
    jsr move_entity
    jsr move_entity
    jsr move_entity
    rts

enemy_timer: .word 0
enemy_launch_time: .word 0
enemy_max: .byte 8
enemy_count: .byte 0
enemy_on: .byte 0
enemy_accel_count: .byte 0

check_enemies:
    lda enemy_on
    cmp #1
    bne @done
    lda enemy_count
    cmp enemy_max
    beq @done
    clc
    lda enemy_timer
    adc #1
    sta enemy_timer
    lda enemy_timer+1
    adc #0
    sta enemy_timer+1
    cmp enemy_launch_time+1
    bne @done
    lda enemy_timer
    cmp enemy_launch_time
    bne @done
    lda #0
    sta enemy_timer
    sta enemy_timer+1
    ; see where to launch enemy
    jsr set_ship_as_active
    ; see where ship Y is and put mine on opposite side of screen
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    cmp #>240
    bcc @enemy_bottom
    bne @enemy_top
    ldy #Entity::_pixel_y
    lda (active_entity), y
    cmp #<240
    bcc @enemy_bottom
@enemy_top:
    jsr launch_enemy_top
    rts
@enemy_bottom:
    jsr launch_enemy_bottom
    rts
@done:
    rts

ENEMY_4_5 = 60*15
ENEMY_6_7 = 60*13
ENEMY_8_UP = 60*11

enemy_compare_set:
    ; enemies start off
    lda #0
    sta enemy_on
    lda level
    cmp #4
    bcc @done ; no enemies on fields 0-3
    lda #1
    sta enemy_on ; enemies are on for rest of the fields
    lda level
@check_6:
    cmp #6
    bcs @check_8
    lda #<ENEMY_4_5
    sta enemy_launch_time
    lda #>ENEMY_4_5
    sta enemy_launch_time+1
    lda #6
    sta enemy_accel_count
    bra @done
@check_8:
    cmp #8
    bcs @max_enemies
    lda #<ENEMY_6_7
    sta enemy_launch_time
    lda #>ENEMY_6_7
    sta enemy_launch_time+1
    lda #7
    sta enemy_accel_count
    bra @done
@max_enemies:
    lda #<ENEMY_8_UP
    sta enemy_launch_time
    lda #>ENEMY_8_UP
    sta enemy_launch_time+1
    lda #8
    sta enemy_accel_count
@done:
    rts

.endif
