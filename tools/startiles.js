const fs = require("fs");

const tiles = []

for (let i=0;i<32;i++) {
    tiles.push(0)
}

for (let i=0;i<32;i++) {
    tiles.push(i===6? 0b00010000 : 0)
}

for (let i=0;i<32;i++) {
    tiles.push(i===24? 0b00000100 : 0)
}

for (let i=0;i<32;i++) {
    tiles.push(i===9? 0b01000000 : 0)
}

for (let i=0;i<32;i++) {
    tiles.push(i===21? 0b00100000 : 0)
}

output = new Uint8Array(tiles);
fs.writeFileSync("build/STARS.BIN", output, "binary");
