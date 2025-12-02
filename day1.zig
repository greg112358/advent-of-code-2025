const std = @import("std");
const print = std.debug.print;

const EMPTY = 'X';
pub fn main() !void {
    print("Running day 1...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 20_000;
    const file = try std.fs.cwd().readFileAlloc(allocator, "day1.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});

    var rotation = [_]u8{0} ** 8;
    //const all_zero = [_]u16{0} ** 10;
    var rotationIndex: usize = 0;
    var ignoreWhitespace = false;
    var dialIndex: i32 = 50;
    var cnt: i32 = 0;
    for (file) |ch| {
        if (!std.ascii.isAscii(ch)) {
            unreachable;
        }
        if (std.ascii.isWhitespace(ch)) {
            if (ignoreWhitespace) {
                continue;
            }
            ignoreWhitespace = true;
            dialIndex = try rotate(dialIndex, rotation[0..rotationIndex]);
            if (@mod(dialIndex, 100) == 0) {
                cnt = cnt + 1;
            }
            rotation = [_]u8{0} ** 8;
            rotationIndex = 0;
        } else {
            ignoreWhitespace = false;
            rotation[rotationIndex] = ch;
            rotationIndex = rotationIndex + 1;
        }
    }
    print("Answer is {}\n Program exit.", .{cnt});
}

fn rotate(dialIndex: i32, rotation: []u8) !i32 {
    const numStr: []u8 = rotation[1..];
    //print("{s}\n", .{numStr});
    const clicks: i32 = try std.fmt.parseInt(i32, numStr, 10);
    //print("{}\n", .{clicks});
    if (rotation[0] == 'L') {
        return dialIndex - clicks;
    } else if (rotation[0] == 'R') {
        return dialIndex + clicks;
    } else {
        unreachable;
    }
}
