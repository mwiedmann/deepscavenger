.ifndef LOADING_S
LOADING_S = 1

ship_filename: .asciiz "ship.bin"
laser_filename: .asciiz "laser.bin"
astbig_filename: .asciiz "astbig.bin"
astsml_filename: .asciiz "astsml.bin"
gate_filename: .asciiz "gate.bin"
gem_filename: .asciiz "gem.bin"
font_filename: .asciiz "font.bin"
warp_filename: .asciiz "warp.bin"
exp_filename: .asciiz "exp.bin"

testsound_filename: .asciiz "testsnd.zsm"

load_sprites:
    jsr load_ship
    jsr load_laser
    jsr load_astbig
    jsr load_astsml
    jsr load_gem
    jsr load_gate
    jsr load_font
    jsr load_warp
    jsr load_exp
    rts

load_ship:
    lda #8
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
    lda #9
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

load_astbig:
    lda #10
    ldx #<astbig_filename
    ldy #>astbig_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<ASTBIG_LOAD_ADDR 
    ldy #>ASTBIG_LOAD_ADDR
    jsr LOAD
    rts

load_astsml:
    lda #10
    ldx #<astsml_filename
    ldy #>astsml_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<ASTSML_LOAD_ADDR 
    ldy #>ASTSML_LOAD_ADDR
    jsr LOAD
    rts

load_gem:
    lda #7
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

load_font:
    lda #8
    ldx #<font_filename
    ldy #>font_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<TILEBASE_L1_ADDR 
    ldy #>TILEBASE_L1_ADDR
    jsr LOAD
    rts

load_gate:
    lda #8
    ldx #<gate_filename
    ldy #>gate_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<GATE_LOAD_ADDR 
    ldy #>GATE_LOAD_ADDR
    jsr LOAD
    rts

load_warp:
    lda #8
    ldx #<warp_filename
    ldy #>warp_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<WARP_LOAD_ADDR 
    ldy #>WARP_LOAD_ADDR
    jsr LOAD
    rts

load_exp:
    lda #7
    ldx #<exp_filename
    ldy #>exp_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<EXPLOSION_LOAD_ADDR 
    ldy #>EXPLOSION_LOAD_ADDR
    jsr LOAD
    rts

load_sounds:
    lda #11
    ldx #<testsound_filename
    ldy #>testsound_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #0 ; RAM
    ldx #<HIRAM 
    ldy #>HIRAM
    jsr LOAD
    rts

.endif