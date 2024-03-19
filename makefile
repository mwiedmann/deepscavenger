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
	node tools/gimp-pal-convert.js gfx/portraits.data.pal build/PORPAL.BIN

img:
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIP.BIN 32 32 8 0 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/LASER.BIN 32 32 8 8 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/ASTBIG.BIN 32 32 8 16 8 2
	node tools/gimp-img-convert.js gfx/sprites.data build/ASTSML.BIN 16 16 16 128 16 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GEM.BIN 32 32 8 48 8 1
	node tools/gimp-img-convert.js gfx/sprites.data build/WARP.BIN 32 32 8 72 8 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GATE.BIN 64 64 4 20 1 1
	node tools/gimp-img-convert.js gfx/sprites.data build/FONT.BIN 16 16 16 224 16 4

por:
	node tools/gimp-img-convert.js gfx/portraits.data build/MGL.BIN 64 64 4 4 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/EGY.BIN 64 64 4 8 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/CGL.BIN 64 64 4 12 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/MGY.BIN 64 64 4 16 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/CGY.BIN 64 64 4 20 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/SGL.BIN 64 64 4 24 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/EGL.BIN 64 64 4 28 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/SGY.BIN 64 64 4 32 4 1
	node tools/gimp-img-convert.js gfx/portraits.data build/DAU.BIN 64 64 4 36 4 1

