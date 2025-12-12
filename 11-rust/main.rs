#![allow(dead_code, unused_variables)]
use std::collections::HashMap;
use std::collections::VecDeque;

const INPUT_FILE: &'static str = "input.txt";

type Id = usize;
type AdjList = Vec<Vec<Id>>;

fn topological_paths(adj: &AdjList, start: Id, end: Id, problem: (Id, Id)) -> usize {
    let n = adj.len();
    let mut incoming = vec![0; n];

    // count inoming edges
    for edges in adj {
        for id in edges {
            incoming[*id] += 1;
        }
    }

    let mut queue = VecDeque::new();
    for i in 0..n {
        if incoming[i] == 0 {
            queue.push_back(i)
        }
    }

    // This is Kahn's (BFS based)
    let mut topo_sorted = Vec::new();
    while !queue.is_empty() {
        let node = queue.pop_front().unwrap();
        topo_sorted.push(node);

        // for each adjacent node we remove the edge from the current node
        for id in &adj[node]{
            incoming[*id] -= 1;
            // once we have removed all incoming edges
            // we can push it to the queue
            if incoming[*id] == 0 {
                queue.push_back(*id);
            }
        }
    }

    let mut dp_paths = vec![0; n];
    dp_paths[start] = 1;

    for node in topo_sorted {
        // if we get to one of the target problem nodes remove all other paths
        if node == problem.0 || node == problem.1 {
            let paths = dp_paths[node];
            dp_paths.fill(0);
            dp_paths[node] = paths;
        }
        for id in &adj[node] {
            dp_paths[*id] += dp_paths[node];
        }
    }

    dp_paths[end]
}

fn part_two(adj: &AdjList, start: Id, end: Id, problem: (Id, Id)) -> usize {
    topological_paths(adj, start, end, problem)
}

// this is too slow for part two (without memoization)
fn dfs_paths(node: Id, end: Id, adj: &AdjList, visited: &mut Vec<bool>) -> usize {
    if node == end {
        1
    } else {
        visited[node] = true;
        let sum = adj[node].iter()
            .filter_map(|i| {
                if !visited[*i] {
                    Some(dfs_paths(*i, end, adj, visited))
                } else {
                    None 
                }
            })
            .sum();
        visited[node] = false;
        sum
    }
}

fn part_one(adj: &AdjList, start: Id, end: Id) -> usize {
    let mut visited = vec![false; adj.len()];
    dfs_paths(start, end, adj, &mut visited)
}

fn main() {
    let time_start = std::time::Instant::now();

    let content = std::fs::read_to_string(INPUT_FILE)
        .expect("File not found");
    let lines: Vec<_> = content.trim().lines().collect();

    let mut id_map = HashMap::new();
    // need to use an extra node for 'out' which is not in the input
    let mut adj: AdjList = vec![Vec::new(); lines.len() + 1];
    for line in lines {
        let sep = line.find(':').unwrap();
        let node = &line[0..sep];
        let next_id = id_map.len();
        let node_id = *id_map.entry(node).or_insert(next_id);

        adj[node_id].extend(
            line[sep+1 .. line.len()]
            .split_ascii_whitespace()
            .map(|edge| {
                let next_id = id_map.len();
                *id_map.entry(edge).or_insert(next_id)
            }));
    }

    let you = id_map.get("you");
    let svr = id_map.get("svr");
    let out = id_map["out"];
    if let Some(start) = you {
        println!("Part one: {}", part_one(&adj, *start, out));
    }
    if let Some(start) = svr {
        let problem = (id_map["dac"], id_map["fft"]);
        println!("Part two: {}", part_two(&adj, *start, out, problem));
    }
    println!("took {:?}", time_start.elapsed());
}
