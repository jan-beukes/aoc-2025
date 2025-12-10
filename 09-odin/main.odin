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

Rect :: struct {
    min: Pos,
    max: Pos,
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
    positions := make([]Pos, len(lines) + 1)

    for line, i in lines {
        sep_idx := strings.index(line, ",")
        assert(sep_idx >= 0)
        x, _ := strconv.parse_int(line[:sep_idx])
        y, _ := strconv.parse_int(line[sep_idx + 1:])
        positions[i] = { x, y }
    }
    positions[len(positions) - 1] = positions[0]

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

    for i in 1..<len(positions) {
        pos := positions[i]
        prev := positions[i-1]
        edge := edge_from_positions(prev, pos)
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

rect_area :: proc(r: Rect) -> int {
    return (r.max.x - r.min.x + 1) * (r.max.y - r.min.y + 1)
}

test_rect_intersection :: proc(rect: Rect, shape_edges: Edges) -> bool {
    for edge in shape_edges.vertical {
        if rect.min.x < edge.pos && edge.pos < rect.max.x {
            start := max(edge.min, rect.min.y)
            end := min(edge.max, rect.max.y)
            if start < end {
                return true
            }

        }
    }

    for edge in shape_edges.horizontal {
        if rect.min.y < edge.pos && edge.pos < rect.max.y {
            start := max(edge.min, rect.min.x)
            end := min(edge.max, rect.max.x)
            if start < end {
                return true
            }

        }
    }

    return false
}

point_inside :: proc(cx, cy: f64, positions: []Pos) -> bool {
    inside := false

    for i in 1..<len(positions) {
        pos, prev := positions[i], positions[i-1]
        x1, y1 := f64(prev.x), f64(prev.y)
        x2, y2 := f64(pos.x), f64(pos.y)

        if (y1 > cy) != (y2 > cy) {
            if cx < x1 {
                inside = !inside
            }
        }
    }

    return inside
}

largest_area_contained :: proc(positions: []Pos) -> (int, Rect) {
    edges := get_edges(positions)

    max_area: int
    max_rect: Rect
    for i in 0..<len(positions) {
        pairs: for j in i+1..<len(positions) {
            a, c := positions[i], positions[j]
            min := Pos{ min(a.x, c.x), min(a.y, c.y) }
            max := Pos{ max(a.x, c.x), max(a.y, c.y) }
            r := Rect{ min, max }
            area := rect_area(r)
            if area <= max_area {
                continue
            }

            if test_rect_intersection(r, edges) {
                continue
            }

            cx:= f64(r.min.x) + 0.5
            cy:= f64(r.min.y) + 0.5
            if !point_inside(cx, cy, positions) {
                continue
            }

            max_area = area
            max_rect = r

        }
    }
    return max_area, max_rect
}

largest_area :: proc(positions: []Pos) -> (int, Rect) {
    max_area: int
    max_rect: Rect
    for i in 0..<len(positions) {
        for j in i+1..<len(positions) {
            a, c := positions[i], positions[j]
            min := Pos{ min(a.x, c.x), min(a.y, c.y) }
            max := Pos{ max(a.x, c.x), max(a.y, c.y) }
            r := Rect{ min, max }
            area := rect_area(r)
            if area > max_area {
                max_area = area
                max_rect = r
            }
        }
    }
    return max_area, max_rect
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
