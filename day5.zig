const std = @import("std");
const print = std.debug.print;

const Range = struct {
    start: usize,
    end: usize,
    fn lessThan(context: void, lhs: Range, rhs: Range) bool {
        _ = context;
        return lhs.start < rhs.start;
    }
};
pub fn main() !void {
    print("Running day 5 ...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 90_000;
    // const file = try std.fs.cwd().readFileAlloc(allocator, "day5example.txt", MAX_BYTES);
    const file = try std.fs.cwd().readFileAlloc(allocator, "day5.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});
    if (fileSize == MAX_BYTES) {
        unreachable;
    }

    var line: [100]u8 = [_]u8{0} ** 100;
    var ignoreWhitespace = false;
    var index: usize = 0;
    var ranges: std.ArrayList(Range) = .empty;
    defer ranges.deinit(allocator);
    var ingredients: std.ArrayList(usize) = .empty;
    defer ingredients.deinit(allocator);

    for (file) |ch| {
        if (std.ascii.isWhitespace(ch)) {
            ignoreWhitespace = true;
            const lineSlice = line[0..index];
            //print("{s}\n", .{lineSlice});
            const dashIndex: ?usize = std.ascii.indexOfIgnoreCase(lineSlice, "-");
            if (dashIndex) |i| {
                const start = try std.fmt.parseInt(usize, lineSlice[0..i], 10);
                const end = try std.fmt.parseInt(usize, lineSlice[i + 1 ..], 10);
                const range: Range = .{ .start = start, .end = end };
                try ranges.append(allocator, range);
            } else if (index < 1) {
                //print("ayyyyyyy", .{});
            } else {
                const ingredient: usize = try std.fmt.parseInt(usize, lineSlice, 10);
                try ingredients.append(allocator, ingredient);
            }
            index = 0;
        } else {
            ignoreWhitespace = false;
            line[index] = ch;
            index += 1;
        }
    }
    var part1Answer: usize = 0;
    print("ingredients: {d}\n", .{ingredients.items.len});
    print("ranges: {d}\n", .{ranges.items.len});
    for (ingredients.items) |i| {
        for (ranges.items) |r| {
            //print("Checking {d} in range of {d}-{d}\n", .{ i, r.start, r.end });
            if (i >= r.start and i <= r.end) {
                part1Answer += 1;
                break;
            }
        }
    }

    std.mem.sort(Range, ranges.items, {}, comptime Range.lessThan);

    var part2Answer: usize = 0;
    var j: usize = 0;
    //1-5 start > j --> add end-start+1;j=end;
    //3-6 start < j and end > j --> add end-j; j = end;
    //9-14 start > j --> add end-start+1; j = end;
    //11-13 start < j and end < j --> ;
    //12-100
    for (ranges.items) |r| {
        if (r.start > j) {
            part2Answer += r.end - r.start + 1;
            j = r.end;
        } else if (r.start <= j) {
            if (r.end <= j) {
                continue;
            } else {
                part2Answer += r.end - j;
                j = r.end;
            }
        }
    }
    //var data = [_]u8{ 10, 240, 0, 0, 10, 5 };
    //std.mem.sort(u8, &data, {}, comptime asc());
    print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.", .{ part1Answer, part2Answer });
}

pub fn asc(comptime T: type) fn (void, T, T) bool {
    return struct {
        pub fn inner(_: void, a: T, b: T) bool {
            return a < b;
        }
    }.inner;
}
