#!/usr/bin/node

const fs = require('fs')
const file = process.argv[2]
let nums = fs.readFileSync(file, 'utf8')
            .split("\n", 1)[0]
            .split(",")
            .map( x => parseInt(x, 10) );

const avg = nums.reduce( (pre, cur) => pre + cur ) / nums.length;

console.log(avg)
let pos = Math.round(avg)
console.log(pos)

pos = pos - 1

function cost(steps) {
    if (steps < 2) return steps;
    return (1+steps)*steps/2;
}

const sum = nums
            .map( x => Math.abs(x - pos))
            .map( cost )
            .reduce( (pre, cur) => pre + cur );

console.log(sum)
