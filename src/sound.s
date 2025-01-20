.ifndef SOUND_S
SOUND_S = 1

SOUND_PRIORITY_MUSIC = 0
SOUND_PRIORITY_SFX = 1
SOUND_PRIORITY_SFX_2 = 2

sound_init:
    lda #ZSM_BANK
	jsr zsm_init_engine
	jsr zsmkit_setisr
    rts

sound_shoot:
    ; ldx #SOUND_PRIORITY_SFX
	; jsr zsm_stop

	lda #0
	ldx #SOUND_PRIORITY_SFX ; Priority
	ldy #>MISSILE_SOUND; address hi to Y
	jsr zsm_setmem

	ldx #SOUND_PRIORITY_SFX
	jsr zsm_play
    rts

sound_explode:
    ; ldx #SOUND_PRIORITY_SFX
	; jsr zsm_stop

	lda #0
	ldx #SOUND_PRIORITY_SFX_2 ; Priority
	ldy #>EXPLODE_SOUND; address hi to Y
	jsr zsm_setmem

	ldx #SOUND_PRIORITY_SFX_2
	jsr zsm_play
    rts

.endif