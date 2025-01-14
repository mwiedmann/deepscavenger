.ifndef MINE_S
MINE_S = 1

create_mine_sprites:
    lda #<MINE_LOAD_ADDR
    sta us_img_addr
    lda #>MINE_LOAD_ADDR
    sta us_img_addr+1
    lda #<(MINE_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #MINE_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*MINE_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*MINE_ENTITY_NUM_START)
    stx sp_offset+1
next_mine:
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
    lda sp_entity_count
    rol
    tax
    lda #0
    ldy #Entity::_x
    sta (active_entity), y
    ldy #Entity::_x+1
    sta (active_entity), y
    ldy #Entity::_y
    sta (active_entity), y
    ldy #Entity::_y+1
    sta (active_entity), y
    ldy #Entity::_ang
    sta (active_entity), y
    jsr move_entity ; Update the pixel positions
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda us_img_addr+2 ; Img addr
    ldy #Entity::_image_addr+2
    sta (active_entity), y
    lda #MINE_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #10
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #3
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%10110000
    ldy #Entity::_collision
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set mine sprite num
    sta cs_sprite_num ; pass the sprite_num for the mine and create its sprite
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
    clc
    inc sp_num
    inc sp_entity_count
    lda sp_entity_count
    cmp #MINE_COUNT
    beq @done
    jmp next_mine
@done:
    rts


mine_x: .word 32
mine_y: .word 32

launch_mine:
    ; Copy ships y position for mine
    jsr set_ship_as_active
    ldy #Entity::_y
    lda (active_entity), y
    sta mine_y
    ldy #Entity::_y+1
    lda (active_entity), y
    sta mine_y+1
    ; see where ship X is and put mine on opposite side of screen
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    cmp #>320
    bcc @mine_right
    ldy #Entity::_pixel_x
    lda (active_entity), y
    cmp #<320
    bcc @mine_right
    ; mine left
    lda #<(16<<5)
    sta mine_x
    lda #>(16<<5)
    sta mine_x+1
    jmp @mine_x_set
@mine_right:
    ; mine right
    lda #<(620<<5)
    sta mine_x
    lda #>(620<<5)
    sta mine_x+1
@mine_x_set:
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*MINE_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*MINE_ENTITY_NUM_START)
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
    jsr found_free_mine
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
    cmp #MINE_COUNT
    bne @next_entity
@done:
    rts


found_free_mine:
    inc mine_count
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
    lda mine_x
    ldy #Entity::_x
    sta (active_entity), y
    lda mine_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda mine_y
    ldy #Entity::_y
    sta (active_entity), y
    lda mine_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    ; ; Set its angle and accel once to get it going
    ; ; astsml_ang_index
    lda #4
    ldy #Entity::_ang
    sta (active_entity), y
    ; ; Accelerate the astsml to get it started moving
    jsr accel_entity
    jsr accel_entity
    rts

mine_timer: .word 0
mine_max: .byte 5
mine_count: .byte 0

check_mines:
    lda mine_count
    cmp mine_max
    beq @done
    clc
    lda mine_timer
    adc #1
    sta mine_timer
    lda mine_timer+1
    adc #0
    sta mine_timer+1
    cmp #>300
    bne @done
    lda mine_timer
    cmp #<300
    bne @done
    lda #0
    sta mine_timer
    sta mine_timer+1
    jsr launch_mine
@done:
    rts

.endif
