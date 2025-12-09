package main

import "core:os"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:fmt"
import "core:testing"

Pos :: [2]int
Edge_Type :: enum {
    Horizontal,
    Vertical,
}

Edge :: struct {
    type:   Edge_Type,
    pos:    int,       // x or y if vertical or horizontal
    min:    int,
    max:    int,
}

Edges :: struct {
    vertical:   []Edge,
    horizontal: []Edge,
}

parse_positions :: proc(file: string, allocator := context.allocator) -> []Pos {
    context.allocator = allocator
    content, ok := os.read_entire_file(file)
    if !ok {
        fmt.eprintln("Error: Could not open", file)
        os.exit(1)
    }
    lines := strings.split_lines(strings.trim_space(string(content)))
    positions := make([]Pos, len(lines))

    for line, i in lines {
        sep_idx := strings.index(line, ",")
        assert(sep_idx >= 0)
        x, _ := strconv.parse_int(line[:sep_idx])
        y, _ := strconv.parse_int(line[sep_idx + 1:])
        positions[i] = { x, y }
    }

    return positions
}

edge_from_positions :: proc(a, b: Pos) -> Edge {
    if a.x == b.x {
        return Edge{
            type = .Vertical,
            pos  = a.x,
            min  = min(a.y, b.y),
            max  = max(a.y, b.y)
        }
    } else {
        assert(a.y == b.y)
        return Edge {
            type = .Horizontal,
            pos  = a.y,
            min  = min(a.x, b.x),
            max  = max(a.x, b.x),
        }
    } 
}

get_edges :: proc(positions: []Pos) -> Edges {
    vertical_edges := make([dynamic]Edge)
    horizontal_edges := make([dynamic]Edge)

    first, last := positions[0], positions[len(positions)-1]
    edge := edge_from_positions(first, last)
    if edge.type == .Vertical {
        append(&vertical_edges, edge)
    } else {
        append(&horizontal_edges, edge)
    }
    for i in 1..<len(positions) {
        pos := positions[i]
        prev := positions[i-1]
        edge = edge_from_positions(prev, pos)
        if edge.type == .Vertical {
            append(&vertical_edges, edge)
        } else {
            append(&horizontal_edges, edge)
        }
    }

    return Edges { 
        vertical = vertical_edges[:],
        horizontal = horizontal_edges[:],
    }
}

rect_area :: proc(a, b: Pos) -> int {
    return (abs(b.x - a.x) + 1) * (abs(b.y - a.y) + 1)
}

is_edge_outside :: proc(edge: Edge, shape_edges: Edges) -> bool {
    intersection_test_edges: []Edge
    if edge.type == .Vertical {
        intersection_test_edges = shape_edges.horizontal
    } else {
        intersection_test_edges = shape_edges.vertical
    }

    found_smaller := false
    found_bigger := false
    for e in intersection_test_edges {
        if e.min <= edge.pos && edge.pos <= e.max {
            // make sure edge is inside
            if e.pos >= edge.max do found_bigger = true
            if e.pos <= edge.min do found_smaller = true
            // don't count corners
            if edge.pos == e.min || edge.pos == e.max do continue

            if edge.min < e.pos && e.pos < edge.max {
                return true
            }
        }
    }
    // make sure edge is not completely outside
    return !(found_smaller && found_bigger)
}

largest_area_contained :: proc(positions: []Pos) -> (int, [2]Pos) {
    edges := get_edges(positions)

    max_area: int
    max_points: [2]Pos
    for i in 0..<len(positions) {
        pairs: for j in i+1..<len(positions) {
            a, c := positions[i], positions[j]
            dx, dy := c.x - a.x, c.y - a.y
            b, d := Pos{ a.x + dx, a.y }, Pos{ a.x, a.y + dy }

            ab := edge_from_positions(a, b)
            bc := edge_from_positions(b, c)
            cd := edge_from_positions(c, d)
            da := edge_from_positions(d, a)
            for e in ([]Edge{ab, bc, cd, da}) {
                if is_edge_outside(e, edges) {
                    continue pairs
                }
            }
            area := rect_area(a, c)
            if area > max_area {
                max_area = area
                max_points = { a, c }
            }
        }
    }
    return max_area, max_points
}

largest_area :: proc(positions: []Pos) -> (int, [2]Pos) {
    max_area: int
    max_points: [2]Pos
    for i in 0..<len(positions) {
        for j in i+1..<len(positions) {
            a, c := positions[i], positions[j]
            area := rect_area(a, c)
            if area > max_area {
                max_area = area
                max_points = { a, c }
            }
        }
    }
    return max_area, max_points
}

INPUT_FILE :: "input.txt"
main :: proc() {
    args := os.args

    input_file := INPUT_FILE
    vis_flag := false

    for arg in args[1:] {
        if arg == "-vis" {
            vis_flag = true
        } else {
            input_file = arg
        }
    }

    positions := parse_positions(input_file)
    area, max_rect := largest_area(positions)
    area_contained, max_rect_contained := largest_area_contained(positions)

    fmt.println("Part one: ", area)
    fmt.println("Part two: ", area_contained)

    if vis_flag {
        visualize(positions, max_rect, max_rect_contained)
    }
}
