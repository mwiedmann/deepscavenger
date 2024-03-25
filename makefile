CC=cl65

make:
	$(CC) --cpu 65C02 -Or -Cl -o ./build/DEEP.PRG -t cx16 -l DEEP.list \
	src/main.s

test:
	$(CC) --cpu 65C02 -Or -Cl -o ./build/TEST.PRG -t cx16 -l TEST.list \
	src/test.s

run:
	cd build && \
	../../x16emur46/x16emu -prg DEEP.PRG -run

rt:
	cd build && \
	../../x16emur46/x16emu -prg TEST.PRG -debug

debug:
	cd build && \
	../../x16emur46/x16emu -prg DEEP.PRG -debug

pal:
	node tools/gimp-pal-convert.js gfx/sprites.data.pal build/MAINPAL.BIN

img:
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIP.BIN 32 32 8 0 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/LASER.BIN 32 32 8 8 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/ASTBIG.BIN 32 32 8 16 8 2
	node tools/gimp-img-convert.js gfx/sprites.data build/ASTSML.BIN 16 16 16 128 16 1
	node tools/gimp-img-convert.js gfx/sprites.data build/EXP.BIN 32 32 8 40 8 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GEM.BIN 32 32 8 48 8 1
	node tools/gimp-img-convert.js gfx/sprites.data build/WARP.BIN 32 32 8 72 8 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GATE.BIN 64 64 4 20 1 1
	node tools/gimp-img-convert.js gfx/sprites.data build/FONT.BIN 16 16 16 224 16 4
	node tools/gimp-img-convert.js gfx/sprites.data build/MGL.BIN 64 64 4 28 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/EGY.BIN 64 64 4 32 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/CGL.BIN 64 64 4 36 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/MGY.BIN 64 64 4 40 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/CGY.BIN 64 64 4 44 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/SGL.BIN 64 64 4 48 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/EGL.BIN 64 64 4 52 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/SGY.BIN 64 64 4 56 4 1
	node tools/gimp-img-convert.js gfx/sprites.data build/DAU.BIN 64 64 4 60 4 1

