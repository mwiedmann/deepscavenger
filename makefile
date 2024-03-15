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
	node tools/gimp-pal-convert.js gfx/sprites.data.pal build/PAL.BIN

img:
	node tools/gimp-img-convert.js gfx/sprites.data build/SHIP.BIN 32 32 8 0 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/LASER.BIN 32 32 8 8 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/UFO.BIN 32 32 8 16 5 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GEM.BIN 32 32 8 32 1 1
	node tools/gimp-img-convert.js gfx/sprites.data build/GATE.BIN 64 64 4 16 1 1
	node tools/gimp-img-convert.js gfx/sprites.data build/FONT.BIN 16 16 16 160 16 4
