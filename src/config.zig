const std = @import("std");
const time = @import("std").time;
const timer = @import("timer.zig");

pub const Config = struct {
    durations: timer.Durations = timer.Durations{},

    pub fn load_from_file(self: *Config, allocator: std.mem.Allocator) !void {
        const home = std.posix.getenvZ("HOME") orelse return;

        const filepath = try std.mem.concat(allocator, u8, &.{ home, "/.config/pomodoro/config" });
        defer allocator.free(filepath);

        var file = try std.fs.openFileAbsolute(filepath, .{});
        defer file.close();

        var buffered_reader = std.io.bufferedReaderSize(1024, file.reader());
        var reader = buffered_reader.reader();

        var buf: [1024]u8 = undefined;

        while (try reader.readUntilDelimiterOrEof(buf[0..], '\n')) |line| {
            if (line.len == 0 or line[0] == '#') {
                continue;
            }

            const found_index = std.mem.indexOf(u8, line, "=");
            if (found_index) |index| {
                const left = std.mem.trim(u8, line[0..index], " ");
                const right = std.mem.trim(u8, line[index + 1 ..], " ");

                const parsed_duration = std.fmt.parseUnsigned(u64, right, 10) catch continue;

                if (std.mem.eql(u8, left, "focus")) {
                    self.durations.focus = parsed_duration * time.s_per_min;
                    continue;
                }

                if (std.mem.eql(u8, left, "short-break")) {
                    self.durations.short_break = parsed_duration * time.s_per_min;
                    continue;
                }

                if (std.mem.eql(u8, left, "long-break")) {
                    self.durations.long_break = parsed_duration * time.s_per_min;
                    continue;
                }
            }
        }
    }
};
