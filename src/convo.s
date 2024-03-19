.ifndef CONVO_S
CONVO_S = 1

mainguy_potrait_id: .byte 0
maingirl_potrait_id: .byte 1
corpguy_potrait_id: .byte 2
corpgirl_potrait_id: .byte 3

; Potrait filenames
mainguy_filename: .asciiz "mgy.bin"
maingirl_filename: .asciiz "mgl.bin"
corpguy_filename: .asciiz "cgy.bin"
corpgirl_filename: .asciiz "cgl.bin"
evilguy_filename: .asciiz "egy.bin"
evilgirl_filename: .asciiz "egl.bin"
sideguy_filename: .asciiz "sgy.bin"
sidegrl_filename: .asciiz "sgl.bin"
daughter_filename: .asciiz "dau.bin"


potrait_filename_table: .word mainguy_filename, maingirl_filename, corpguy_filename, corpgirl_filename, evilguy_filename, evilgirl_filename, sideguy_filename, sidegrl_filename, daughter_filename


convo_1: .byte 1, 2 ; What 2 portraits to load
convo_1_p1: .byte 0 ; Potrait to show
convo_1_t1: .asciiz "HELLO" ; Text for that portrait
convo_1_p2: .byte 1 ; Next potrait to show
convo_1_t2: .asciiz "HOW ARE YOU?" ; Text for that portrait
convo_1_end: .byte 255

show_test_convo:
    jsr clear_tiles
    jsr load_porpal
    lda #<convo_1
    sta param1 ; Convo to show
    lda #>convo_1
    sta param1+1 ; Convo to show
    jsr load_convo_images
    jsr create_convo_sprites
@block:
    bra @block
    rts

lcs_filename: .word 0

; param1 - Address of the convo
load_convo_images:
    ; 1st portrait
    lda (param1)
    rol
    tax
    lda potrait_filename_table, x
    sta lcs_filename
    lda potrait_filename_table+1, x
    sta lcs_filename+1
    lda #7
    ldx lcs_filename
    ldy lcs_filename+1
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<PORTRAIT1_LOAD_ADDR
    ldy #>PORTRAIT1_LOAD_ADDR
    jsr LOAD
    ; 2nd portrait
    clc
    ldy #1
    lda (param1), y
    rol
    tax
    lda potrait_filename_table, x
    sta lcs_filename
    lda potrait_filename_table+1, x
    sta lcs_filename+1
    lda #7
    ldx lcs_filename
    ldy lcs_filename+1
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<PORTRAIT2_LOAD_ADDR
    ldy #>PORTRAIT2_LOAD_ADDR
    jsr LOAD
    rts

create_convo_sprites:
    lda #<PORTRAIT1_LOAD_ADDR
    sta us_img_addr
    lda #>PORTRAIT1_LOAD_ADDR
    sta us_img_addr+1
    lda #<(PORTRAIT1_LOAD_ADDR>>16)
    sta us_img_addr+2
    lda #120
    sta pts_sprite_num
    jsr point_to_sprite
    lda #100
    sta cps_y
    jsr create_portrait_sprite
    ; Portrait 2
    lda #<PORTRAIT2_LOAD_ADDR
    sta us_img_addr
    lda #>PORTRAIT2_LOAD_ADDR
    sta us_img_addr+1
    lda #<(PORTRAIT2_LOAD_ADDR>>16)
    sta us_img_addr+2
    lda #121
    sta pts_sprite_num
    jsr point_to_sprite
    lda #200
    sta cps_y
    jsr create_portrait_sprite
    rts

cps_y: .byte 0

create_portrait_sprite:
    ldx #0
@start_shift: ; Shift the image addr bits as sprites use bits 12:5 and 16:13 (we default 16 to 0)
    clc
    lda us_img_addr+2
    ror
    sta us_img_addr+2
    lda us_img_addr+1
    ror
    sta us_img_addr+1
    lda us_img_addr
    ror
    sta us_img_addr
    inx
    cpx #5
    bne @start_shift
    clc
    lda us_img_addr
    sta VERA_DATA0
    lda us_img_addr+1
    ora #%10000000
    sta VERA_DATA0
    lda #250
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda cps_y
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%11110000 ; 64x64
    sta VERA_DATA0
    rts

.endif
