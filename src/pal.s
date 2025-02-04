.ifndef PAL_S
PAL_S = 1

mainpal_filename: .asciiz "mainpal.bin"
titlepal_filename: .asciiz "tpal.bin"

load_mainpal:
    lda #11
    ldx #<mainpal_filename
    ldy #>mainpal_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<PALETTE_ADDR 
    ldy #>PALETTE_ADDR
    jsr LOAD
    rts

load_titlepal:
    lda #8
    ldx #<titlepal_filename
    ldy #>titlepal_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<PALETTE_ADDR 
    ldy #>PALETTE_ADDR
    jsr LOAD
    rts

.endif