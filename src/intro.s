.ifndef INTRO_S
INTRO_S = 1

intro_1: 
.byte 13, 4
.asciiz "DEEP SCAVENGER"
.byte 12, 5
.asciiz "BY MARK WIEDMANN"
.byte 14, 8
.asciiz "--CONTROLS--"
.byte 10, 9
.asciiz "LEFT-RIGHT TO ROTATE"
.byte 14, 10
.asciiz "UP TO THRUST"
.byte 6, 11
.asciiz "DOWN OR ANY BUTTON TO SHOOT"
.byte 14, 14
.asciiz "--GAMEPLAY--"
.byte 6, 15
.asciiz "SHOOT ASTEROIDS AND FLY OVER"
.byte 6, 16
.asciiz "THE CRYSTALS TO HARVEST THEM"
.byte 8, 18
.asciiz "EXTRA SHIP EVERY 2 FIELDS"
.byte 13, 21
.asciiz "--CUT SCENES--"
.byte 8, 22
.asciiz "PRESS BUTTON TO SPEED UP"
.byte 7, 23
.asciiz "ENTER-START TO SKIP INTRO"
.byte 255

intro:
    ; Playing these sounds seems to fix some sound issues on the initial music playing later
    jsr sound_explode
    jsr sound_shoot
    lda #<intro_1
    sta active_exp
    lda #>intro_1
    sta active_exp+1
@set_xy:
    ldy #0
    lda (active_exp), y
    sta mb_x
    iny
    lda (active_exp), y
    sta mb_y
    iny
    phy
    jsr point_to_convo_mapbase
    ply
@next_char:
    lda (active_exp), y
    cmp #0
    beq @found_null
    ; Write the char
    phy
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    ply
    iny
    bra @next_char
@found_null:
    iny
    clc
    tya
    adc active_exp
    sta active_exp
    lda active_exp+1
    adc #0
    sta active_exp+1
    ldy #0
    lda (active_exp), y
    cmp #255
    beq @found_end
    bra @set_xy
@found_end:
    jsr watch_for_joystick_press
    rts

.endif