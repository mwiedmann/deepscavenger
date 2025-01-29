.ifndef SOUND_S
SOUND_S = 1

SOUND_PRIORITY_SHOOT = 0
SOUND_PRIORITY_EXPLODE = 1
SOUND_PRIORITY_THRUST = 2
SOUND_PRIORITY_CRYSTAL = 3

sound_init:
    lda #ZSM_BANK
	jsr zsm_init_engine
	jsr zsmkit_setisr
    rts

sound_shoot:
	lda #0
	ldx #SOUND_PRIORITY_SHOOT ; Priority
	ldy #>MISSILE_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_SHOOT
	jsr zsm_play
    rts

sound_explode:
	lda #0
	ldx #SOUND_PRIORITY_EXPLODE ; Priority
	ldy #>EXPLODE_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_EXPLODE
	jsr zsm_play
    rts

sound_crystal:
	lda #0
	ldx #SOUND_PRIORITY_CRYSTAL ; Priority
	ldy #>CRYSTAL_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_CRYSTAL
	jsr zsm_play
    rts

playing_thrust: .byte 0

sound_thrust_check:
	lda thrusting
	cmp #1
	beq @thrusting
	; not thrusting, turn sound off if playing
	lda playing_thrust
	cmp #0
	beq @done
	jsr sound_thrust_stop
	bra @done
@thrusting:
	lda playing_thrust
	cmp #1
	beq @done
	jsr sound_thrust_play
@done:
    rts

sound_thrust_stop:
	ldx #SOUND_PRIORITY_THRUST
	jsr zsm_stop
	lda #0
	sta playing_thrust
	rts

sound_thrust_play:
	lda #0
	ldx #SOUND_PRIORITY_THRUST ; Priority
	ldy #>THRUST_SOUND; address hi to Y
	jsr zsm_setmem
	ldx #SOUND_PRIORITY_THRUST
	jsr zsm_play
	lda #1
	sta playing_thrust
	rts

sound_all_stop:
	jsr sound_thrust_stop
	rts

.endif