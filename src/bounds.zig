const raylib = @import("raylib");
const Timer = @import("timer.zig").Timer;

const default_width = 140;
const default_height = 50;
const default_padding = 5;

pub const Buttons = struct {
    start: raylib.Rectangle,
    focus: raylib.Rectangle,
    short: raylib.Rectangle,
    long: raylib.Rectangle,

    pub fn init(self: *Buttons) void {
        const centered_rect = create_centered();

        self.start = centered_rect;
        self.start.y += Timer.font_size - 5;

        self.short = centered_rect;
        self.short.y -= Timer.font_size + 5;

        self.long = self.short;
        self.long.x += default_width + default_padding;

        self.focus = self.short;
        self.focus.x -= default_width + default_padding;
    }
};

fn create_centered() raylib.Rectangle {
    const screen_width: f32 = @floatFromInt(raylib.getScreenWidth());
    const screen_height: f32 = @floatFromInt(raylib.getScreenHeight());

    return .{
        .x = (screen_width - default_width) / 2,
        .y = (screen_height - default_height) / 2,
        .width = default_width,
        .height = default_height,
    };
}
