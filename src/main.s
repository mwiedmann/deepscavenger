.org $080D
.segment "ONCE"

.include "x16.inc"
.include "config.inc"

    jmp start

timebyte: .byte 0
shipx: .word 600
shipy: .word 440
ship_velx: .byte 0
ship_vely: .byte 0

default_irq: .word 0
waitflag: .byte 0

.include "config.s"
.include "tiles.s"
.include "irq.s"
.include "sprites.s"
.include "pal.s"

start:
    jsr irq_config
    jsr config
    jsr load_pal
    jsr create_tiles
    jsr load_ship
    jsr clear_tiles
    jsr create_sprite
@move:
    jsr move_sprite
@waiting:
    lda waitflag
    cmp #0
    beq @waiting
    lda #0
    sta waitflag
    bra @move

point_to_mapbase:
    pha
    lda #<MAPBASE_L1_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_L1_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    pla
    rts

move_sprite:
    lda #0
    jsr JOYGET
    pha
    bit #%1000
    bne @check_y_down
    lda shipy
    sec
    sbc #SPRITE_SPEED
    sta shipy
    lda shipy+1
    sbc #0
    sta shipy+1
    jmp @check_x_left
@check_y_down:
    bit #%100
    bne @check_x_left
    lda shipy
    clc
    adc #SPRITE_SPEED
    sta shipy
    lda shipy+1
    adc #0
    sta shipy+1
@check_x_left:
    pla
    bit #%10
    bne @check_x_right
    lda shipx
    sec
    sbc #SPRITE_SPEED
    sta shipx
    lda shipx+1
    sbc #0
    sta shipx+1
    jmp @update_sprite
@check_x_right:
    bit #%1
    bne @update_sprite
    lda shipx
    clc
    adc #SPRITE_SPEED
    sta shipx
    lda shipx+1
    adc #0
    sta shipx+1
@update_sprite:
    jsr point_to_sprite
    lda VERA_DATA0 ; skip byte
    lda VERA_DATA0 ; skip byte
    lda shipx
    sta VERA_DATA0
    lda shipx+1
    sta VERA_DATA0
    lda shipy
    sta VERA_DATA0
    lda shipy+1
    sta VERA_DATA0
@done:
    rts

