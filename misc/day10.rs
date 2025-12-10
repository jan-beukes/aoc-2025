// NOTE: I did not come up with this solution. This is taken from Sebastiano Tronto
// who was able to solve part two without an external linear programming library/tool
// https://git.tronto.net/aoc/file/2025/10/b.py.html

#![allow(dead_code)]

#[derive(Debug)]
struct Machine {
    lights: u32,
    buttons: Vec<u32>, // stored as bit masks
    joltage: Vec<u32>, // just the list of joltages
}

impl std::str::FromStr for Machine {
    type Err = ();
    fn from_str(string: &str) -> Result<Self, Self::Err> {
        let tokens: Vec<_> = string.split_ascii_whitespace().collect();
        let lights = tokens[0]
            .trim_matches(['[', ']'])
            .chars()
            .rev() // start from back so we can shift over
            .fold(0, |acc, c| (acc << 1) | (c == '#') as u32);

        let buttons = tokens[1..tokens.len()-1]
            .iter()
            .map(|s| {
                s.trim_matches(['(', ')'])
                    .split(',')
                    .map(|n| n.parse::<u8>().unwrap())
                    .fold(0, |acc, n| acc | (1 << n))
            })
            .collect();

        let joltage = tokens[tokens.len()-1]
            .trim_matches(['{', '}'])
            .split(',')
            .map(|n| n.parse::<u32>().unwrap())
            .collect();
 
        Ok(Machine { lights, buttons, joltage })
    }
}

fn part_one(machines: &Vec<Machine>) -> u32 {
    machines
        .iter()
        .map(|m| {
            let mut minimum = u32::MAX;
            let b_count = m.buttons.len();
            // all button combinations since we only need to consider single button presses
            // i is a bit mask for which buttons we should choose
            for i in 0u32..(1 << b_count) {
                let x = (0..b_count).
                    fold(0, |x, j| if (i >> j) & 1 != 0 { x ^ m.buttons[j] } else { x });
                if x == m.lights {
                    minimum = minimum.min(i.count_ones());
                }
            }
            minimum
        })
        .sum()
}

fn main() {
    let content = std::fs::read_to_string("input10.txt").unwrap();
    let machines: Vec<Machine> = content.trim()
        .lines()
        .map(|line| line.parse().unwrap())
        .collect();

    println!("{}", part_one(&machines));
}
