.ifndef ENTITIES_S
ENTITIES_S = 1

move_entities:
    ldx #0
    stx sp_entity_count
    ldx #0
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
    beq @skip_entity ; Skip if not visible
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS ; We only thrust entities every few ticks (otherwise they take off SUPER fast)
    bne @skip_accel
    ldy #Entity::_has_accel
    lda (active_entity), y
    cmp #0
    beq @skip_accel
    jsr accel_entity
@skip_accel:
    ldy #Entity::_destroy_ticks ; See if entity is destroyed after some time
    lda (active_entity), y
    cmp #0
    beq @skip_destroy
    dec
    sta (active_entity), y
    cmp #0
    bne @skip_destroy
    ldy #Entity::_visible
    sta (active_entity), y
@skip_destroy:
    jsr move_entity
    jsr enemy_logic
    jsr mine_logic
    lda #0
    sta param1 ; make entity not visible if out of bounds
    jsr check_entity_bounds
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
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
    cmp #ENTITY_COUNT
    bne @next_entity
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS
    bne @done
    lda #0
    sta accelwait
@done:
    ; See if enemy firing should reset
    lda enemywait
    cmp #ENEMY_SHOOT_TIME
    bne @skip_enemywait_reset
    lda #0
    sta enemywait
    rts
@skip_enemywait_reset:
    inc enemywait
    rts

target_x: .word 0
target_y: .word 0
mine_diff_x: .word 0
mine_diff_y: .word 0
mine_y_adj: .byte 0

mine_logic:
    ldy #Entity::_type
    lda (active_entity), y
    cmp #MINE_TYPE
    beq @mine_yes
    rts
@mine_yes:
    ; if ship is dead, destroy the mine
    lda ship_dead
    cmp #0
    beq @ship_alive
    jsr destroy_active_entity
    rts
@ship_alive:
    ; move towards ship
    jsr kill_velocity
    ; load ship to get x/y
    ldx #<ship
    stx comp_entity1
    ldx #>ship
    stx comp_entity1+1
    ldy #Entity::_pixel_x
    lda (comp_entity1), y
    sta target_x
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    sta target_x+1
    ldy #Entity::_pixel_y
    lda (comp_entity1), y
    sta target_y
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    sta target_y+1
    ; compare x and move mine towards ship
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    cmp target_x+1
    bcc @mine_x_less
    bne @mine_x_greater
    ; check low bits
    ldy #Entity::_pixel_x
    lda (active_entity), y
    cmp target_x
    bcs @mine_x_greater
    ; mine less
@mine_x_less:
    ; first store diff
    sec
    lda target_x
    ldy #Entity::_pixel_x
    sbc (active_entity), y
    sta mine_diff_x
    lda target_x+1
    ldy #Entity::_pixel_x+1
    sbc (active_entity), y
    sta mine_diff_x+1
    ; set base angle
    ldy #Entity::_ang
    lda #4
    sta (active_entity), y
    lda #0
    sta mine_y_adj
    bra @check_mine_y
@mine_x_greater:
    ; first store diff
    sec
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sbc target_x
    sta mine_diff_x
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sbc target_x+1
    sta mine_diff_x+1
    ; set base angle
    ldy #Entity::_ang
    lda #12
    sta (active_entity), y
    lda #1
    sta mine_y_adj
@check_mine_y:
    ; compare y and move mine towards ship
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    cmp target_y+1
    bcc @mine_y_less
    bne @mine_y_greater
    ; check low bits
    ldy #Entity::_pixel_y
    lda (active_entity), y
    cmp target_y
    bcs @mine_y_greater
    ; mine less
@mine_y_less:
    ; first store diff
    sec
    lda target_y
    ldy #Entity::_pixel_y
    sbc (active_entity), y
    sta mine_diff_y
    lda target_y+1
    ldy #Entity::_pixel_y+1
    sbc (active_entity), y
    sta mine_diff_y+1
    ; check adj direction
    lda mine_y_adj
    cmp #0
    beq @mine_add
    bra @mine_sub
@mine_y_greater:
    ; first store diff
    sec
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sbc target_y
    sta mine_diff_y
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sbc target_y+1
    sta mine_diff_y+1
    ; check adj direction
    lda mine_y_adj
    cmp #0
    beq @mine_sub
@mine_add:
    lda mine_diff_x+1
    cmp mine_diff_y+1
    beq @mine_add_check_lower
    bcs @mine_add_x_greater
    bra @mine_add_x_less
@mine_add_check_lower:
    lda mine_diff_x
    cmp mine_diff_y
    beq @mine_add_x_even
    bcs @mine_add_x_greater
    bra @mine_add_x_less
@mine_add_x_even:
    ldy #Entity::_ang
    lda (active_entity), y
    clc
    adc #2
    sta (active_entity), y
    bra @accel
@mine_add_x_greater:
    ldy #Entity::_ang
    lda (active_entity), y
    clc
    adc #1
    sta (active_entity), y
    bra @accel
@mine_add_x_less:
    ldy #Entity::_ang
    lda (active_entity), y
    clc
    adc #3
    sta (active_entity), y
    bra @accel
@mine_sub:
    lda mine_diff_x+1
    cmp mine_diff_y+1
    beq @mine_sub_check_lower
    bcs @mine_sub_x_greater
    bra @mine_sub_x_less
@mine_sub_check_lower:
    lda mine_diff_x
    cmp mine_diff_y
    beq @mine_sub_x_even
    bcs @mine_sub_x_greater
    bra @mine_sub_x_less
@mine_sub_x_even:
    ldy #Entity::_ang
    lda (active_entity), y
    sec
    sbc #2
    sta (active_entity), y
    bra @accel
@mine_sub_x_greater:
    ldy #Entity::_ang
    lda (active_entity), y
    sec
    sbc #1
    sta (active_entity), y
    bra @accel
@mine_sub_x_less:
    ldy #Entity::_ang
    lda (active_entity), y
    sec
    sbc #3
    sta (active_entity), y
@accel:
    ; Accelerate the mine to get it started moving
    lda mine_accel_count
@accel_loop:
    pha
    jsr accel_entity
    pla
    dec
    cmp #0
    bne @accel_loop
    rts

enemy_logic:
    ldy #Entity::_type
    lda (active_entity), y
    cmp #ENEMY_TYPE
    bne @done
    ; check if enemy should change dir
    jsr enemy_change_dir
    lda enemywait
    cmp #ENEMY_SHOOT_TIME
    bne @done
    ; Fire a laser
    ; adjust position by 8 since missiles are smaller
    clc
    ldy #Entity::_x
    lda (active_entity), y
    adc #<(8<<5)
    sta fel_x
    ldy #Entity::_x+1
    lda (active_entity), y
    adc #>(8<<5)
    sta fel_x+1
    clc
    ldy #Entity::_y
    lda (active_entity), y
    adc #<(8<<5)
    sta fel_y
    ldy #Entity::_y+1
    lda (active_entity), y
    adc #>(8<<5)
    sta fel_y+1
    ldy #Entity::_ang
    lda (active_entity), y
    sta fel_ang_index
    ldy #Entity::_vel_x
    lda (active_entity), y
    sta fel_vel_x
    ldy #Entity::_vel_x+1
    lda (active_entity), y
    sta fel_vel_x+1
    ldy #Entity::_vel_y
    lda (active_entity), y
    sta fel_vel_y
    ldy #Entity::_vel_y+1
    lda (active_entity), y
    sta fel_vel_y+1
    jsr fire_enemy_laser
@done:
    rts
    
enemy_dir: .byte 2, 3, 2, 1, 2, 2, 3, 4, 3, 2, 1
enemy_index_x: .word 0

kill_velocity:
    lda #0
    ldy #Entity::_vel_x
    sta (active_entity), y
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    ldy #Entity::_vel_y
    sta (active_entity), y
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta enemy_index_x
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta enemy_index_x+1
    rts

enemy_change_dir:
    jsr kill_velocity
    ldx #0
@shift_x:
    ; Shift down 6 times to get an index
    clc
    lda enemy_index_x+1
    ror
    sta enemy_index_x+1
    lda enemy_index_x
    ror
    sta enemy_index_x
    inx
    cpx #6
    bne @shift_x
    ldx enemy_index_x
    lda enemy_dir, x
    ldy #Entity::_ang
    sta (active_entity), y
    ; Accelerate the enemy to get moving in correct dir
    ldx #0
@accel:
    phx
    jsr accel_entity
    plx
    inx
    cpx enemy_accel_count
    bne @accel
    rts

hc_outer_entity_count: .byte 0
hc_inner_entity_count: .byte 0
hc_comp_val1: .word 0
hc_comp_val2: .word 0
hc_overlap: .byte 0

handle_collision:
    ldx #0
    stx hc_outer_entity_count
    ldx #1
    stx hc_inner_entity_count
    ldx #<entities ; entity 0
    stx comp_entity1
    ldx #>entities
    stx comp_entity1+1
    ldx #<(entities+.sizeof(Entity)) ; entity 1
    stx comp_entity2
    ldx #>(entities+.sizeof(Entity))
    stx comp_entity2+1
check_entities:
    ; See if entities are colliding
    ; First check if these CAN collidate
    ldy #Entity::_visible ; Is this entity even visible
    lda (comp_entity1), y
    cmp #1
    beq @check_other_visible
    jmp last_inner_entity ; Outer entity isn't visible
@check_other_visible:
    lda (comp_entity2), y
    cmp #1
    beq @check_collision_flags
    jmp no_collision ; Inner entity isn't visible
@check_collision_flags:
    ldy #Entity::_type ; Same types can't collide
    lda (comp_entity1), y
    cmp (comp_entity2), y
    beq @jump_to_no_collision
    ; Different types, see if they can collide
    ldy #Entity::_collision_id
    lda (comp_entity1), y
    ldy #Entity::_collision_matrix
    and (comp_entity2), y
    cmp #0
    beq @jump_to_no_collision
    jmp @check_actual_collisions
@jump_to_no_collision:
    jmp no_collision
    ; Now check if they overlap
    ; 1st check if x1 > x2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_x into vars and increase x2 by size, then compare
@check_actual_collisions:
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_x+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_x+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_x+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    clc
    lda hc_comp_val2
    ldy #Entity::_coll_size
    adc (comp_entity2), y ; now add coll_size=x2+size
    sta hc_comp_val2
    lda hc_comp_val2+1
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val2+1
    cmp hc_comp_val1+1 ; compare the hi bytes
    bcc @jump_to_no_collision ; If hi bytes are not equal, they are too far apart to collide 
    bne @x2_check
    lda hc_comp_val2
    cmp hc_comp_val1 ; compare the lo bytes
    bcc @jump_to_no_collision ; A < B, no possible collision 
    ; 2nd check if x1+size < x2 (then it is to the left of the object and no collision)
    ; Load the _pixel_x into vars and increase x2 by size, then compare
@x2_check:
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_x+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    lda hc_comp_val1
    ldy #Entity::_coll_size
    adc (comp_entity1), y ; add coll_size=x1+size
    sta hc_comp_val1
    lda hc_comp_val1+1
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_x+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_x+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val1+1
    cmp hc_comp_val2+1 ; compare the hi bytes
    bcc @early_no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @y1_check
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc @early_no_collision ; A < B, no possible collision 
    ; 3rd check if y1 > y2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
    jmp @y1_check
@early_no_collision:
    jmp no_collision
@y1_check:
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_y+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_y+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_y+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    clc
    lda hc_comp_val2
    ldy #Entity::_coll_size
    adc (comp_entity2), y ; now add coll_size=x2+size
    sta hc_comp_val2
    lda hc_comp_val2+1
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val2+1
    cmp hc_comp_val1+1 ; compare the hi bytes
    bcc no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @y2_check
    lda hc_comp_val2
    cmp hc_comp_val1 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision 
     ; 4th check if y1+size < y2 (then it is to the left of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
@y2_check:
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity1), y
    ldy #Entity::_coll_adj
    adc (comp_entity1), y ; pixel_y+coll_adj=x1
    sta hc_comp_val1
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    clc
    lda hc_comp_val1
    ldy #Entity::_coll_size
    adc (comp_entity1), y ; add coll_size=x1+size
    sta hc_comp_val1
    lda hc_comp_val1+1
    adc #0
    sta hc_comp_val1+1
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity2), y
    ldy #Entity::_coll_adj
    adc (comp_entity2), y ; pixel_y+coll_adj=x2
    sta hc_comp_val2
    ldy #Entity::_pixel_y+1
    lda (comp_entity2), y
    adc #0
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val1+1
    cmp hc_comp_val2+1 ; compare the hi bytes
    bcc no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @got_collision
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision
@got_collision: 
    ; If we made it here, we have a collision!
    jsr handle_collision_sprites
    lda hcs_keep_going
    cmp #1
    beq no_collision ; Look for more collisions or stop
    rts
    ; Need to look at the sprite type to decide what to do (player death, score points, etc.)
no_collision:
    ; Go to the next inner entity
    clc
    lda comp_entity2
    adc #.sizeof(Entity)
    sta comp_entity2
    lda comp_entity2+1
    adc #0
    sta comp_entity2+1
    inc hc_inner_entity_count
    lda hc_inner_entity_count
    cmp #ENTITY_COUNT
    beq last_inner_entity
    jmp check_entities
last_inner_entity:
    ; Reached last entity
    inc hc_outer_entity_count ; Update the outer index
    lda hc_outer_entity_count 
    cmp #ASTSML_ENTITY_NUM_START
    beq @something_wrong ;@done ; Reached end of list...stop
    inc ; Inc and store as the starting inner index
    sta hc_inner_entity_count 
    clc
    lda comp_entity1 ; Update the outer entity
    adc #.sizeof(Entity)
    sta comp_entity1
    lda comp_entity1+1
    adc #0
    sta comp_entity1+1
    clc
    lda comp_entity1 ; Set the inner entity to 1 more than the outer
    adc #.sizeof(Entity)
    sta comp_entity2
    lda comp_entity1+1
    adc #0
    sta comp_entity2+1
    jmp check_entities
@done:
    rts
@something_wrong:
    rts

hcs_keep_going: .byte 0

handle_collision_sprites:
    lda #0
    sta hcs_keep_going
    jsr clear_amount_to_add ; Clear the scoring amount
    ldy #Entity::_type
    lda (comp_entity1), y
    cmp #SHIP_TYPE
    bne @check_laser
    jsr collision_ship
    bra @done
@check_laser:
    cmp #LASER_TYPE
    bne @check_enemy
    jsr collision_laser
    bra @done
@check_enemy:
    cmp #ENEMY_TYPE
    bne @check_enemy_laser
    jsr collision_enemy
    bra @done
@check_enemy_laser:
    cmp #ENEMY_LASER_TYPE
    bne @catch_all
    jsr collision_enemy_laser
    bra @done
@catch_all:
    ;jsr destroy_1 ; Catch all, shouldn't get here
    bra @done
@done:
    jsr update_score
    rts

count_gems:
    clc
    inc gem_count
check_gems:
    lda gem_count
    cmp launch_amount
    bcc @no_warp
    jsr show_warp
@no_warp:
    rts

collision_ship:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #ENEMY_TYPE
    beq @ship_enemy
    cmp #ENEMY_LASER_TYPE
    beq @ship_enemy_laser
    cmp #MINE_TYPE
    beq @ship_mine
    cmp #ASTSML_TYPE
    beq @ship_astsml
    cmp #ASTBIG_TYPE
    beq @ship_astbig
    cmp #GEM_TYPE
    beq @ship_gem
    cmp #WARP_TYPE
    beq @ship_warp
    rts
@ship_enemy:
    ; Both die
    jsr destroy_ship
    jsr destroy_2
    rts
@ship_enemy_laser:
    ; Both die
    jsr destroy_ship
    jsr destroy_2
    rts
@ship_mine:
    ; Both die
    jsr destroy_ship
    jsr destroy_2
    rts
@ship_astsml:
    ; Destroy both
    jsr destroy_ship
    jsr destroy_2
    rts
@ship_astbig:
    ; Destroy both
    jsr destroy_ship
    jsr split_2
    rts
@ship_gem:
    ; Ship gets gem and points
    jsr clear_amount_to_add
    ; 750
    lda #$50
    sta amount_to_add
    lda #$07
    sta amount_to_add+1
    jsr add_points
    jsr count_gems
    jsr destroy_2
    rts
@ship_warp:
    lda #1
    sta hit_warp
    jsr destroy_1 ; Just hide the ship, doesn't count as a death
    jsr destroy_2
    rts

collision_laser:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #ENEMY_TYPE
    beq @laser_enemy
    cmp #MINE_TYPE
    beq @laser_mine
    cmp #ASTSML_TYPE
    beq @laser_astsml
    cmp #ASTBIG_TYPE
    beq @laser_astbig
    cmp #GEM_TYPE
    beq @laser_gem
    rts
@laser_enemy:
    ; Destroy both - score points
    jsr clear_amount_to_add
    ; 500
    lda #$5
    sta amount_to_add+1
    jsr add_points
    jsr destroy_both
    rts
@laser_mine:
    ; Destroy both - score points
    jsr clear_amount_to_add
    ; 50
    lda #$75
    sta amount_to_add
    jsr add_points
    jsr destroy_both
    rts
@laser_astsml:
    ; Destroy both - score points
    jsr clear_amount_to_add
    ; 50
    lda #$50
    sta amount_to_add
    jsr add_points
    jsr destroy_both
    rts
@laser_astbig:
    ; Split astbig, destroy laser - score points
    jsr clear_amount_to_add
    ; 125
    lda #$25
    sta amount_to_add
    lda #$01
    sta amount_to_add+1
    jsr add_points
    jsr destroy_1
    jsr split_2
    rts
@laser_gem:
    ; Destroy both
    jsr count_gems
    jsr destroy_both
    rts

collision_enemy:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #ASTSML_TYPE
    beq @enemy_astsml
    cmp #ASTBIG_TYPE
    beq @enemy_astbig
    cmp #GEM_TYPE
    beq @enemy_gem
    rts
@enemy_astsml:
    ; Destroy ast
    jsr destroy_2
    rts
@enemy_astbig:
    ; Split the big
    jsr split_2
    rts
@enemy_gem:
    ; Destroy gem
    jsr count_gems
    jsr destroy_2
    rts

collision_enemy_laser:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #ASTSML_TYPE
    beq @enemy_astsml
    cmp #ASTBIG_TYPE
    beq @enemy_astbig
    cmp #GEM_TYPE
    beq @enemy_gem
    rts
@enemy_astsml:
    ; Destroy both
    jsr destroy_both
    rts
@enemy_astbig:
    ; Split the big, destroy laser
    jsr destroy_1
    jsr split_2
    rts
@enemy_gem:
    ; Destroy both
    jsr count_gems
    jsr destroy_both
    rts

create_explosion_active_entity:
    ldy #Entity::_pixel_x
    lda (active_entity), y
    sta os_x
    ldy #Entity::_pixel_x+1
    lda (active_entity), y
    sta os_x+1
    ldy #Entity::_pixel_y
    lda (active_entity), y
    sta os_y
    ldy #Entity::_pixel_y+1
    lda (active_entity), y
    sta os_y+1
    jsr create_oneshot
    rts

destroy_1:
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr destroy_active_entity
    rts

destroy_2:
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr destroy_active_entity
    rts

destroy_both:
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr destroy_active_entity
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr destroy_active_entity
    jsr create_explosion_active_entity
    rts

destroy_ship:
    ; Ship is always entity1 in this case
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr create_explosion_active_entity
    jsr destroy_active_entity
    lda lives
    cmp #0
    bne @more_lives
    ; game over
    lda #1
    sta game_over
    jsr show_game_over
    lda #DEAD_SHIP_TIME
    sta ship_dead
    rts
@more_lives:
    dec lives
    jsr show_header
    lda #DEAD_SHIP_TIME
    sta ship_dead
    rts

split_index_1: .byte 1
split_index_2: .byte 6
split_index_3: .byte 11
split_index_4: .byte 13

split_1:
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr split_active_entity
    rts

split_2:
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr split_active_entity
    rts

split_active_entity:
    jsr create_explosion_active_entity
    jsr destroy_active_entity
    lda active_entity
    sta hold
    lda active_entity+1
    sta hold+1
    jsr drop_gem_from_active_entity
    lda hold
    sta active_entity
    lda hold+1
    sta active_entity+1
    ldy #Entity::_x
    lda (active_entity), y
    sta astsml_x
    ldy #Entity::_x+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta astsml_x+1
    ldy #Entity::_y
    lda (active_entity), y
    sta astsml_y
    ldy #Entity::_y+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta astsml_y+1
    ; All asteroids need to fly in slightly different directions
    lda split_index_1
    sta astsml_ang_index
    inc; stays between 0-4
    cmp #5
    bne @no_wrap_1
    lda #0
@no_wrap_1:
    sta split_index_1
    jsr launch_astsml
    ; 2nd astsml, active_entity now the astsml that was just launched
    lda split_index_2
    sta astsml_ang_index
    inc; stays between 5-7
    cmp #8
    bne @no_wrap_2
    lda #5
@no_wrap_2:
    sta split_index_2
    jsr launch_astsml
    ; 3rd astsml, active_entity now the astsml that was just launched
    lda split_index_3
    sta astsml_ang_index
    inc; stays between 8-12
    cmp #13
    bne @no_wrap_3
    lda #8
@no_wrap_3:
    sta split_index_3
    jsr launch_astsml
    ; 4th astsml, active_entity now the astsml that was just launched
    lda split_index_4
    sta astsml_ang_index
    inc; stays between 13-15
    cmp #16
    bne @no_wrap_4
    lda #13
@no_wrap_4:
    sta split_index_4
    jsr launch_astsml
    rts


destroy_active_entity:
    ldy #Entity::_type
    lda (active_entity), y
    ldy #Entity::_visible
    lda #0 ; Hide it
    sta (active_entity), y
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
    rts

.endif