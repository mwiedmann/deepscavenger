.ifndef ASTBIG_S
ASTBIG_S = 1

; across 0<<5, 64<<5, 128<<5, 192<<5, 256<<5, 320<<5, 384<<5, 448<<5, 512<<5, 576<<5
; down 0<<5, 69<<5, 138<<5, 207<<5, 276<<5, 345<<5, 414<<5

; astbig_start_x:         .word 0<<5,   64<<5,  128<<5, 192<<5, 256<<5, 320<<5, 384<<5, 448<<5, 512<<5, 576<<5 ; top row
; astbig_start_x_sides:   .word 0<<5,   576<<5, 0<<5,   576<<5, 0<<5,   576<<5, 0<<5,   576<<5, 0<<5,   576<<5 ; sides
; astbig_start_x_bot:     .word 0<<5,   64<<5,  128<<5, 192<<5, 256<<5, 320<<5, 384<<5, 448<<5, 512<<5, 576<<5 ; bottom row

; astbig_start_y:         .word 0<<5,   0<<5,   0<<5,   0<<5,   0<<5,   0<<5,   0<<5,   0<<5,   0<<5,   0<<5   ; top
; astbig_start_y_sides:   .word 69<<5,  69<<5,  138<<5, 138<<5, 207<<5, 207<<5, 276<<5, 276<<5, 345<<5, 345<<5 ; sides
; astbig_start_y_bot:     .word 414<<5, 414<<5, 414<<5, 414<<5, 414<<5, 414<<5, 414<<5, 414<<5, 414<<5, 414<<5 ; bottom row

; astbig_start_ang:       .word 8,     10,      7,      9,      6,      7,      9,      8,      7,      10
; astbig_start_ang_sides: .word 5,     11,      6,      10,     4,      12,     3,      13,     2,      14
; astbig_start_ang_bot:   .word 1,     0,       15,     14,     2,      1,      15,     0,      15,     14

; astbig_start_x:         .word 0<<5, 192<<5, 384<<5, 576<<5, 0<<5,   0<<5,   576<<5, 576<<5, 0<<5,   192<<5, 384<<5, 576<<5, 128<<5, 0<<5,   576<<5, 320<<5
; astbig_start_y:         .word 0<<5, 0<<5,   0<<5,   0<<5,   138<<5, 276<<5, 138<<5, 276<<5, 414<<5, 414<<5, 414<<5, 414<<5,  0<<5,  345<<5, 69<<5,  414<<5
; astbig_start_ang:       .word 6,    9,      9,      10,     5,      6,      12,     13,     1,      2,      13,     14,      11,    2,      10,     15

astbig_start_x:         .word 0<<5, 0<<5,   576<<5, 192<<5, 384<<5, 0<<5,   576<<5, 320<<5, 192<<5, 0<<5,   576<<5, 384<<5, 128<<5, 0<<5,   576<<5, 576<<5
astbig_start_y:         .word 0<<5, 276<<5, 138<<5, 414<<5, 0<<5,   414<<5, 414<<5, 414<<5, 0<<5,   138<<5, 276<<5, 414<<5, 0<<5,   345<<5, 0<<5,   69<<5 
astbig_start_ang:       .word 6,    6,      12,     2,      9,      1,      13,     14,     9,      5,      13,     13,     11,     2,      10,     10  


ang_adj: .byte 1

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
    clc
    adc ang_adj
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
    lda #20
    ldy #Entity::_coll_size
    sta (active_entity), y
    lda #6
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
    inc sp_num
    inc sp_entity_count
    lda sp_entity_count
    cmp #ASTBIG_COUNT
    beq @done
    jmp next_astbig
@done:
    rts

launch_amount: .byte START_ASTBIG_COUNT

launch_astbigs:
    ldx #0
@next_astbig:
    stx param1 ; Currently doesn't do anything but maybe later
    phx
    jsr launch_astbig
    plx
    inx
    cpx launch_amount
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
    inc sp_entity_count
    lda sp_entity_count
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
