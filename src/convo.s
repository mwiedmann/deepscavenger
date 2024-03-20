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


convo_1:
    .byte 0, 1 ; What 2 portraits to load
    .byte 1 ; Potrait to show
    .asciiz "HELLO.|2ND LINE." ; Text for that portrait
    .byte 0 ; Next potrait to show
    .asciiz "HOW ARE YOU?" ; Text for that portrait
    .byte 1
    .asciiz "DOING FINE. AND YOU?"
    .byte 0
    .asciiz "BETTER NOW THAT YOU ARE HERE."
    .byte 1
    .asciiz "NICE WEATHER WE ARE HAVING."
    .byte 0
    .asciiz "YES, I LOVE THE RAIN."
    .byte 255

convo_2: 
    .byte 2, 3 ; What 2 portraits to load
    .byte 0 ; Potrait to show
    .asciiz "SUP DOG!" ; Text for that portrait
    .byte 1 ; Next potrait to show
    .asciiz "WHO DIS?" ; Text for that portrait
    .byte 255

convo_table: .word convo_1, convo_2

convo_index: .byte 0

inc_param1:
    clc
    lda param1
    adc #1
    sta param1
    lda param1+1
    adc #0
    sta param1+1
    rts

mb_offset: .word 0
mb_x: .byte 0
mb_y: .byte 0 ; 64x32

point_to_convo_mapbase:
    lda #0
    sta mb_offset
    sta mb_offset+1
    ldy #0
@next_y:
    cpy mb_y
    beq @y_done
    lda mb_offset
    clc
    adc #128 ; Skip one full row of tiles
    sta mb_offset
    lda mb_offset+1
    adc #0
    sta mb_offset+1
    iny
    bra @next_y
@y_done:
    ; In correct y row, now add x
    clc
    lda mb_x
    rol ; Mult by 2
    sta mb_x
    lda mb_offset
    clc
    adc mb_x
    sta mb_offset
    lda mb_offset+1
    adc #0
    sta mb_offset+1 ; Offset should be correct now
    clc
    lda #<MAPBASE_L1_ADDR
    adc mb_offset
    sta VERA_ADDR_LO
    lda #>MAPBASE_L1_ADDR
    adc mb_offset+1
    sta VERA_ADDR_MID
    lda #VERA_ADDR_HI_INC_BITS
    sta VERA_ADDR_HI_SET
    rts

; param1 has text
show_convo_msg:
    lda #CONVO_TEXT_X
    sta mb_x
    jsr point_to_convo_mapbase
    lda #CONVO_TEXT_WAIT_AMOUNT
    sta wc
@next_char:
    jsr wait_count
    lda #0
    jsr JOYGET
    cmp #255
    bne @found_null
    jsr inc_param1
    lda (param1)
    cmp #0 ; Looking for null
    beq @found_null
    cmp #$DD ; Pipe char for CR
    beq @CR
    ; Write the char
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    ; We can continue writing but need to go to next line at some points
    ; Just reset the mapbase pointer each character. We don't care about speed.
    bra @next_char
@CR:
    lda #CONVO_TEXT_X
    sta mb_x
    lda mb_y
    inc
    sta mb_y
    jsr point_to_convo_mapbase
    bra @next_char
@found_null:
    rts

stc_y: .byte 0

show_test_convo:
    lda #PORTRAIT_SPRITE_NUM_START
    sta ccs_sprite_num
    jsr clear_tiles
    lda #<convo_1
    sta param1 ; Convo to show
    lda #>convo_1
    sta param1+1 ; Convo to show
    jsr load_convo_images
    jsr inc_param1
    jsr inc_param1 ; Jump to 1st por/convo
    lda #8
    sta ccs_y
    lda #0
    sta ccs_y+1
    lda #1
    sta stc_y
@next_por:
    lda #CONVO_WAIT_BETWEEN_PORTRAITS
    sta wc
    jsr wait_count
    lda #0
    jsr JOYGET
    cmp #255
    bne @done
    lda (param1)
    sta ccs_pornum
    jsr create_convo_sprite
    lda ccs_y
    clc
    adc #80
    sta ccs_y
    lda ccs_y+1
    adc #0
    sta ccs_y+1
    lda ccs_sprite_num ; Next sprite num
    inc
    sta ccs_sprite_num
    ; Show text now
    lda stc_y
    sta mb_y
    jsr show_convo_msg
    lda stc_y
    clc
    adc #5
    sta stc_y
    jsr inc_param1
    lda (param1)
    ; Next byte is either a new portrait, or 255: End of convo
    cmp #255
    bne @next_por
    ; End of convo
@done:
    lda #1
    sta wc
@loop:
    jsr wait_count
    lda #0
    jsr JOYGET
    cmp #255
    beq @loop
    jsr cleanup_convo
    rts

cleanup_convo:
    ldx #0
    ldy #PORTRAIT_SPRITE_NUM_START
@next_sprite:
    phx
    phy
    sty pts_sprite_num
    jsr point_to_sprite
    lda #0
    ; Wipe out the sprite settings
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    sta VERA_DATA0
    ply
    plx
    inx
    iny
    cpx #6
    bne @next_sprite
    rts

lcs_filename: .word 0

; param1 - Address of the convo
load_convo_images:
    ; 1st portrait
    clc
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

ccs_y: .word 0
ccs_pornum: .byte 0
ccs_sprite_num: .byte 0

create_convo_sprite:
    lda ccs_pornum
    cmp #0
    bne @load2
    lda #<PORTRAIT1_LOAD_ADDR
    sta us_img_addr
    lda #>PORTRAIT1_LOAD_ADDR
    sta us_img_addr+1
    lda #<(PORTRAIT1_LOAD_ADDR>>16)
    sta us_img_addr+2
    bra @addr_done
@load2:
    lda #<PORTRAIT2_LOAD_ADDR
    sta us_img_addr
    lda #>PORTRAIT2_LOAD_ADDR
    sta us_img_addr+1
    lda #<(PORTRAIT2_LOAD_ADDR>>16)
    sta us_img_addr+2
@addr_done:
    lda ccs_sprite_num
    sta pts_sprite_num
    jsr point_to_sprite
    lda ccs_y
    sta cps_y
    lda ccs_y+1
    sta cps_y+1
    jsr create_portrait_sprite
    rts

cps_y: .word 0

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
    lda #100
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda cps_y
    sta VERA_DATA0
    lda cps_y+1
    sta VERA_DATA0
    lda #%00001100 ; In front of layer 1
    sta VERA_DATA0
    lda #%11110000 ; 64x64
    sta VERA_DATA0
    rts

.endif
