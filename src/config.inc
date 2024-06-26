.ifndef CONFIG_H
CONFIG_H=1

ZSM_BANK = 1

TILE_COUNT = 64
TILES_PER_ROW = 64
TILES_PER_COL = 32
VISIBLE_TILES_PER_ROW = 40
VISIBLE_TILES_PER_COL = 30

MAPBASE_L1_ADDR = 0
TILEBASE_L1_ADDR = $1000 ; 4kB

VERA_DC_VIDEO_BITS = %11100001; Sprites on, Layer 1 on, other defaults
VERA_L1_CONFIG_BITS = %00010011; 64x32 tiles, 8bbp
VERA_L1_MAPBASE_BITS = (MAPBASE_L1_ADDR>>9) ; Mapbase at VRAM Addr 0, need 4kB
VERA_L1_TILEBASE_BITS = (TILEBASE_L1_ADDR>>9) + %00000011 ; Start at 4Kb VRAM, 16x16 pixel tiles

TILEBASE_SIZE = 256 * TILE_COUNT ; 12kb
SHIP_LOAD_ADDR = TILEBASE_L1_ADDR+TILEBASE_SIZE; 4096+12288=16384
DEFAULT_FRAME_SIZE = 1024
SHIP_FRAME_COUNT = 5

SHIP_SPRITE_FRAME_SIZE = 1024

SHIP_THRUST_LOAD_ADDR = SHIP_LOAD_ADDR + (SHIP_SPRITE_FRAME_SIZE*SHIP_FRAME_COUNT)

ENEMY_LOAD_ADDR = SHIP_THRUST_LOAD_ADDR + (SHIP_SPRITE_FRAME_SIZE*SHIP_FRAME_COUNT)
ENEMY_SPRITE_FRAME_SIZE = 1024
ENEMY_FRAME_COUNT = 5

ENEMY_LASER_LOAD_ADDR = ENEMY_LOAD_ADDR + (ENEMY_SPRITE_FRAME_SIZE*ENEMY_FRAME_COUNT)
ENEMY_LASER_SPRITE_FRAME_SIZE = 256
ENEMY_LASER_FRAME_COUNT = 5

LASER_LOAD_ADDR = ENEMY_LASER_LOAD_ADDR + (ENEMY_LASER_SPRITE_FRAME_SIZE*ENEMY_LASER_FRAME_COUNT)
LASER_SPRITE_FRAME_SIZE = 256
LASER_FRAME_COUNT = 5

ASTSML_LOAD_ADDR = LASER_LOAD_ADDR + (LASER_SPRITE_FRAME_SIZE*LASER_FRAME_COUNT)
ASTSML_SPRITE_FRAME_SIZE = 256
ASTSML_SPRITE_COUNT = 16

GEM_LOAD_ADDR = ASTSML_LOAD_ADDR + (ASTSML_SPRITE_FRAME_SIZE*ASTSML_SPRITE_COUNT)
GEM_SPRITE_FRAME_SIZE = 256
GEM_SPRITE_COUNT = 8

GATE_LOAD_ADDR = GEM_LOAD_ADDR + (GEM_SPRITE_FRAME_SIZE*GEM_SPRITE_COUNT)
GATE_SPRITE_FRAME_SIZE = 4096

WARP_LOAD_ADDR = GATE_LOAD_ADDR + GATE_SPRITE_FRAME_SIZE
WARP_SPRITE_FRAME_SIZE = 1024
WARP_SPRITE_COUNT = 8

; Use VRAM Hi bank from here on
; Need to check if anything before this changes and hits 64k
; loading.s needs to have the VRAM flag updated so it loads into correct VRAM bank

ASTBIG_LOAD_ADDR = $10000 ; ASTSML_LOAD_ADDR + (ASTSML_SPRITE_FRAME_SIZE*ASTSML_SPRITE_COUNT)
ASTBIG_SPRITE_FRAME_SIZE = 1024
ASTBIG_SPRITE_COUNT = 16

; Portraits
PORTRAIT_SPRITE_FRAME_SIZE = 4096
PORTRAIT_SPRITE_COUNT = 4

PORTRAIT1_LOAD_ADDR = ASTBIG_LOAD_ADDR + (ASTBIG_SPRITE_FRAME_SIZE * ASTBIG_SPRITE_COUNT)

PORTRAIT2_LOAD_ADDR = PORTRAIT1_LOAD_ADDR + (PORTRAIT_SPRITE_FRAME_SIZE * PORTRAIT_SPRITE_COUNT)

EXPLOSION_LOAD_ADDR = PORTRAIT2_LOAD_ADDR + (PORTRAIT_SPRITE_FRAME_SIZE * PORTRAIT_SPRITE_COUNT)
EXPLOSION_SPRITE_FRAME_SIZE = 1024
EXPLOSION_FRAME_COUNT = 8

SHIP_ROTATE_TICKS = 4
SHIP_THRUST_TICKS = 6
ENTITY_ACCEL_TICKS = 3
SHIP_FIRE_TICKS = 30
SHIP_MAX_ACCEL = 64

LASER_SPRITE_NUM_START = 0
LASER_ENTITY_NUM_START = 0
LASER_COUNT = 3

ENEMY_SPRITE_NUM_START = LASER_SPRITE_NUM_START + LASER_COUNT
ENEMY_ENTITY_NUM_START = LASER_ENTITY_NUM_START + LASER_COUNT
ENEMY_COUNT = 2

ENEMY_LASER_SPRITE_NUM_START = ENEMY_SPRITE_NUM_START + ENEMY_COUNT
ENEMY_LASER_ENTITY_NUM_START = ENEMY_ENTITY_NUM_START + ENEMY_COUNT
ENEMY_LASER_COUNT = 10

ASTSML_SPRITE_NUM_START = ENEMY_LASER_SPRITE_NUM_START + ENEMY_LASER_COUNT
ASTSML_ENTITY_NUM_START = ENEMY_LASER_ENTITY_NUM_START + ENEMY_LASER_COUNT
ASTSML_COUNT = 20

ASTBIG_SPRITE_NUM_START = ASTSML_SPRITE_NUM_START + ASTSML_COUNT
ASTBIG_ENTITY_NUM_START = ASTSML_ENTITY_NUM_START + ASTSML_COUNT
ASTBIG_COUNT = 16

GEM_SPRITE_NUM_START = ASTBIG_SPRITE_NUM_START + ASTBIG_COUNT
GEM_ENTITY_NUM_START = ASTBIG_ENTITY_NUM_START + ASTBIG_COUNT
GEM_COUNT = 10

WARP_SPRITE_NUM = GEM_SPRITE_NUM_START + GEM_COUNT
WARP_ENTITY_NUM = GEM_ENTITY_NUM_START + GEM_COUNT
WARP_COUNT = 1

GATE_SPRITE_NUM = WARP_SPRITE_NUM + WARP_COUNT
GATE_ENTITY_NUM = WARP_ENTITY_NUM + WARP_COUNT
GATE_COUNT = 1

SHIP_SPRITE_NUM = GATE_SPRITE_NUM + GATE_COUNT
SHIP_ENTITY_NUM = GATE_ENTITY_NUM + GATE_COUNT

ENTITY_COUNT = LASER_COUNT + ENEMY_COUNT + ENEMY_LASER_COUNT + ASTBIG_COUNT + ASTSML_COUNT + GEM_COUNT + WARP_COUNT + GATE_COUNT + 1 ; +1 for ship at the end

PORTRAIT_SPRITE_NUM_START = SHIP_SPRITE_NUM + 1

STORM_COUNT = 180; 360 ; 6 seconds
DEAD_SHIP_TIME = 180 ; 3 seconds
ENEMY_SHOOT_TIME = 60
LASER_DESTROY_TICKS = 70
ENEMY_LASER_DESTROY_TICKS = 60
START_ASTBIG_COUNT = 10
AST_COLLISIONS_SAFETY = 10

CONVO_TEXT_X = 5
CONVO_TEXT_WAIT_AMOUNT = 3
CONVO_WAIT_BETWEEN_PORTRAITS = 20

ONESHOT_SPRITE_NUM_START = PORTRAIT_SPRITE_NUM_START + 6
ONESHOT_SPRITE_COUNT = 10
ONESHOT_TICKS = 4

SOUNDFX_BANK = 2

.endif