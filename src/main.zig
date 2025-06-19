const std = @import("std");
const time = @import("std").time;
const raylib = @import("raylib");
const raygui = @import("raygui");

const App = @import("app.zig").App;
const Timer = @import("timer.zig").Timer;
const bounds = @import("bounds.zig");
const Config = @import("config.zig").Config;

const raywhite_int = raylib.Color.ray_white.toInt();
const white_int = raylib.Color.white.toInt();

pub fn main() !void {
    const allocator = std.heap.c_allocator;

    var config: Config = .{};
    config.load_from_file(allocator) catch {};

    var app: App = .{};
    app.durations = config.durations;

    var timer: Timer = undefined;
    timer.init(app.current_duration());

    raylib.setTraceLogLevel(.err);
    raylib.setTargetFPS(60);
    raylib.setConfigFlags(.{ .window_resizable = true });

    raylib.initWindow(800, 600, "Pomodoro");
    defer raylib.closeWindow();

    raygui.setStyle(.default, .{ .default = .text_size }, 18);
    raygui.setStyle(.default, .{ .control = .base_color_normal }, raywhite_int);
    raygui.setStyle(.default, .{ .control = .base_color_focused }, white_int);
    raygui.setStyle(.default, .{ .control = .base_color_pressed }, white_int);

    app.set_window_title();

    while (!raylib.windowShouldClose()) {
        if (raylib.isKeyPressed(.q)) {
            break;
        }

        if (raylib.isKeyPressed(.space)) {
            app.is_running = !app.is_running;
            timer.threshold = 1;
        }

        if (timer.duration < 1) {
            app.end_interval();
            timer.reset(app.current_duration());
            app.notify(allocator);
        }

        if (app.is_running) {
            timer.tick();
        }

        var buttons_bounds: bounds.Buttons = undefined;
        buttons_bounds.init();

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(app.state.to_color());

        if (raygui.button(buttons_bounds.focus, "Focus")) {
            app.reset(.focus);
            timer.reset(app.current_duration());
        }

        if (raygui.button(buttons_bounds.short, "Short Break")) {
            app.reset(.short_break);
            timer.reset(app.current_duration());
        }

        if (raygui.button(buttons_bounds.long, "Long Break")) {
            app.reset(.long_break);
            timer.reset(app.current_duration());
        }

        const start_button_text = if (app.is_running) "#132#Pause" else "#131#Start";
        if (raygui.button(buttons_bounds.start, start_button_text)) {
            app.is_running = !app.is_running;
            timer.threshold = 1;
        }

        timer.draw();
    }
}
