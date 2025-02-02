.ifndef GEM_S
GEM_S = 1

gem_number: .byte 0,     0,     0,     1,     1,     1,     2,     2,     3,     3,     4,     4,     5,     5,     6,     7
gem_score: .word  $0250, $0250, $0250, $0500, $0500, $0500, $0750, $0750, $1000, $1000, $2000, $2000, $3500, $3500, $5000, $7500

last_gem_number: .byte 0

create_gem_sprites:
    lda #<GEM_LOAD_ADDR
    sta us_img_addr
    lda #>GEM_LOAD_ADDR
    sta us_img_addr+1
    lda #<(GEM_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    sta last_gem_number
    stx sp_entity_count
    ldx #GEM_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*GEM_ENTITY_NUM_START)
    stx sp_offset+1
next_gem:
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
    lda #GEM_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #16
    ldy #Entity::_size
    sta (active_entity), y
    lda #12
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #2
    ldy #Entity::_coll_adj
    sta (active_entity), y
    lda #%11011000
    ldy #Entity::_collision_matrix
    sta (active_entity), y
    lda #%00000100
    ldy #Entity::_collision_id
    sta (active_entity), y
    lda #0
    ldy #Entity::_has_accel
    sta (active_entity), y
    ldy #Entity::_has_ang
    sta (active_entity), y
    lda #1
    ldy #Entity::_ob_behavior
    sta (active_entity), y
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set sprite num
    sta cs_sprite_num ; pass the sprite_num and create its sprite
    lda #%01010000
    sta cs_size ; 16x16
    jsr create_sprite
    lda sp_offset
    adc #.sizeof(Entity)
    sta sp_offset
    lda sp_offset+1
    adc #0
    sta sp_offset+1
    ; Increase the GEM img addr if next gem
    ldx sp_entity_count
    inx
    lda gem_number, x
    cmp last_gem_number
    beq @check_max
    sta last_gem_number
    ; new gem type, change gfx
    clc
    lda us_img_addr
    adc #<GEM_SPRITE_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>GEM_SPRITE_FRAME_SIZE
    sta us_img_addr+1
    lda us_img_addr+2
    adc #0
    sta us_img_addr+2
@check_max:
    inc sp_num
    inc sp_entity_count
    lda sp_entity_count
    cmp #GEM_COUNT
    beq @done
    jmp next_gem
@done:
    rts


dg_x: .word 0
dg_y: .word 0

drop_gem_from_active_entity:
    ldy #Entity::_x
    lda (active_entity), y
    sta dg_x
    ldy #Entity::_x+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta dg_x+1
    ldy #Entity::_y
    lda (active_entity), y
    sta dg_y
    ldy #Entity::_y+1
    lda (active_entity), y
    clc
    adc #>(8<<5)
    sta dg_y+1
    ldx #0
    stx sp_entity_count
    ; there are 16 astbigs and 16 gems
    ; pick the same gem sprite num as the astbig+16
    lda active_entity
    adc #<(.sizeof(Entity)*GEM_COUNT)
    sta sp_offset
    lda active_entity+1
    adc #>(.sizeof(Entity)*GEM_COUNT)
    sta sp_offset+1
    ; make the gem the active entity
    lda sp_offset
    sta active_entity
    lda sp_offset+1
    sta active_entity+1
    ; make it visible and config it
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    lda dg_x
    ldy #Entity::_x
    sta (active_entity), y
    lda dg_x+1
    ldy #Entity::_x+1
    sta (active_entity), y
    lda dg_y
    ldy #Entity::_y
    sta (active_entity), y
    lda dg_y+1
    ldy #Entity::_y+1
    sta (active_entity), y
    jsr set_gem_vel
@done:
    rts

GEM_VELOCITY=3

gem_vel: .word 65535-GEM_VELOCITY, 65535-GEM_VELOCITY, GEM_VELOCITY, 65535-GEM_VELOCITY, GEM_VELOCITY, GEM_VELOCITY, 65535-GEM_VELOCITY, GEM_VELOCITY
gem_vel_idx: .byte 0

set_gem_vel:
    ; _vel_x
    ldx gem_vel_idx
    lda gem_vel, x
    ldy #Entity::_vel_x 
    sta (active_entity), y
    inx
    lda gem_vel, x
    ldy #Entity::_vel_x+1
    sta (active_entity), y
    inx
    ; _vel_y
    lda gem_vel, x
    ldy #Entity::_vel_y
    sta (active_entity), y
    inx
    lda gem_vel, x
    ldy #Entity::_vel_y+1
    sta (active_entity), y
    inx
    cpx #16
    bne @done
    ldx #0
@done:
    stx gem_vel_idx
    rts

.endif
