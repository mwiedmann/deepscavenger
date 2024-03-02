.org $080D
.segment "ONCE"

CHROUT = $FFD2
CHECK = 65536-32

.struct Point
    _x .word
    _y .word
.endstruct

    jmp start

p1: .tag Point
p2: .tag Point

start:
    lda #1
    sta p1+Point::_x
    lda #2
    sta p1+Point::_y
    lda #3
    sta p2+Point::_x
    lda #4
    sta p2+Point::_y
    rts