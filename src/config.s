.ifndef CONFIG_S
CONFIG_S = 1

.include "x16.inc"

config:
    lda #VERA_DC_VIDEO_BITS
    sta VERA_DC_VIDEO
    lda #VERA_L1_CONFIG_BITS
    sta VERA_L1_CONFIG
    lda #VERA_L1_MAPBASE_BITS
    sta VERA_L1_MAPBASE
    lda #VERA_L1_TILEBASE_BITS
    sta VERA_L1_TILEBASE
    rts

.endif