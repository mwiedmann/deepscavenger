const fs = require("fs");
const color=208
const stars = []

let d=1
let lastHit=false

for(let i=0; i<1024; i++){
    let n=0
    if (!lastHit && Math.random()*100 > 60) {
        n=d
        d++
        if (d==5) {
            d=1
        }
        lastHit=true
    } else {
        lastHit=false
    }
    stars.push(n)
}

//console.log(stars)

const data=stars.reduce((p,c)=> {
    p.push(c,c===0 ? 0 : color)
    return p
},[])

output = new Uint8Array(data);
fs.writeFileSync("build/FIELD.BIN", output, "binary");
