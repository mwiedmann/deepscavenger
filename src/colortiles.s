.org $080D
.segment "ONCE"

; Kernal functions
RDTIM = $FFDE

TILEBASE_ADDR = $1000
MAPBASE_ADDR = 0

VERA_ADDR_LO = $9F20
VERA_ADDR_MID = $9F21
VERA_ADDR_HI_SET = $9F22
VERA_DATA0 = $9F23

VERA_DC_VIDEO = $9F29

VERA_L1_CONFIG = $9F34
VERA_L1_MAPBASE = $9F35
VERA_L1_TILEBASE = $9F36

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
    jsr draw_tiles
    rts

config:
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

draw_tiles:
    lda #0
@start:
    jsr point_to_mapbase
    ldy #0
@outer:
    ldx #0
@loop:
    sta VERA_DATA0 ; Tile index
    pha
    lda #0 ; Tile settings, always 0
    sta VERA_DATA0
    pla
    cpx #VISIBLE_TILES_PER_ROW ; Don't inc the tile index if off screen
    bpl @skip_tile_index
    inc ; Increase tile index
    jsr wait
@skip_tile_index:
    cmp #TILE_COUNT ; See if we hit the max tile
    bne @skip_tile_reset
    lda #0 ; Set the tile index back to 0
@skip_tile_reset:
    inx
    cpx #TILES_PER_ROW ; Draw entire row
    bne @loop
    iny ; Next row
    cpy #VISIBLE_TILES_PER_COL
    beq @done
    bra @outer
@done:
    bra @start ; Keep drawing back at the beginning
    rts