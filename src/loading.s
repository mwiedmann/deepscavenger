.ifndef LOADING_S
LOADING_S = 1

ship_filename: .asciiz "ship.bin"
laser_filename: .asciiz "laser.bin"
ufo_filename: .asciiz "ufo.bin"
gate_filename: .asciiz "gate.bin"
gem_filename: .asciiz "gem.bin"

load_sprites:
    jsr load_ship
    jsr load_laser
    jsr load_ufo
    jsr load_gem
    jsr load_gate
    rts

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

load_ufo:
    lda #$07
    ldx #<ufo_filename
    ldy #>ufo_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<UFO_LOAD_ADDR 
    ldy #>UFO_LOAD_ADDR
    jsr LOAD
    rts

load_gem:
    lda #$07
    ldx #<gem_filename
    ldy #>gem_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<GEM_LOAD_ADDR 
    ldy #>GEM_LOAD_ADDR
    jsr LOAD
    rts

load_gate:
    lda #$08
    ldx #<gate_filename
    ldy #>gate_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<GATE_LOAD_ADDR 
    ldy #>GATE_LOAD_ADDR
    jsr LOAD
    rts

.endif