CC=cl65

make:
	$(CC) --cpu 65C02 -Or -Cl -o ./build/DEEP.PRG -t cx16 -l DEEP.list \
	src/main.s

run:
	cd build && \
	../../x16emur46/x16emu -prg DEEP.PRG -run

debug:
	cd build && \
	../../x16emur46/x16emu -prg DEEP.PRG -debug

pal:
	node tools/gimp-pal-convert.js gfx/ship.data.pal build/PAL.BIN

img:
	node tools/gimp-img-convert.js gfx/ship.data build/SHIP.BIN 32 32 0 1 5