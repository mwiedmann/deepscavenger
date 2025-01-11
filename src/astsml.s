.ifndef ASTSML_S
ASTSML_S = 1

create_astsml_sprites:
    lda #<ASTSML_LOAD_ADDR
    sta us_img_addr
    lda #>ASTSML_LOAD_ADDR
    sta us_img_addr+1
    lda #<(ASTSML_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #ASTSML_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*ASTSML_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ASTSML_ENTITY_NUM_START)
    stx sp_offset+1
next_astsml:
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
    lda #ASTSML_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #2
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
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
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
    ; Increase the ASTSML img addr
    clc
    inc sp_num
    inc sp_entity_count
    lda sp_entity_count
    cmp #ASTSML_COUNT
    beq @done
    jmp next_astsml
@done:
    rts


astsml_ang_index: .byte 0
astsml_x: .word 0
astsml_y: .word 0

launch_astsml:
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*ASTSML_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ASTSML_ENTITY_NUM_START)
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
    jsr found_free_astsml
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
    cmp #ASTSML_COUNT
    bne @next_entity
@done:
    rts


found_free_astsml:
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
    lda astsml_x
    ldy #Entity::_x
    sta (active_entity), y
    lda astsml_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda astsml_y
    ldy #Entity::_y
    sta (active_entity), y
    lda astsml_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    ; Set its angle and accel once to get it going
    ; astsml_ang_index
    lda astsml_ang_index
    ldy #Entity::_ang
    sta (active_entity), y
    ; Accelerate the astsml to get it started moving
    jsr accel_entity
    jsr accel_entity
    rts

.endif
