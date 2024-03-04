.ifndef LOADING_S
LOADING_S = 1

ship_filename: .asciiz "ship.bin"
laser_filename: .asciiz "laser.bin"

load_ship:
    lda #$08
    ldx #<ship_filename
    ldy #>ship_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_LOAD_ADDR 
    ldy #>SHIP_LOAD_ADDR
    jsr LOAD
    rts

load_laser:
    lda #$09
    ldx #<laser_filename
    ldy #>laser_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<LASER_LOAD_ADDR 
    ldy #>LASER_LOAD_ADDR
    jsr LOAD
    rts

.endif