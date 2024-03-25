.ifndef SOUND_S
SOUND_S = 1

SOUND_PRIORITY_MUSIC = 0
SOUND_PRIORITY_SFX = 1

sound_init:
    lda #ZSM_BANK
	jsr zsm_init_engine
	jsr zsmkit_setisr
    rts

sound_shoot:
    ldx #SOUND_PRIORITY_SFX
	jsr zsm_stop

	lda #0
	ldx #SOUND_PRIORITY_SFX ; Priority
	ldy #>HIRAM; address hi to Y
	jsr zsm_setmem

	ldx #SOUND_PRIORITY_SFX
	jsr zsm_play
    rts

.endif