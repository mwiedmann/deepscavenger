ufo_start_x: .word 200<<5, 480<<5, 200<<5, 480<<5, 200<<5
ufo_start_y: .word 0<<5,   32<<5,  64<<5,  96<<5,  200<<5

create_ufo_sprites:
    lda #<UFO_LOAD_ADDR
    sta us_img_addr
    lda #>UFO_LOAD_ADDR
    sta us_img_addr+1
    ldx #0
    stx sp_entity_count
    ldx #UFO_SPRITE_NUM_START
    stx sp_num
    ldx #.sizeof(Entity)*UFO_ENTITY_NUM_START
    stx sp_offset
next_ufo:
    clc
    lda #<entities
    adc sp_offset
    sta active_entity
    lda #>entities
    adc #0
    sta active_entity+1
    lda #0
    sta param1 ; Not visible
    jsr reset_active_entity
    clc
    lda sp_entity_count ; Use this to get an index into ufo_start_?
    rol
    tax
    lda ufo_start_x, x
    ldy #Entity::_x
    sta (active_entity), y
    lda ufo_start_x+1, x
    ldy #Entity::_x+1
    sta (active_entity), y
    lda ufo_start_y, x
    ldy #Entity::_y
    sta (active_entity), y
    lda ufo_start_y+1, x
    ldy #Entity::_y+1
    sta (active_entity), y
    jsr move_entity ; Update the pixel positions
    lda us_img_addr ; Img addr
    ldy #Entity::_image_addr
    sta (active_entity), y
    lda us_img_addr+1 ; Img addr
    ldy #Entity::_image_addr+1
    sta (active_entity), y
    lda #UFO_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
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
    ; Increase the UFO img addr
    clc
    lda us_img_addr
    adc #<UFO_SPRITE_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>UFO_SPRITE_FRAME_SIZE
    sta us_img_addr+1
    lda sp_num
    inc
    sta sp_num
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #UFO_COUNT
    beq @done
    jmp next_ufo
@done:
    rts


launch_ufos:
    lda #4
    sta param1
    jsr launch_ufo
    lda #4
    sta param1
    jsr launch_ufo
    lda #4
    sta param1
    jsr launch_ufo
    lda #4
    sta param1
    jsr launch_ufo
    lda #4
    sta param1
    jsr launch_ufo
    rts

; param1 - ang
; param2 - img offset
launch_ufo:
    ldx #0
    stx sp_entity_count
    ldx #.sizeof(Entity)*UFO_ENTITY_NUM_START
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
    bne @skip_entity
    ; Found a free ufo
    lda param1
    ldy #Entity::_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    ldx #0
@initial_accel:
    ; Accelerate the ufo a few times to get it started moving
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
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #UFO_COUNT
    bne @next_entity
@done:
    rts