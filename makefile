CC=cl65

make:
	$(CC) --cpu 65C02 -Or -Cl -o ./build/DEEP.PRG -t cx16 \
	src/main.s

run:
	cd build && \
	../../x16emur46/x16emu -prg DEEP.PRG -run

debug:
	cd build && \
	../../x16emur46/x16emu -prg DEEP.PRG -debug
