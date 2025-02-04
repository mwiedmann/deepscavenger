.ifndef TITLE_S
TITLE_S = 1

TITLE_VERA_DC_VIDEO_BITS = %10100001
TITLE_VERA_L1_CONFIG_BITS = %00000111;
TITLE_VERA_L1_TILEBASE_BITS = 0

title_filename: .asciiz "title.bin"

show_title:
    ; hide layers until everything loaded
    lda #VERA_LAYERS_OFF_DC_VIDEO_BITS
    sta VERA_DC_VIDEO
    ; load title and pal
    lda #9
    ldx #<title_filename
    ldy #>title_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #0
    ldy #0
    jsr LOAD
    jsr load_titlepal
    ; now turn on layer to show title
    lda #TITLE_VERA_DC_VIDEO_BITS
    sta VERA_DC_VIDEO
    lda #TITLE_VERA_L1_CONFIG_BITS
    sta VERA_L1_CONFIG
    lda #TITLE_VERA_L1_TILEBASE_BITS
    sta VERA_L1_TILEBASE
    lda #64
    sta VERA_HSCALE
    lda #64
    sta VERA_VSCALE
    ; wait then hide
    jsr watch_for_joystick_press
    lda #VERA_LAYERS_OFF_DC_VIDEO_BITS
    sta VERA_DC_VIDEO
    lda #128
    sta VERA_HSCALE
    lda #128
    sta VERA_VSCALE
    rts

.endif