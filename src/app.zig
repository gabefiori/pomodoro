const std = @import("std");
const mem = @import("std").mem;
const builtin = @import("builtin");
const raylib = @import("raylib");

const Color = @import("raylib").Color;
const timer = @import("timer.zig");

pub const App = struct {
    durations: timer.Durations = timer.Durations{},
    focus_count: u32 = 0,
    state: State = .focus,
    is_running: bool = false,

    pub const State = enum {
        focus,
        short_break,
        long_break,

        const focus_color = Color.init(140, 50, 80, 255);
        const short_break_color = Color.init(0, 121, 170, 255);
        const long_break_color = Color.init(0, 90, 152, 255);

        pub fn to_color(self: State) Color {
            switch (self) {
                .focus => return focus_color,
                .short_break => return short_break_color,
                .long_break => return long_break_color,
            }
        }
    };

    pub fn reset(self: *App, new_state: State) void {
        self.state = new_state;
        self.is_running = false;
        self.focus_count = 0;
        self.set_window_title();
    }

    pub fn end_interval(self: *App) void {
        self.is_running = false;

        if (self.state == .focus) {
            self.state = if (self.focus_count >= 4) .long_break else .short_break;
            self.focus_count += 1;
            return;
        }

        if (self.state == .short_break) {
            self.state = .focus;
            return;
        }

        if (self.state == .long_break) {
            self.focus_count = 0;
            self.state = .focus;
        }

        self.set_window_title();
    }

    pub fn set_window_title(self: *const App) void {
        const title = switch (self.state) {
            .focus => "Pomodoro - Focus",
            .short_break => "Pomodoro - Short Break",
            .long_break => "Pomodoro - Long Break",
        };
        raylib.setWindowTitle(title);
    }

    pub fn current_duration(self: *App) u64 {
        return self.durations.from_state(self.state);
    }

    pub fn notify(self: *const App, allocator: mem.Allocator) void {
        var command: []const []const u8 = undefined;

        switch (builtin.os.tag) {
            .linux => {
                command = &.{ "notify-send", "Pomodoro", switch (self.state) {
                    .focus => "Focus time is over! Take a break.",
                    .short_break => "Short break is over! Back to work.",
                    .long_break => "Long break is over! Time to focus again.",
                } };
            },
            .macos => {
                command = &.{ "osascript", "-e", switch (self.state) {
                    .focus => "display notification \"Focus time is over! Take a break.\" with title \"Pomodoro\"",
                    .short_break => "display notification \"Short break is over! Back to work.\" with title \"Pomodoro\"",
                    .long_break => "display notification \"Long break is over! Time to focus again.\" with title \"Pomodoro\"",
                } };
            },
            else => @compileError("Invalid platform. Only Linux and macOS are supported."),
        }

        var child = std.process.Child.init(command, allocator);
        child.spawn() catch {};
    }
};
