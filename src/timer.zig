const time = @import("std").time;
const std = @import("std");
const raylib = @import("raylib");

const State = @import("app.zig").App.State;

pub const Timer = struct {
    duration: u64,
    display: [5:0]u8,
    threshold: f32 = 1,

    pub const font_size = 80;

    pub fn init(self: *Timer, duration: u64) void {
        self.* = Timer{
            .duration = duration,
            .display = std.mem.zeroes(@TypeOf(self.display)),
        };
        self.update_display();
    }

    pub fn reset(self: *Timer, new_duration_s: u64) void {
        self.duration = new_duration_s;
        self.update_display();
        self.threshold = 1;
    }

    pub fn tick(self: *Timer) void {
        self.threshold -= raylib.getFrameTime();

        if (self.threshold <= 0) {
            self.duration -= 1;
            self.update_display();
            self.threshold = 1;
        }
    }

    fn update_display(self: *Timer) void {
        const minutes = self.duration / 60;
        const seconds = self.duration % 60;

        _ = std.fmt.bufPrint(self.display[0.. :0], "{:02}:{:02}", .{ minutes, seconds }) catch unreachable;
    }

    pub fn draw(self: *const Timer) void {
        const display_width = raylib.measureText(&self.display, font_size);
        const center_x = @divFloor(raylib.getScreenWidth() - display_width, 2);
        const center_y = @divFloor(raylib.getScreenHeight() - font_size, 2);

        raylib.drawText(&self.display, center_x, center_y, font_size, .white);
    }
};

pub const Durations = struct {
    focus: u64 = 25 * time.s_per_min,
    short_break: u64 = 5 * time.s_per_min,
    long_break: u64 = 15 * time.s_per_min,

    pub fn from_state(self: Durations, state: State) u64 {
        switch (state) {
            .focus => return self.focus,
            .short_break => return self.short_break,
            .long_break => return self.long_break,
        }
    }
};
