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


convo_1: .byte 0, 1 ; What 2 portraits to load
convo_1_p1: .byte 1 ; Potrait to show
convo_1_t1: .asciiz "HELLO" ; Text for that portrait
convo_1_p2: .byte 0 ; Next potrait to show
convo_1_t2: .asciiz "HOW ARE YOU?" ; Text for that portrait
convo_1_end: .byte 255

convo_2: .byte 2, 3 ; What 2 portraits to load
convo_2_p1: .byte 0 ; Potrait to show
convo_2_t1: .asciiz "SUP DOG!" ; Text for that portrait
convo_2_p2: .byte 1 ; Next potrait to show
convo_2_t2: .asciiz "WHO DIS?" ; Text for that portrait
convo_2_end: .byte 255

convo_table: .word convo_1

convo_index: .byte 0

inc_param1:
    lda param1
    clc
    inc
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
    lda #10
    sta mb_x
    jsr point_to_convo_mapbase
@next_char:
    jsr inc_param1
    lda (param1)
    cmp #0 ; Looking for null
    beq @found_null
    ; Write the char
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    ; We can continue writing but need to go to next line at some points
    ; Just reset the mapbase pointer each character. We don't care about speed.
    lda mb_x
    inx
    sta mb_x
    bra @next_char
@found_null:
    rts

show_test_convo:
    jsr clear_tiles
    ; WEIRD - We shouldn't need to load the PAL again, but if we don't the 2nd portrait is garbage!
    jsr load_mainpal
    lda #<convo_1
    sta param1 ; Convo to show
    lda #>convo_1
    sta param1+1 ; Convo to show
    jsr load_convo_images
    jsr inc_param1
    jsr inc_param1 ; Jump to 1st por/convo
    lda #0
    sta ccs_y
    sta ccs_y+1
    lda #5
    sta mb_y
@next_por:
    lda (param1)
    sta ccs_pornum
    lda ccs_y
    clc
    adc #70
    sta ccs_y
    lda ccs_y+1
    adc #0
    sta ccs_y+1
    jsr create_convo_sprite
    ; Show text now
    jsr show_convo_msg
    jsr inc_param1
    lda (param1)
    ; Next byte is either a new portrait, or 255: End of convo
    cmp #255
    bne @next_por
    ; End of convo
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

ccs_y: .word 0
ccs_pornum: .byte 0

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
    lda #PORTRAIT1_SPRITE_NUM
    bra @addr_done
@load2:
    lda #<PORTRAIT2_LOAD_ADDR
    sta us_img_addr
    lda #>PORTRAIT2_LOAD_ADDR
    sta us_img_addr+1
    lda #<(PORTRAIT2_LOAD_ADDR>>16)
    sta us_img_addr+2
    lda #PORTRAIT2_SPRITE_NUM
@addr_done:
    sta pts_sprite_num
    jsr point_to_sprite
    lda ccs_y
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
    lda #100
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
