move_entities:
    ldx #0
    stx sp_entity_count
    ldx #0
    stx sp_offset
@next_entity:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc #0
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
    bne @jump_to_no_collision ; If hi bytes are not equal, they are too far apart to collide 
    lda hc_comp_val2
    cmp hc_comp_val1 ; compare the lo bytes
    bcc @jump_to_no_collision ; A < B, no possible collision 
    ; 2nd check if x1+size < x2 (then it is to the left of the object and no collision)
    ; Load the _pixel_x into vars and increase x2 by size, then compare
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
    bne no_collision ; If hi bytes are not equal, they are too far apart to collide 
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision 
    ; 3rd check if y1 > y2+size (then it is to the right of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
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
    bne no_collision ; If hi bytes are not equal, they are too far apart to collide 
    lda hc_comp_val2
    cmp hc_comp_val1 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision 
     ; 4th check if y1+size < y2 (then it is to the left of the object and no collision)
    ; Load the _pixel_y into vars and increase y2 by size, then compare
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
    bne no_collision ; If hi bytes are not equal, they are too far apart to collide 
    lda hc_comp_val1
    cmp hc_comp_val2 ; compare the lo bytes
    bcc no_collision ; A < B, no possible collision 
    ; If we made it here, we have a collision!
    brk
    ; TODO: Disable at least one of the sprites
    ; Need to look at the sprite type to decide what to do (player death, score points, etc.)
no_collision:
    ; Go to the next inner entity
    clc
    lda comp_entity2
    adc #.sizeof(Entity)
    sta comp_entity2
    lda hc_inner_entity_count
    inc
    sta hc_inner_entity_count
    cmp #ENTITY_COUNT
    bne @keep_checking
    ; Reached last entity
    lda hc_outer_entity_count
    inc
    cmp #ENTITY_COUNT
    beq @done ; Reached end of list...stop
    sta hc_outer_entity_count ; Store the incremented outer index
    inc
    sta hc_inner_entity_count ; Inc and store as the starting inner index
    lda comp_entity1 ; Update the outer entity
    adc #.sizeof(Entity)
    sta comp_entity1
    clc
    adc #.sizeof(Entity)
    sta comp_entity2 ; Set the inner entity as 1 more (should match hc_inner_entity_count)
@keep_checking:
    jmp check_entities
@done:
    rts
