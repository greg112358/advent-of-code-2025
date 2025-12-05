const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Running day ...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 20_000;
    const file = try std.fs.cwd().readFileAlloc(allocator, "day.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});
    if (file == MAX_BYTES) {
        unreachable;
    }
    //print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.", .{ part1Answer, part2Answer });
}
