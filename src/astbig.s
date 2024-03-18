.ifndef ASTBIG_S
ASTBIG_S = 1

astbig_start_x: .word   160<<5, 320<<5, 480<<5, 60<<5,  220<<5, 380<<5, 0<<5, 0<<5,  608<<5, 608<<5
astbig_start_y: .word   24<<5,   32<<5,   0<<5,  448<<5, 448<<5, 448<<5, 60<<5, 220<<5, 160<<5, 320<<5
astbig_start_ang: .word 4,      12,     11,     15,     3,      14,      4,     5,      15,     13

create_astbig_sprites:
    lda #<ASTBIG_LOAD_ADDR
    sta us_img_addr
    lda #>ASTBIG_LOAD_ADDR
    sta us_img_addr+1
    lda #<(ASTBIG_LOAD_ADDR>>16)
    sta us_img_addr+2
    ldx #0
    stx sp_entity_count
    ldx #ASTBIG_SPRITE_NUM_START
    stx sp_num
    ldx #<(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx sp_offset+1
next_astbig:
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
    lda sp_entity_count ; Use this to get an index into astbig_start_?
    rol
    tax
    lda astbig_start_x, x
    ldy #Entity::_x
    sta (active_entity), y
    lda astbig_start_x+1, x
    ldy #Entity::_x+1
    sta (active_entity), y
    lda astbig_start_y, x
    ldy #Entity::_y
    sta (active_entity), y
    lda astbig_start_y+1, x
    ldy #Entity::_y+1
    sta (active_entity), y
    lda astbig_start_ang, x
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
    lda #ASTBIG_TYPE
    ldy #Entity::_type
    sta (active_entity), y
    lda #2
    ldy #Entity::_has_ang
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
    lda sp_num
    ldy #Entity::_sprite_num
    sta (active_entity), y ; Set enemy sprite num
    sta cs_sprite_num ; pass the sprite_num for the enemy and create its sprite
    lda #%10100000
    sta cs_size ; 32x32
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
    ; Increase the ASTBIG img addr
    clc
    lda sp_num
    inc
    sta sp_num
    lda sp_entity_count
    inc
    sta sp_entity_count
    cmp #ASTBIG_COUNT
    beq @done
    jmp next_astbig
@done:
    rts


launch_astbigs:
    ldx #0
@next_astbig:
    stx param1 ; Currently doesn't do anything but maybe later
    phx
    jsr launch_astbig
    plx
    inx
    cpx #ASTBIG_COUNT
    bne @next_astbig
    rts

; param1 - ang
; param2 - img offset
launch_astbig:
    ldx #0
    stx sp_entity_count
    ldx #<(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
    stx sp_offset
    ldx #>(.sizeof(Entity)*ASTBIG_ENTITY_NUM_START)
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
    ; Found a free astbig
    ; lda param1
    ; ldy #Entity::_ang
    ; sta (active_entity), y
    lda #1
    ldy #Entity::_visible
    sta (active_entity), y
    ldx #0
@initial_accel:
    ; Accelerate the astbig a few times to get it started moving
    jsr accel_entity
    bra @done
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
    cmp #ASTBIG_COUNT
    bne @next_entity
@done:
    rts


check_storm:
    clc
    lda storm_count
    adc #1
    sta storm_count
    lda storm_count+1
    adc #0
    sta storm_count+1
    lda storm_count+1
    cmp #>STORM_COUNT ; compare the hi bytes
    bne @no_storm
    lda storm_count
    cmp #<STORM_COUNT
    bne @no_storm
    ; lda #0 ; Reset storm to 0
    ; sta storm_count
    ; sta storm_count+1
    jsr launch_astbigs
@no_storm:
    rts
.endif
