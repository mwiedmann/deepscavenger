.ifndef CONVO_S
CONVO_S = 1

MAX_CONVO = 16

; Convos happen before the level (so we can have the starting convo)
convo_level_table: .word convo_intro, 255, convo_love_interest_1, 255, convo_pirate_1, 255, convo_corp_1, 255, convo_colony_1, 255, convo_pirate_2, 255, convo_love_hurt, 255, convo_friend, convo_last, 255

convo_index: .byte 0

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
scm_count: .byte 0

show_convo_msg:
    lda #CONVO_TEXT_X
    sta mb_x
    jsr point_to_convo_mapbase
    lda #0
    sta scm_count
    lda #CONVO_TEXT_WAIT_AMOUNT
    sta wc
@next_char:
    lda level
    cmp #0
    bne @bypass_skipall ; skip all only on long intro cut-scene
    jsr joy1
    cmp #%11101111
    beq @done
@bypass_skipall:
    jsr joy1
    cmp #255
    bne @skip_wait
    jsr wait_count
@skip_wait:
    jsr inc_param1
    lda (param1)
    cmp #32
    bne @skip_space_check
    lda scm_count
    cmp #28 ; If we are close to the EOL and its a space, just go to a new line
    bcs @CR
    cmp #0
    beq @skip_space ; Skip spaces at beginning of line
    lda #32 ; put the space back, we will show it
@skip_space_check:
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
@skip_space:
    inc scm_count
    lda scm_count
    cmp #34 ; Hard limit
    beq @CR
    bra @next_char
@CR:
    lda #0
    sta scm_count
    lda #CONVO_TEXT_X
    sta mb_x
    inc mb_y
    jsr point_to_convo_mapbase
    bra @next_char
@done:
@found_null:
    rts

stc_y: .byte 0

show_next_convo:
    jsr clear_tiles
    ; check for winner convo
    lda winner
    cmp #1
    bne @reg_convo
    jsr load_winner_convo
    jsr sound_cut_play
    bra @new_convo
@reg_convo:
    lda level
    cmp #MAX_CONVO
    bcc @level_ok
    lda #MAX_CONVO
@level_ok:
    clc
    rol ; mult by 2 for .word table index
    tax
    lda convo_level_table, x
    cmp #255 ; No convo for this level
    bne @convo_valid
    lda convo_level_table+1, x
    cmp #0 ; No convo for this level
    bne @convo_valid
    rts
@convo_valid:
    jsr load_valid_convo
    jsr sound_cut_play
@new_convo:
    jsr load_convo_images
    jsr inc_param1
@new_screen:
    jsr new_screen
@next_por:
    lda level
    cmp #0
    bne @bypass_skipall ; skip all only on long intro cut-scene
    jsr joy1
    cmp #%11101111
    beq @quick_exit
@bypass_skipall:
    jsr joy1
    cmp #255
    bne @skip_wait
    lda #CONVO_WAIT_BETWEEN_PORTRAITS
    sta wc
    jsr wait_count
@skip_wait:
    lda (param1)
    sta ccs_pornum
    jsr inc_param1
    lda (param1)
    sta css_framenum
    jsr create_convo_sprite
    lda ccs_y
    clc
    adc #80
    sta ccs_y
    lda ccs_y+1
    adc #0
    sta ccs_y+1
    inc ccs_sprite_num ; Next sprite num
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
    ; Next byte is either a new portrait, 254: Next page, 253: New convo, or 255: End of convo
    cmp #253
    bcc @next_por
    ; End of convo
@done:
    lda #1
    sta wc
@loop:
    jsr watch_for_joystick_press
    jsr cleanup_convo
    lda (param1)
    cmp #253
    bne @check_new_screen
    jsr inc_param1
    jmp @new_convo
@check_new_screen:
    cmp #254
    beq @new_screen
    jsr sound_cut_stop
    rts
@quick_exit:
    jsr cleanup_convo
    jsr sound_cut_stop
    rts

load_valid_convo:
    lda convo_level_table, x
    sta param1 ; Convo to show
    lda convo_level_table+1, x
    sta param1+1 ; Convo to show
    rts

load_winner_convo:
    lda #<convo_winner
    sta param1 ; Convo to show
    lda #>convo_winner
    sta param1+1 ; Convo to show
    rts

new_screen:
    lda #PORTRAIT_SPRITE_NUM_START
    sta ccs_sprite_num
    jsr inc_param1 ; Jump to 1st por/convo
    lda #8
    sta ccs_y
    lda #0
    sta ccs_y+1
    lda #1
    sta stc_y
    rts

cleanup_convo:
    jsr clear_tiles
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
css_framenum: .byte 0
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
    lda css_framenum
    cmp #0
    beq @frame_done
    clc
    lda us_img_addr
    adc #<PORTRAIT_SPRITE_FRAME_SIZE
    sta us_img_addr
    lda us_img_addr+1
    adc #>PORTRAIT_SPRITE_FRAME_SIZE
    sta us_img_addr+1
    lda us_img_addr+2
    adc #0
    sta us_img_addr+2
    lda css_framenum
    sec
    sbc #1
    sta css_framenum
    bra @addr_done
@frame_done:
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
    lda #16
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
