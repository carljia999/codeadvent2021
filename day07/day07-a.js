#!/usr/bin/node

const fs = require('fs')
const file = process.argv[2]
let nums = fs.readFileSync(file, 'utf8')
            .split("\n", 1)[0]
            .split(",")
            .map( x => parseInt(x, 10) );

nums.sort( (a, b) => a - b )

const median = nums[nums.length/2]
const sum = nums
            .map( x => Math.abs(x - median))
            .reduce( (pre, cur) => pre + cur );

console.log(sum)
