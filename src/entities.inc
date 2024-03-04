.ifndef ENTITIES_H
ENTITIES_H=1

.struct Entity
    _x .word
    _y .word
    _pixel_x .word
    _pixel_y .word
    _vel_x .word
    _vel_y .word
    _ang .byte ;0=0, 1=22.5, 2=45, 3=67.5, 4=90, 5=112.5, etc.
    _sprite_num .byte
    _image_addr .word
.endstruct

.endif