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
    jsr move_entity
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
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #ENTITY_COUNT
    bne @next_entity
    ldx accelwait
    cpx #ENTITY_ACCEL_TICKS
    bne @done
    lda #0
    sta accelwait
@done:
    rts

hc_outer_entity_count: .byte 0
hc_inner_entity_count: .byte 0
hc_comp_val1: .word 0
hc_comp_val2: .word 0

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
    ldy #Entity::_collision
    lda (comp_entity1), y
    and (comp_entity2), y
    bne @check_actual_collisions
@jump_to_no_collision:
    jmp no_collision
    ; Now check if they overlap
    ; 1st check if x1 > x2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_x into vars and increase x2 by size, then compare
@check_actual_collisions:
    clc
    ldy #Entity::_pixel_x
    lda (comp_entity1), y
    sta hc_comp_val1
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    sta hc_comp_val1+1
    ldy #Entity::_pixel_x
    lda (comp_entity2), y
    ldy #Entity::_size
    adc (comp_entity2), y
    sta hc_comp_val2
    ldy #Entity::_pixel_x+1
    lda (comp_entity2), y
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
    ldy #Entity::_size
    adc (comp_entity1), y
    sta hc_comp_val1
    ldy #Entity::_pixel_x+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    ldy #Entity::_pixel_x
    lda (comp_entity2), y
    sta hc_comp_val2
    ldy #Entity::_pixel_x+1
    lda (comp_entity2), y
    sta hc_comp_val2+1
    ; values are ready to compare
    lda hc_comp_val1+1
    cmp hc_comp_val2+1 ; compare the hi bytes
    bcc no_collision ; If hi bytes are not equal, they are too far apart to collide
    bne @y1_check
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision 
    ; 3rd check if y1 > y2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
@y1_check:
    clc
    ldy #Entity::_pixel_y
    lda (comp_entity1), y
    sta hc_comp_val1
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    sta hc_comp_val1+1
    ldy #Entity::_pixel_y
    lda (comp_entity2), y
    ldy #Entity::_size
    adc (comp_entity2), y
    sta hc_comp_val2
    ldy #Entity::_pixel_y+1
    lda (comp_entity2), y
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
    ldy #Entity::_size
    adc (comp_entity1), y
    sta hc_comp_val1
    ldy #Entity::_pixel_y+1
    lda (comp_entity1), y
    adc #0
    sta hc_comp_val1+1
    ldy #Entity::_pixel_y
    lda (comp_entity2), y
    sta hc_comp_val2
    ldy #Entity::_pixel_y+1
    lda (comp_entity2), y
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
    lda hc_inner_entity_count
    inc
    sta hc_inner_entity_count
    cmp #ENTITY_COUNT
    beq last_inner_entity
    jmp check_entities
last_inner_entity:
    ; Reached last entity
    lda hc_outer_entity_count
    inc
    sta hc_outer_entity_count ; Store the incremented outer index
    cmp #ENTITY_COUNT-1
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
    
handle_collision_sprites:
    jsr clear_amount_to_add ; Clear the scoring amount
    ldy #Entity::_type
    lda (comp_entity1), y
    cmp #LASER_TYPE
    bne @check_astsml
    jsr collision_laser
    bra @done
@check_astsml:
    cmp #ASTSML_TYPE
    bne @check_astbig
    jsr collision_astsml
    bra @done
@check_astbig:
    cmp #ASTBIG_TYPE
    bne @check_gem
    jsr collision_astbig
    bra @done
@check_gem:
    cmp #GEM_TYPE
    bne @check_gate
    jsr collision_gem
    bra @done
@check_gate:
    cmp #GATE_TYPE
    bne @check_warp
    jsr collision_gate
    bra @done
@check_warp:
    cmp #WARP_TYPE
    bne @catch_all
    jsr collision_warp
    bra @done
@catch_all:
    jsr destroy_1 ; Catch all, shouldn't get here
    bra @done
    ; Cases
    ; Laser - ASTSML - ASTBIG - Gem - Gate - Warp - Ship
@done:
    jsr update_score
    rts


collision_laser:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #ASTSML_TYPE
    beq @laser_astsml
    cmp #ASTBIG_TYPE
    beq @laser_astbig
    cmp #GEM_TYPE
    beq @laser_gem
    jsr destroy_1 ; Laser hitting anything else just destroys the laser
    rts
@laser_astsml:
    ; Destroy both - score points
    lda #$10
    sta amount_to_add
    jsr add_points
    jsr destroy_both
    rts
@laser_astbig:
    ; Destroy both - score points
    lda #$25
    sta amount_to_add
    jsr add_points
    jsr split_2
    jsr destroy_1
    rts
@laser_gem:
    ; Destroy Gem
    jsr destroy_2
    rts

collision_astsml:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #ASTBIG_TYPE
    beq @astsml_astbig
    cmp #GEM_TYPE
    beq @astsml_gem
    cmp #GATE_TYPE
    beq @astsml_gate
    cmp #SHIP_TYPE
    beq @astsml_ship
    jsr destroy_1 ; If sml hits sml, only 1 will be destroyed
    rts
@astsml_astbig:
    ; Split the big, destroy sml
    jsr split_2
    jsr destroy_1
    rts
@astsml_gem:
    ; Destroy Gem
    jsr destroy_2
    rts
@astsml_gate:
    ; Destroy astsml
    jsr destroy_1
    rts
@astsml_ship:
    ; Both die
    jsr destroy_both
    rts

collision_astbig:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #GEM_TYPE
    beq @astbig_gem
    cmp #GATE_TYPE
    beq @astbig_gate
    cmp #SHIP_TYPE
    beq @astbig_ship
    jsr destroy_1
    rts
@astbig_gem:
    ; Destroy Gem
    jsr destroy_2
    rts
@astbig_gate:
    ; Destroy astbig
    jsr destroy_1
    rts
@astbig_ship:
    ; Both die
    jsr destroy_both
    rts

collision_gem:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #SHIP_TYPE
    beq @gem_ship
    jsr destroy_1
    rts
@gem_ship:
    ; Ship gets gem and points
    lda #$50
    sta amount_to_add
    lda #$1
    sta amount_to_add+1
    jsr add_points
    jsr show_warp
    jsr destroy_1
    rts

collision_warp:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #SHIP_TYPE
    beq @warp_ship
    jsr destroy_1
    rts
@warp_ship:
    lda #1
    sta hit_warp
    jsr destroy_1
    rts

collision_gate:
    ldy #Entity::_type
    lda (comp_entity2), y
    cmp #SHIP_TYPE
    beq @gate_ship
    jsr destroy_2 ; Not sure what else this would be, but gate is indestructable
    rts
@gate_ship:
    ; Ship crashes
    jsr destroy_2
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
    rts


split_ang_1: .byte 0
split_ang_2: .byte 0

split_1:
    ldy #Entity::_x
    lda (comp_entity1), y
    sta astsml_x
    ldy #Entity::_x+1
    lda (comp_entity1), y
    sta astsml_x+1
    ldy #Entity::_y
    lda (comp_entity1), y
    sta astsml_y
    ldy #Entity::_y+1
    lda (comp_entity1), y
    sta astsml_y+1
    ; Rotate to opposite side (almost)
    ; Both asteroids will fly the other in slightly different directions
    ldy #Entity::_ang
    lda (comp_entity1), y
    ldx #0
    clc
@next_ang:
    inc
    cmp #16
    bne @skip_back_to_zero
    lda #0
@skip_back_to_zero:
    sta split_ang_1
    inx
    cpx #6
    bne @next_ang
    lda comp_entity1
    sta active_entity
    lda comp_entity1+1
    sta active_entity+1
    jsr destroy_active_entity
    jsr launch_astsml
    rts


split_2:
    ldy #Entity::_x
    lda (comp_entity2), y
    sta astsml_x
    ldy #Entity::_x+1
    lda (comp_entity2), y
    sta astsml_x+1
    ldy #Entity::_y
    lda (comp_entity2), y
    sta astsml_y
    ldy #Entity::_y+1
    lda (comp_entity2), y
    sta astsml_y+1
    ; Rotate to opposite side (almost)
    ; Both asteroids will fly the other in slightly different directions
    ldy #Entity::_ang
    lda (comp_entity2), y
    ldx #0
    clc
@next_ang:
    inc
    cmp #16
    bne @skip_back_to_zero
    lda #0
@skip_back_to_zero:
    sta split_ang_1
    inx
    cpx #10
    bne @next_ang
    lda comp_entity2
    sta active_entity
    lda comp_entity2+1
    sta active_entity+1
    jsr destroy_active_entity
    jsr launch_astsml
    rts

destroy_active_entity:
    ldy #Entity::_type
    lda (active_entity), y
    cmp #GATE_TYPE
    beq @skip_gate
    ldy #Entity::_visible
    lda #0 ; Hide it
    sta (active_entity), y
    ldy #Entity::_sprite_num
    lda (active_entity), y
    sta param1
    jsr update_sprite
@skip_gate:
    rts

.endif