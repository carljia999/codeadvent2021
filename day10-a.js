#!/usr/bin/node

const fs = require('fs')
const file = process.argv[2]
let lines = fs.readFileSync(file, 'utf8')
            .split("\n")
            .filter(x => x.length > 0);

const pairs = new Map([
    [')', ['(', 3]],
    ['>', ['<', 25137]],
    [']', ['[', 57]],
    ['}', ['{', 1197]],
])

function syntax_check(line) {
    let stack = [];
    for (let c of line) {
        if (pairs.has(c)) {
            const opening = stack.pop()
            if ( pairs.get(c)[0] !== opening) {
                return c
            }
        } else {
            stack.push(c)
        }
    }
    return 0
}

function cost(error) {
    return pairs.has(error) ? pairs.get(error)[1] : 0
}

let sum = lines.map(syntax_check).map( cost ).reduce( (pre, cur) => pre + cur );
console.log(sum)
