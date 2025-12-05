const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Running day 2...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const MAX_BYTES: usize = 20_000;
    //const rawFile = try std.fs.cwd().readFileAlloc(allocator, "day2example.txt", MAX_BYTES);
    const rawFile = try std.fs.cwd().readFileAlloc(allocator, "day2.txt", MAX_BYTES);
    defer allocator.free(rawFile);
    var fileBuffer = [_]u8{0} ** MAX_BYTES;
    var file: []u8 = fileBuffer[0..fileBuffer.len];
    const rawFileSize = rawFile.len;
    std.debug.print("File Size: {} \n", .{rawFileSize});
    if (rawFileSize == MAX_BYTES) {
        unreachable;
    }
    const fileSize = try removeWhitespace(rawFile, file);
    file = file[0..fileSize];
    print("{s}\n", .{file});
    //11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
    //1698522-1698528,446443-446449,38593856-38593862,565653-565659,
    //824824821-824824827,2121212118-2121212124
    var part1Answer: i64 = 0;
    var part2Answer: i64 = 0;
    var last = false;
    while (!last) {
        //print("\n\n", .{});
        const end: ?usize = std.ascii.indexOfIgnoreCase(file, ",");
        var seq: []u8 = undefined;
        if (end) |value| {
            seq = file[0..value];
            file = file[value + 1 ..];
        } else {
            print("last set to true\n", .{});
            last = true;
            seq = file[0..];
        }
        //print("file: {s}\n", .{file});
        //print("seq: {s}\n", .{seq});
        //print("last: {}\n", .{last});
        const optionalDi = std.ascii.indexOfIgnoreCase(seq, "-");
        var di: usize = undefined;
        if (optionalDi) |value| {
            di = value;
            if (di >= seq.len) unreachable;
        } else {
            unreachable;
        }
        const rangeBegin = seq[0..di];
        const rangeEnd = seq[(di + 1)..];
        var stri: [20]u8 = [_]u8{0} ** 20;
        const start = try std.fmt.parseInt(i64, rangeBegin, 10);
        const finish = std.fmt.parseInt(i64, rangeEnd, 10) catch |err| {
            print("ERROR PARSING |{s}| |{}, {}|\n", .{ rangeEnd, rangeEnd.len, di });
            return err;
        };
        var i = start;
        while (i <= finish) {
            var str: []u8 = try std.fmt.bufPrint(&stri, "{d}", .{i});
            const half: usize = str.len / 2;
            var matchthatmatters: bool = false;
            for (1..half + 1) |j| {
                if (@mod(str.len, j) == 0) {
                    var matches = true;
                    const substr = str[0..j];
                    for (0..str.len) |k| {
                        //0,0 | 1,1 | 2,2 | 3,0 | 4,1 | 5,2 | 6,0...
                        const substrIndex = @mod(k, j);
                        matches = matches and str[k] == substr[substrIndex];
                    }
                    matchthatmatters = matchthatmatters or matches;
                }
            }
            if (matchthatmatters) {
                print("invalid id {s} \n", .{str});
                const invalid: i64 = try std.fmt.parseInt(i64, str, 10);
                part2Answer += invalid;
            }
            const firstHalf = str[0..half];
            if (@mod(str.len, 2) == 0) {
                const secondHalf = str[half..];
                var matches = true;
                for (0..half) |j| {
                    matches = matches and firstHalf[j] == secondHalf[j];
                }
                if (matches) {
                    //print("invalid id {s}\n", .{str});
                    const invalid: i64 = try std.fmt.parseInt(i64, str, 10);
                    part1Answer += invalid;
                }
            }
            i = i + 1;
        }
    }
    print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.", .{ part1Answer, part2Answer });
}

fn removeWhitespace(pre: []u8, post: []u8) !usize {
    var postIndex: usize = 0;
    for (pre) |ch| {
        if (post.len <= postIndex) {
            return error.uidiot;
        }
        if (!std.ascii.isWhitespace(ch)) {
            post[postIndex] = ch;
            postIndex += 1;
        }
    }
    return postIndex;
}
