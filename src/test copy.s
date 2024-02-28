.org $080D
.segment "ONCE"

; Kernal functions
RDTIM = $FFDE
JOYGET = $FF56

TILEBASE_ADDR = $1000
MAPBASE_ADDR = 0

SPRITE_GFX_ADDR_LO = (TILEBASE_ADDR+256) >> 5; 2nd tile
SPRITE_GFX_ADDR_HI = %10000000 | ((TILEBASE_ADDR+256) >> 13)
SPRITE_SPEED = 2

VERA_ADDR_LO = $9F20
VERA_ADDR_MID = $9F21
VERA_ADDR_HI_SET = $9F22
VERA_DATA0 = $9F23

VERA_DC_VIDEO = $9F29

VERA_L1_CONFIG = $9F34
VERA_L1_MAPBASE = $9F35
VERA_L1_TILEBASE = $9F36

SPRITE_ADDR = $FC08 ; Also 1 for 2nd bank of VRAM

VERA_DC_VIDEO_BITS = %11100001; Sprites on, Layer 1 on, other defaults
VERA_L1_CONFIG_BITS = %00010011; 64x32 tiles, 8bbp
VERA_L1_MAPBASE_BITS = 0 ; Mapbase at VRAM Addr 0, need 4kB
VERA_L1_TILEBASE_BITS = %00001011 ; Start at 4Kb VRAM, 16x16 pixel tiles


VERA_ADDR_HI_INC_BITS = %00010000 ; Addr increment 1

TILE_COUNT = 255
TILES_PER_ROW = 64
TILES_PER_COL = 32
VISIBLE_TILES_PER_ROW = 40
VISIBLE_TILES_PER_COL = 30


    jmp start

timebyte: .byte 0
spritex: .word 600
spritey: .word 440

wait:
    pha
    phx
    phy
@tryagain:
    jsr RDTIM
    cmp timebyte
    beq @tryagain
    sta timebyte
    ply
    plx
    pla
    rts



start:
    jsr config
    jsr create_tiles
    jsr clear_tiles
    jsr create_sprite
@move:
    jsr move_sprite
    jsr wait
    bra @move

config:
    lda #VERA_DC_VIDEO_BITS
    sta VERA_DC_VIDEO
    lda #VERA_L1_CONFIG_BITS
    sta VERA_L1_CONFIG
    lda #VERA_L1_MAPBASE_BITS
    sta VERA_L1_MAPBASE
    lda #VERA_L1_TILEBASE_BITS
    sta VERA_L1_TILEBASE
    rts

; Create 2 tiles
; 1 black, 1 another color
create_tiles:
    lda #<TILEBASE_ADDR
    sta VERA_ADDR_LO
    lda #>TILEBASE_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET

    ldx #0
    lda #0
@loop:
    sta VERA_DATA0
    inx
    cpx #0
    bne @loop
    inc ; Inc the tile color
    cmp #TILE_COUNT ; stop after this many tiles
    bne @loop
    rts

point_to_mapbase:
    pha
    lda #<MAPBASE_ADDR
    sta VERA_ADDR_LO
    lda #>MAPBASE_ADDR
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    pla
    rts

clear_tiles:
    jsr point_to_mapbase
    lda #0
    ldy #0
@outer:
    ldx #0
@loop:
    sta VERA_DATA0
    sta VERA_DATA0
    inx
    cpx #TILES_PER_ROW
    bmi @loop
@next_row:
    iny
    cpy #TILES_PER_COL
    bmi @outer
    rts

point_to_sprite:
    lda #<SPRITE_ADDR
    sta VERA_ADDR_LO
    lda #>SPRITE_ADDR
    sta VERA_ADDR_MID
    lda #(VERA_ADDR_HI_INC_BITS+1) ; Sprites are in 2nd bank of VRAM
    sta VERA_ADDR_HI_SET
    rts

create_sprite:
    jsr point_to_sprite
    lda #SPRITE_GFX_ADDR_LO
    sta VERA_DATA0
    lda #SPRITE_GFX_ADDR_HI
    sta VERA_DATA0
    lda spritex ; X
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda spritey ; Y
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%10100000 ; 32x32 pixels
    sta VERA_DATA0
    rts

move_sprite:
    lda #0
    jsr JOYGET
    pha
    bit #%1000
    bne @check_y_down
    lda spritey
    sec
    sbc #SPRITE_SPEED
    sta spritey
    jmp @check_x_left
@check_y_down:
    bit #%100
    bne @check_x_left
    lda spritey
    clc
    adc #SPRITE_SPEED
    sta spritey
@check_x_left:
    pla
    bit #%10
    bne @check_x_right
    lda spritex
    sec
    sbc #SPRITE_SPEED
    sta spritex
    jmp @update_sprite
@check_x_right:
    bit #%1
    bne @update_sprite
    lda spritex
    clc
    adc #SPRITE_SPEED
    sta spritex 
@update_sprite:
    jsr point_to_sprite
    lda VERA_DATA0 ; skip byte
    lda VERA_DATA0 ; skip byte
    lda spritex
    sta VERA_DATA0
    lda spritex+1
    sta VERA_DATA0
    lda spritey
    sta VERA_DATA0
    lda spritey+1
    sta VERA_DATA0
@done:
    rts

