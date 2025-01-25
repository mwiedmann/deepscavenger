.ifndef LOADING_S
LOADING_S = 1

ship_filename: .asciiz "ship.bin"
ship_thrust_filename: .asciiz "shipthr.bin"
enemy_filename: .asciiz "enemy.bin"
enemy_laser_filename: .asciiz "elaser.bin"
laser_filename: .asciiz "laser.bin"
astbig_filename: .asciiz "astbig.bin"
astsml_filename: .asciiz "astsml.bin"
gem_filename: .asciiz "gem.bin"
score_filename: .asciiz "score.bin"
font_filename: .asciiz "font.bin"
warp_filename: .asciiz "warp.bin"
exp_filename: .asciiz "exp.bin"
mine_filename: .asciiz "mine.bin"

missile_filename: .asciiz "missile.zsm"
explode_filename: .asciiz "explode.zsm"

load_sprites:
    jsr load_ship
    jsr load_ship_thust
    jsr load_enemy
    jsr load_enemy_laser
    jsr load_laser
    jsr load_astbig
    jsr load_astsml
    jsr load_gem
    jsr load_score
    jsr load_font
    jsr load_warp
    jsr load_exp
    jsr load_mine
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

load_ship_thust:
    lda #11
    ldx #<ship_thrust_filename
    ldy #>ship_thrust_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<SHIP_THRUST_LOAD_ADDR 
    ldy #>SHIP_THRUST_LOAD_ADDR
    jsr LOAD
    rts

load_enemy:
    lda #9
    ldx #<enemy_filename
    ldy #>enemy_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<ENEMY_LOAD_ADDR 
    ldy #>ENEMY_LOAD_ADDR
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

load_enemy_laser:
    lda #10
    ldx #<enemy_laser_filename
    ldy #>enemy_laser_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #2 ; VRAM 1st bank
    ldx #<ENEMY_LASER_LOAD_ADDR 
    ldy #>ENEMY_LASER_LOAD_ADDR
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
    lda #3 ; VRAM 2nd bank
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

load_score:
    lda #9
    ldx #<score_filename
    ldy #>score_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<SCORE_LOAD_ADDR 
    ldy #>SCORE_LOAD_ADDR
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
    lda #2 ; VRAM 1st bank
    ldx #<WARP_LOAD_ADDR 
    ldy #>WARP_LOAD_ADDR
    jsr LOAD
    rts

load_mine:
    lda #8
    ldx #<mine_filename
    ldy #>mine_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #3 ; VRAM 2nd bank
    ldx #<MINE_LOAD_ADDR 
    ldy #>MINE_LOAD_ADDR
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
    ldx #<missile_filename
    ldy #>missile_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #0 ; RAM
    ldx #<MISSILE_SOUND 
    ldy #>MISSILE_SOUND
    jsr LOAD

    lda #11
    ldx #<explode_filename
    ldy #>explode_filename
    jsr SETNAM
    ; 0,8,2
    lda #0
    ldx #8
    ldy #2
    jsr SETLFS
    lda #0 ; RAM
    ldx #<EXPLODE_SOUND 
    ldy #>EXPLODE_SOUND
    jsr LOAD
    
    rts

.endif