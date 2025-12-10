const std = @import("std");
const print = std.debug.print;
const helper = @import("helper.zig");

pub fn main() !void {
    print("Running day 6 ...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 20_000;
    //const file = try std.fs.cwd().readFileAlloc(allocator, "day6example.txt", MAX_BYTES);
    const file = try std.fs.cwd().readFileAlloc(allocator, "day6.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});
    if (fileSize == MAX_BYTES) {
        unreachable;
    }

    const lines: [][]u8 = try helper.readLines(file, allocator);
    defer {
        for (lines) |line| {
            allocator.free(line);
        }
    }
    var listofnums: std.ArrayList(std.ArrayList(usize)) = .empty;
    var ops: std.ArrayList(u8) = .empty;
    defer ops.deinit(allocator);

    var numchars: [30]u8 = [_]u8{0} ** 30;
    var listofcharnums: std.ArrayList(std.ArrayList([]u8)) = .empty;
    //print("line cnt {d}\n", .{lines.len});
    for (lines, 0..lines.len) |line, lineNo| {
        var nums: std.ArrayList(usize) = .empty;
        var charnums: std.ArrayList([]u8) = .empty;
        var i: usize = 0;
        var ignoreWhitespace: bool = true;
        for (line, 0..line.len) |ch, j| {
            //print(" |{c}| ", .{ch});
            if (!std.ascii.isWhitespace(ch)) {
                numchars[i] = ch;
                i += 1;
                ignoreWhitespace = false;
            }

            if (!ignoreWhitespace and (j >= line.len - 1 or std.ascii.isWhitespace(ch))) {
                const slice = numchars[0..i];
                const newNumchars = try allocator.alloc(u8, i);
                //print("address: 0x{x}\n", .{@intFromPtr(&newNumchars)});
                @memcpy(newNumchars, slice);
                //print("for line: {s}  |  ", .{numchars});
                //print("lineNo: {d} \\ {d}, newNumchars: {s}, sizeof newNumchars: {d}\n", .{ lineNo, lines.len - 2, newNumchars, newNumchars.len });
                if (lineNo == lines.len - 1) {
                    const char: u8 = newNumchars[0];
                    try ops.append(allocator, char);
                    allocator.free(newNumchars);
                } else {
                    const num = std.fmt.parseInt(usize, newNumchars, 10) catch |err| {
                        print("CHAR: {c}\n", .{ch});
                        print("CHAR: {d}\n", .{ch});
                        print("i: {d}, j: {d}, lineNo: {d} \\ {d}, newNumchars: {s}, sizeof newNumchars: {d},newNumChars address: {d}\n", .{ i, j, lineNo, lines.len - 2, newNumchars, newNumchars.len, @intFromPtr(&newNumchars) });
                        //print("{s}\n", .{newNumchars});
                        print("{any}\n", .{err});
                        unreachable;
                    };
                    try nums.append(allocator, num);
                    //print("{any}", .{nums.items});
                    try charnums.append(allocator, newNumchars);
                    //            print("{any}\n", .{charnums});
                    //for (charnums.items) |*abc| {
                    //print("address for slice {s} : 0x{x}\n", .{ abc.*, @intFromPtr(abc) });
                    //}
                    //print("i: {d}, j: {d}, lineNo: {d} \\ {d}, newNumchars: {s}, sizeof newNumchars: {d},newNumChars address: 0x{x}\n", .{ i, j, lineNo, lines.len - 2, newNumchars, newNumchars.len, @intFromPtr(&newNumchars) });
                }
                ignoreWhitespace = true;
                i = 0;
            }
        }
        //print("lineNo: {d} \\ {d}\n", .{ lineNo, lines.len - 1 });
        //print("{any}\n", .{nums});
        //print("{any}\n", .{listofnums.items});
        if (lineNo < lines.len - 1) {
            try listofnums.append(allocator, nums);
            try listofcharnums.append(allocator, charnums);
        }
    }

    var part1Answer: usize = 0;
    //print("{s}\n", .{ops.items});
    //print("{}\n", .{listofnums.items.len});
    for (0..ops.items.len) |i| {
        //print("{d}\n", .{listofnums.items.len});
        var subanswer: usize = 0;
        for (listofnums.items, 0..listofnums.items.len) |operands, j| {
            //print("{d} {c}\n", .{ operands.items[i], ops.items[i] });
            if (j == 0 or ops.items[i] == '+') {
                subanswer = subanswer + operands.items[i];
            } else if (ops.items[i] == '*') {
                subanswer = subanswer * operands.items[i];
            } else {
                unreachable;
            }
        }
        part1Answer += subanswer;
    }

    //123 328  51 64
    // 45 64  387 23
    //  6 98  215 314
    //*   +   *   +
    //
    //623 +431+4
    //175 * 581 *32
    //8+248+369
    var col: usize = 0;
    var part2Answer: usize = 0;
    for (0..ops.items.len) |i| {
        const op: u8 = ops.items[i];
        var subAnswer: usize = 0;
        while (true) {
            var numbuf: [20]u8 = [_]u8{0} ** 20;
            var digit: usize = 0;
            var isAllSpaces = true;
            for (0..lines.len - 1) |j| {
                if (lines[j].len <= col) continue;
                const ch: u8 = lines[j][col];
                if (std.ascii.isDigit(ch)) {
                    numbuf[digit] = ch;
                    digit += 1;
                }
                isAllSpaces = isAllSpaces and std.ascii.isWhitespace(ch);
            }
            col += 1;
            if (isAllSpaces) break;
            const num: usize = try std.fmt.parseInt(usize, numbuf[0..digit], 10);
            //print("{d}\n", .{num});

            if (subAnswer == 0) {
                subAnswer += num;
            } else if (op == '+') {
                subAnswer += num;
            } else if (op == '*') {
                subAnswer *= num;
            } else {
                unreachable;
            }
        }
        part2Answer += subAnswer;
    }

    for (listofcharnums.items) |*charnums| {
        for (charnums.*.items) |*newNumchars| {
            allocator.free(newNumchars.*);
        }
        charnums.*.deinit(allocator);
    }
    listofcharnums.deinit(allocator);

    for (listofnums.items) |*nums| {
        nums.deinit(allocator);
    }
    listofnums.deinit(allocator);
    print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.\n\n", .{ part1Answer, part2Answer });
}
