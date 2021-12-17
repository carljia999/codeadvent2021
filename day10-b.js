#!/usr/bin/node

const fs = require('fs')
const file = process.argv[2]
let lines = fs.readFileSync(file, 'utf8')
            .split("\n")
            .filter(x => x.length);

const pairs = new Map([
    [')', ['(', 1]],
    ['>', ['<', 4]],
    [']', ['[', 2]],
    ['}', ['{', 3]],
])

const reverse_pairs = new Map()

pairs.forEach((v, k) => {
    reverse_pairs.set(v[0],k)
})

function syntax_check(line) {
    let stack = [];
    for (let c of line) {
        if (pairs.has(c)) {
            const opening = stack.pop()
            if ( pairs.get(c)[0] !== opening) {
                return null
            }
        } else {
            stack.push(c)
        }
    }
    let a = stack.map(x => reverse_pairs.get(x)).filter(x => !!x)
    return a.reverse()
}

function cost(incomplete) {
    return incomplete.reduce( (pre, cur) => pre * 5 + pairs.get(cur)[1], 0)
}

let nums = lines.map(syntax_check).filter(x => !!x).map(cost)
nums.sort( (a, b) => a - b )
median = nums[(nums.length-1)/2]
console.log(median)
