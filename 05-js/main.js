const fs = require('fs');

function partOne(db) {
    return db.items.filter((id) => 
        db.ranges.some((r) => r.start <= id && id <= r.end)
    ).length;
}

function partTwo(ranges) {
    ranges.sort((a, b) => a.start - b.start);
    let total = 0;
    let current = ranges[0];
    for (let r of ranges) {
        if (current.end < r.start) {
            // consume
            total += current.end - current.start + 1;
            current = r;
        } else if (current.end < r.end) {
            // grow
            current.end = r.end;
        }
    }
    total += current.end - current.start + 1;
    return total;
}

function parseDatabase(content) {
    let [ranges, items] = content.split("\n\n").map((list) => list.split("\n"));
    // to numbers and shit
    return {
        items: items.map(Number),
        ranges: ranges.map((range) => {
            let [start, end] = range.split("-").map(Number);
            return {
                start,
                end,
            };
        }),
    };
}

const file = "input.txt";
const content = fs.readFileSync(file, 'utf8').trim();
let db = parseDatabase(content);
console.log(`Part one: ${partOne(db)}`);
console.log(`Part two: ${partTwo(db.ranges)}`);
