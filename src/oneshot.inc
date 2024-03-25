.ifndef EXP_H
EXP_H=1

.struct Oneshot
    _visible .byte
    _pixel_x .word
    _pixel_y .word
    _frame .byte
    _ticks .byte
    _sprite_num .byte
    _image_addr .dword
.endstruct

.endif