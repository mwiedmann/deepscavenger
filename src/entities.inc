.ifndef ENTITIES_H
ENTITIES_H=1

SHIP_TYPE = 0
LASER_TYPE = 1
ASTSML_TYPE = 2
ASTBIG_TYPE = 3
GEM_TYPE = 4
WARP_TYPE = 5
ENEMY_TYPE = 6
ENEMY_LASER_TYPE = 7
MINE_TYPE = 8

.struct Entity
    _x .word
    _y .word
    _pixel_x .word
    _pixel_y .word
    _vel_x .word
    _vel_y .word
    _ang .byte ;0=0, 1=22.5, 2=45, 3=67.5, 4=90, 5=112.5, etc.
    _sprite_num .byte
    _image_addr .dword
    _visible .byte
    _has_accel .byte
    _has_ang .byte
    _ob_behavior .byte ; 0=dead, 1=reset, 2=wrap
    _collision_matrix .byte
    _collision_id .byte
    _type .byte
    _size .byte
    _ang_ticks .byte
    _destroy_ticks .byte
    _coll_size .byte
    _coll_adj .byte
.endstruct

.endif