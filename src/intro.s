.ifndef INTRO_S
INTRO_S = 1

INTRO_LINE=2

intro_1: 
.byte 13, INTRO_LINE
.asciiz "DEEP SCAVENGER"
.byte 12, INTRO_LINE+1
.asciiz "BY MARK WIEDMANN"
.byte 14, INTRO_LINE+4
.asciiz "--CONTROLS--"
.byte 10, INTRO_LINE+5
.asciiz "LEFT-RIGHT TO ROTATE"
.byte 14, INTRO_LINE+6
.asciiz "UP TO THRUST"
.byte 6, INTRO_LINE+7
.asciiz "DOWN OR ANY BUTTON TO SHOOT"
.byte 14, INTRO_LINE+10
.asciiz "--GAMEPLAY--"
.byte 6, INTRO_LINE+11
.asciiz "SHOOT ASTEROIDS AND FLY OVER"
.byte 6, INTRO_LINE+12
.asciiz "THE CRYSTALS TO HARVEST THEM"
.byte 8, INTRO_LINE+14
.asciiz "EXTRA SHIP EVERY 2 FIELDS"
.byte 13, INTRO_LINE+17
.asciiz "--CUT SCENES--"
.byte 8, INTRO_LINE+18
.asciiz "PRESS BUTTON TO SPEED UP"
.byte 7, INTRO_LINE+19
.asciiz "ENTER-START TO SKIP INTRO"
.byte 14, INTRO_LINE+22
.asciiz "--SETTINGS--"
.byte 7, INTRO_LINE+23
.asciiz "LEFT-RIGHT TO TOGGLE SOUND"
.byte 15, INTRO_LINE+24
.asciiz "SOUND:ON"
.byte 255

ON_OFF_X=22
ON_OFF_Y=INTRO_LINE+24

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
    ; left/right toggle sound, button to continue
    lda #0
    jsr JOYGET
    and #%11
    cmp #%11
    beq @check_button
    jsr sound_toggle
    ; show on/off
    lda #ON_OFF_X
    sta mb_x
    lda #ON_OFF_Y
    sta mb_y
    jsr point_to_convo_mapbase
    lda soundmuted
    beq @on
@off:
    ;F=C6
    lda #$C6
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #(ON_OFF_X+1)
    sta mb_x
    jsr point_to_convo_mapbase
    lda #$C6
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    bra @wait_for_lr_release
@on:
    ;N=CE
    lda #$CE
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    lda #(ON_OFF_X+1)
    sta mb_x
    jsr point_to_convo_mapbase
    lda #$20
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
@wait_for_lr_release:
    lda #0
    jsr JOYGET
    and #%11
    cmp #%11
    bne @wait_for_lr_release
@check_button:
    lda #0
    jsr JOYGET
    and #%11111100
    cmp #%11111100
    beq @found_end
@done:
@release:
    lda #0
    jsr JOYGET
    cmp #255 ; Wait for release
    bne @release
    rts

.endif