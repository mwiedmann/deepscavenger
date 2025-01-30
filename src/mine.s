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
    lda #%11000000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000010
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set mine sprite num
    sta cs_sprite_num ; pass the sprite_num for the mine and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
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
    ; see where ship X is and put mine on opposite side of screen
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    cmp #>320
    bcc @mine_right
    bne @mine_left
    ldy #Entity::_pixel_x
    lda (active_entity), y
    cmp #<320
    bcc @mine_right
@mine_left:
    lda #<(16<<5)
    sta mine_x
    lda #>(16<<5)
    sta mine_x+1
    bra @mine_y_check
@mine_right:
    ; mine right
    lda #<(620<<5)
    sta mine_x
    lda #>(620<<5)
    sta mine_x+1
@mine_y_check:
    ; see where ship Y is and put mine on opposite side of screen
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    cmp #>240
    bne @mine_top
    ldy #Entity::_pixel_y
    lda (active_entity), y
    cmp #<240
    bcc @mine_bottom
@mine_top:
    lda #<(16<<5)
    sta mine_y
    lda #>(16<<5)
    sta mine_y+1
    bra @mine_checks_done
@mine_bottom:
    ; mine bottom
    lda #<(460<<5)
    sta mine_y
    lda #>(460<<5)
    sta mine_y+1
@mine_checks_done:
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
    inc current_mine_count
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
    lda #4
    ldy #Entity::_ang
    sta (active_entity), y
    rts

mine_timer: .word 0
mine_launch_time: .word 0
mine_max: .byte 16
mine_count: .byte 0
mines_on: .byte 0
mine_accel_count: .byte 0
current_mine_count: .byte 0

check_mines:
    lda mines_on
    cmp #1
    bne @done
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
    cmp mine_launch_time+1
    bne @done
    lda mine_timer
    cmp mine_launch_time
    bne @done
    lda #0
    sta mine_timer
    sta mine_timer+1
    jsr launch_mine
@done:
    rts

MINES_2_3 = 240;60*20
MINES_4_5 = 60*19
MINES_6_7 = 60*16
MINES_8_UP = 60*14

mine_compare_set:
    ; mines start off
    lda #0
    sta mines_on
    lda level
    ; cmp #2
    ; bcc @done ; no mines on fields 0-1
    lda #1
    sta mines_on ; mines are on for rest of the fields
    lda level
    cmp #4
    bcs @check_6
    lda #<MINES_2_3
    sta mine_launch_time
    lda #>MINES_2_3
    sta mine_launch_time+1
    lda #3
    sta mine_accel_count
    bra @done
@check_6:
    cmp #6
    bcs @check_8
    lda #<MINES_4_5
    sta mine_launch_time
    lda #>MINES_4_5
    sta mine_launch_time+1
    lda #4
    sta mine_accel_count
    bra @done
@check_8:
    cmp #8
    bcs @max_mines
    lda #<MINES_6_7
    sta mine_launch_time
    lda #>MINES_6_7
    sta mine_launch_time+1
    lda #5
    sta mine_accel_count
    bra @done
@max_mines:
    lda #<MINES_8_UP
    sta mine_launch_time
    lda #>MINES_8_UP
    sta mine_launch_time+1
    lda #6
    sta mine_accel_count
@done:
    rts

.endif
