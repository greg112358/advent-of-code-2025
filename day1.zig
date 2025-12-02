const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Running day 1...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 20_000;
    const file = try std.fs.cwd().readFileAlloc(allocator, "day1.txt", MAX_BYTES);
    //const file = try std.fs.cwd().readFileAlloc(allocator, "day1example.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});

    var rotation = [_]u8{0} ** 8;
    //const all_zero = [_]u16{0} ** 10;
    var rotationIndex: usize = 0;
    var ignoreWhitespace = false;
    var dialIndex: i32 = 50;
    var part1Cnt: i32 = 0;
    var part2Cnt: i32 = 0;
    for (file) |ch| {
        if (!std.ascii.isAscii(ch)) {
            unreachable;
        }
        if (std.ascii.isWhitespace(ch)) {
            if (ignoreWhitespace) {
                continue;
            }
            ignoreWhitespace = true;
            var oldDialIndex = dialIndex;
            dialIndex = try rotate(dialIndex, rotation[0..rotationIndex]);
            //pt2 calc
            while (true) {
                if (dialIndex > oldDialIndex) {
                    oldDialIndex += 1;
                } else if (dialIndex < oldDialIndex) {
                    oldDialIndex -= 1;
                } else {
                    break;
                }
                if (@mod(oldDialIndex, 100) == 0) {
                    part2Cnt = part2Cnt + 1;
                }
            }
            //pt 1 calc
            if (@mod(dialIndex, 100) == 0) {
                part1Cnt += 1;
            }
            rotation = [_]u8{0} ** 8;
            rotationIndex = 0;
        } else {
            ignoreWhitespace = false;
            rotation[rotationIndex] = ch;
            rotationIndex = rotationIndex + 1;
        }
    }
    print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.", .{ part1Cnt, part2Cnt });
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
