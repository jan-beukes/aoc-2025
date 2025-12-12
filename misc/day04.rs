#![allow(dead_code)]
type Point = (i32, i32);

struct Grid {
    width: i32,
    height: i32,
    cells: Vec<Vec<char>>,
}

fn neighbor_count_goofy(grid: &Grid, row: i32, col: i32) -> usize {
    (row-1..=row+1)
        .filter(|r| *r >= 0 && *r < grid.height)
        .map(|r|
            (col-1..=col+1)
            .filter(|c|
                (r, *c) != (row, col) &&
                *c >= 0 && *c < grid.width &&
                grid.cells[r as usize][*c as usize] == '@')
            .count())
        .sum()
}

fn neighbor_count(grid: &Grid, row: i32, col: i32) -> usize {
    let mut count = 0;
    for r in row-1..=row+1 {
        if r < 0 || r >= grid.height { continue }
        for c in col-1..=col+1 {
            if (r, c) == (row, col) || c < 0 || c >= grid.width {
                continue
            }
            if grid.cells[r as usize][c as usize] == '@' { count += 1 }
        }
    }
    count
}

fn get_accessible(grid: &Grid) -> Vec<Point> {
    (0..grid.height).flat_map(move |r|
        (0..grid.width).filter_map(move |c|
            (grid.cells[r as usize][c as usize] == '@' &&
             neighbor_count(grid, r, c) < 4).then_some((r, c))
        )
    ).collect()
}

fn solve(grid: &mut Grid) -> (usize, usize) {
    let mut accessible = get_accessible(grid);
    let count_accessible = accessible.len();
    let mut removals = 0;
    while accessible.len() > 0 {
        removals += accessible.len();
        for point in accessible {
            grid.cells[point.0 as usize][point.1 as usize] = '.';
        }
        accessible = get_accessible(grid);
    }
    (count_accessible, removals)
}

fn main() {
    let start_time = std::time::Instant::now();
    let content = std::fs::read_to_string("input04.txt")
        .expect("file not found");
    let cells: Vec<_> = content.
        lines()
        .map(|line| line.chars().collect::<Vec<_>>())
        .collect();

    let mut grid = Grid {
        height: cells.len() as i32,
        width: cells[0].len() as i32,
        cells,
    };
    let (p1, p2) = solve(&mut grid);
    println!("Part one: {p1}");
    println!("Part two: {p2}");
    println!("took {:?}", start_time.elapsed());
}
