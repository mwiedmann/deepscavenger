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
	node tools/gimp-pal-convert.js gfx/ship.data.pal build/PAL.BIN

img:
	node tools/gimp-img-convert.js gfx/ship.data build/SHIP.BIN 32 32 0 1 5