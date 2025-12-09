package main

import rl "vendor:raylib"
import "core:fmt"

draw_shape :: proc(positions: []Pos) {
    for i in 1..<len(positions) {
        pos := positions[i]
        prev := positions[i-1]
        rl.DrawLine(i32(prev.x), i32(prev.y), i32(pos.x), i32(pos.y), rl.RED)
    }
    first, last := positions[0], positions[len(positions)-1]
    rl.DrawLine(i32(last.x), i32(last.y), i32(first.x), i32(first.y), rl.RED)
}

draw_rectangle_from_max :: proc(max_rect: [2]Pos, color: rl.Color) {
    x := min(max_rect[0].x, max_rect[1].x)
    y := min(max_rect[0].y, max_rect[1].y)
    w := max(1, abs(max_rect[1].x - max_rect[0].x))
    h := max(1, abs(max_rect[1].y - max_rect[0].y))
    rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), color)
}

visualize :: proc(positions: []Pos, max_rect, max_rect_contained: [2]Pos) {
    max_area := rect_area(max_rect[0], max_rect[1])
    max_area_contained := rect_area(max_rect_contained[0], max_rect_contained[1])

    part_one_color := rl.BLUE
    part_two_color := rl.GREEN

    min_pos := positions[0]
    max_pos := positions[0]
    for pos in positions {
        if pos.x < min_pos.x do min_pos.x = pos.x
        if pos.y < min_pos.y do min_pos.y = pos.y

        if pos.x > max_pos.x do max_pos.x = pos.x
        if pos.y > max_pos.y do max_pos.y = pos.y
    }

    rl.InitWindow(800, 800, "Day 9")

    camera: rl.Camera2D
    width, height := max_pos.x - min_pos.x, max_pos.y - min_pos.y
    camera.target = { 0.5*f32(min_pos.x + max_pos.x), 0.5*f32(min_pos.y + max_pos.y)}
    camera.zoom = min(f32(rl.GetScreenWidth())/f32(width), f32(rl.GetScreenHeight())/f32(height))
    camera.offset = { camera.zoom*0.5*f32(width), camera.zoom*0.5*f32(height) }

    for !rl.WindowShouldClose() {
        scroll := rl.GetMouseWheelMove()
        if rl.IsMouseButtonDown(.LEFT) {
            camera.target -= rl.GetMouseDelta() / camera.zoom
        }
        if scroll != 0 {
            if scroll < 0 {
                camera.zoom *= 0.9
            } else {
                camera.zoom *= 1.1
            }
        }
        rl.ClearBackground(rl.BLACK)
        rl.BeginDrawing()
        rl.BeginMode2D(camera)

        draw_rectangle_from_max(max_rect, rl.Fade(part_one_color, 0.8))
        draw_rectangle_from_max(max_rect_contained, rl.Fade(part_two_color, 0.8))

        draw_shape(positions)
        rl.EndMode2D()

        rl.DrawText(rl.TextFormat("Area: %v", max_area), 10, 10, 20, part_one_color)
        rl.DrawText(rl.TextFormat("Area: %v", max_area_contained), 10, 40, 20, part_two_color)
        rl.EndDrawing()

    }
}
