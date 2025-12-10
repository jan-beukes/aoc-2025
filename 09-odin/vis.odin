package main

import rl "vendor:raylib"
import "core:fmt"

draw_shape :: proc(positions: []Pos) {
    for i in 1..<len(positions) {
        pos := positions[i]
        prev := positions[i-1]
        rl.DrawLine(i32(prev.x), i32(prev.y), i32(pos.x), i32(pos.y), rl.RED)
    }
}

draw_rect :: proc(rect: Rect, color: rl.Color) {
    x := rect.min.x
    y := rect.min.y
    w := rect.max.x - rect.min.x
    h := rect.max.y - rect.min.y
    rl.DrawRectangle(i32(x), i32(y), i32(w), i32(h), color)
}

visualize :: proc(positions: []Pos, max_rect, max_rect_contained: Rect) {
    max_area := rect_area(max_rect)
    max_area_contained := rect_area(max_rect_contained)

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

        draw_rect(max_rect, rl.Fade(part_one_color, 0.8))
        draw_rect(max_rect_contained, rl.Fade(part_two_color, 0.8))

        draw_shape(positions)
        rl.EndMode2D()

        rl.DrawText(rl.TextFormat("Area: %v", max_area), 10, 10, 20, part_one_color)
        rl.DrawText(rl.TextFormat("Area: %v", max_area_contained), 10, 40, 20, part_two_color)
        rl.EndDrawing()

    }
}
