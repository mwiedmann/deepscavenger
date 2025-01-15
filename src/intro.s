.ifndef INTRO_S
INTRO_S = 1

intro_1: .asciiz "||||      DEEP SCAVENGER||     BY MARK WIEDMANN|||         CONTROLS|   LEFT-RIGHT TO ROTATE|       UP TO THRUST|DOWN OR ANY BUTTON TO SHOOT|||        CUT SCENES|  ANY BUTTON TO SPEED UP|    ENTER-START TO SKIP"

intro:
    lda #0
    sta mb_y
    lda #7
    sta mb_x
    jsr point_to_convo_mapbase
    ldx #0
@next_char:
    lda intro_1, x
    cmp #0
    beq @found_null
    cmp #$DD ; Pipe char for CR 
    beq @found_cr
    ; Write the char
    phx
    jsr get_font_char
    sta VERA_DATA0
    lda #0
    sta VERA_DATA0
    plx
    inx
    bra @next_char
@found_cr:
    inx
    inc mb_y
    lda #7
    sta mb_x
    phx
    jsr point_to_convo_mapbase
    plx
    bra @next_char
@found_null:
    jsr watch_for_joystick_press
    rts

.endif