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

.define GUY_FIRST "JOHN"
.define GUY_LAST "SMITH"

; 34 max chars per convo row

convo_1:
    .byte 2, 0 ; What 2 portraits to load
    .byte 0, 0 ; Potrait to show and frame
    .asciiz "HELLO MR. ", GUY_LAST, ". I'M GLAD YOU HAVE CHOSEN TO JOIN US." ; Text for that portrait
    .byte 1, 0 ; Next potrait to show
    .asciiz "DIDN'T SEEM LIKE MUCH OF A CHOICE." ; Text for that portrait
    .byte 0, 0
    .asciiz "WE ALL MAKE CHOICES MR. ", GUY_LAST, ". YOU CHOSE TO STEAL FROM THE|CORPORATION. BUT, I'D GUESS YOU DIDN'T CHOOSE TO GET CAUGHT."
    .byte 1, 1
    .asciiz "DECISION MAKING WAS NEVER MY STRONG SUIT."
    .byte 0, 0
    .asciiz "WELL, LET'S HOPE THAT TURNS|AROUND. SEE, THE JUDGE HAS CHOOSEN TO ASSIGN YOU TO WORK FOR ME UNTIL YOUR DEBT IS PAID."
    .byte 1, 2
    .asciiz "DID HE CHOSE THAT BEFORE OR AFTER YOU PAID FOR HIS LAST VACATION?"
    .byte 254
    .byte 0, 2
    .asciiz "NO NEED FOR ACCUSATIONS MR. ", GUY_LAST, ". WOULD YOU RATHER THE ALTERNATIVE AND SERVE 20 YEARS OF HARD LABOR?"
    .byte 1, 1
    .asciiz "WELL, I HEAR THE PENAL COLONIES ARE NICE THIS TIME OF YEAR."
    .byte 0, 0
    .asciiz "HMM, THE LAST PILOT WHO TURNED US DOWN DIDN'T LAST A WEEK AT THE COLONIES. I HEAR IT CAN BE QUITE BRUTAL."
    .byte 1, 1
    .asciiz "PERHAPS MY SUNNY DISPOSITION WOULD MAKE ME POPULAR THERE?"
    .byte 0, 2
    .asciiz "LET'S CUT TO THE CHASE MR. ", GUY_LAST, ". YOU BELONG TO ME NOW. DO WELL AND YOU MAY PAY OFF YOUR DEBT."
    .byte 1, 1
    .asciiz "AND IF I DON'T DO WELL IS THERE SOME KIND OF PAYMENT PLAN?"
    .byte 254
    .byte 0, 2
    .asciiz "I SUGGEST YOU START TAKING THIS SERIOUSLY MR. ", GUY_LAST, ". MY PLANS FOR YOU ARE VERY LUCRATIVE...BUT QUITE DANGEROUS."
    .byte 1, 1
    .asciiz "SO, A 50-50 SPLIT OF THE PROFITS THEN?"
    .byte 0, 0
    .asciiz "OH MR. ", GUY_LAST, ", YOUR FIRST CONCERN SHOULD BE STAYING ALIVE. DEEP SCAVENGING IS A RISKY BUSINESS."
    .byte 0, 2
    .asciiz "EVEN FOR A LEGENDARY PILOT SUCH AS YOURSELF, YOUR SKILLS WILL BE PUSHED TO THEIR LIMITS. PERHAPS YOU ARE NOT CUT OUT FOR THIS?"
    .byte 1, 2
    .asciiz "SAVE YOUR MOTIVATIONAL SPEECH. I'M IN. JUST TELL ME HOW THIS WORKS EXACTLY?"
    .byte 0, 0
    .asciiz "GOOD...GOOD...(LAUGHS)"
    .byte 254
    .byte 0, 2
    .asciiz "USING OUR WARP GATE TECHNOLOGY, WE WILL TRANSPORT YOU AND YOUR SHIP INTO THE MIDDLE OF DEEP SPACE ASTEROID FIELDS."
    .byte 1, 0
    .asciiz "I HATE THIS PLAN ALREADY."
    .byte 0, 2
    .asciiz "THESE FIELDS ALSO CONTAIN SOME OF THE GALAXY'S MOST VALUABLE CRYSTALS AND MINERALS. YOU WILL HARVEST THEM."
    .byte 0, 2
    .asciiz "USE YOUR SHIP TO GRAB AS MANY AS YOU CAN WHILE AVOIDING THE ASTEROIDS AND OTHER, UM 'HAZARDS'."
    .byte 1, 2
    .asciiz "HAZARDS? WHAT EXACTLY AM I LOOKING AT?"
    .byte 0, 2
    .asciiz "WELL, SOME OF THE CRYSTALS ARE EXPLOSIVE. I'D SKIP THOSE. AND YOU MAY NOT BE ALONE OUT THERE."
    .byte 254
    .byte 1, 0
    .asciiz "LET'S ASSUME I CAN GRAB ALL THE LOOT AND STAY ALIVE. WHAT THEN?"
    .byte 0, 2
    .asciiz "ONCE THE WARP GATE SENSES THAT THE AREA HAS BEEN ADEQUATELY HARVESTED, IT WILL REOPEN FOR YOU TO FLY BACK IN."
    .byte 0, 2
    .asciiz "BE CAREFUL AROUND THE WARP GATE. CRASHING INTO IT WILL DESTROY YOUR SHIP. SPEAKING OF DEATH, I DO HAVE SOME GOOD NEWS."
    .byte 0, 2
    .asciiz "USING SHORT-RANGED INSTANT WARP TECHNOLOGY, THE GATE WILL BE ABLE TO SAVE YOU FROM DEATH A FEW TIMES. DON'T ABUSE IT."
    .byte 1, 0
    .asciiz "VERY REASSURING."
    .byte 0, 2
    .asciiz "WELL THAT'S IT. IF THERE ARE NO QUESTIONS, I SAY WE GET STARTED...3...2...1..."
    .byte 255

convo_table: .word convo_1

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
    lda #0
    jsr JOYGET
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
    lda mb_y
    inc
    sta mb_y
    jsr point_to_convo_mapbase
    bra @next_char
@found_null:
    rts

stc_y: .byte 0

show_test_convo:
    jsr clear_tiles
    lda #<convo_1
    sta param1 ; Convo to show
    lda #>convo_1
    sta param1+1 ; Convo to show
    jsr load_convo_images
    jsr inc_param1
@new_screen:
    lda #PORTRAIT_SPRITE_NUM_START
    sta ccs_sprite_num
    jsr inc_param1 ; Jump to 1st por/convo
    lda #8
    sta ccs_y
    lda #0
    sta ccs_y+1
    lda #1
    sta stc_y
@next_por:
    lda #0
    jsr JOYGET
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
    ; Next byte is either a new portrait, 254: Next page, or 255: End of convo
    cmp #254
    bcc @next_por
    ; End of convo
@done:
    lda #1
    sta wc
@loop:
    jsr watch_for_joystick_press
    jsr cleanup_convo
    lda (param1)
    cmp #254
    beq @new_screen
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
