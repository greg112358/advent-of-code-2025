const std = @import("std");
pub fn readLines(buf: []u8, allocator: std.mem.Allocator) ![][]u8 {
    var line: [40_000]u8 = [_]u8{0} ** 40_000;
    var lines: [40_000][]u8 = [_][]u8{&.{}} ** 40_000;
    var index: usize = 0;
    var lineNo: usize = 0;
    for (buf) |ch| {
        if (ch == '\n' or ch == 10) {
            const lineSlice = line[0..index];
            const newLine = try allocator.alloc(u8, index);
            @memcpy(newLine, lineSlice);
            lines[lineNo] = newLine;
            std.debug.print("{s}\n", .{lines[lineNo]});
            index = 0;
            lineNo += 1;
            continue;
        }
        line[index] = ch;
        index += 1;
    }
    return lines[0..lineNo];
}
