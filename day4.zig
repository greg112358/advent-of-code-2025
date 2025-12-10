const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Running day ...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 20_000;
    //const file = try std.fs.cwd().readFileAlloc(allocator, "day4example.txt", MAX_BYTES);
    const file = try std.fs.cwd().readFileAlloc(allocator, "day4.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});
    if (fileSize == MAX_BYTES) {
        unreachable;
    }
    var line: [200]u8 = [_]u8{0} ** 200;
    var lines: [200][]u8 = [_][]u8{&.{}} ** 200;
    var index: usize = 0;
    var lineNo: usize = 0;
    var part1Answer: usize = undefined;
    var part2Answer: usize = undefined;
    for (file) |ch| {
        if (std.ascii.isWhitespace(ch)) {
            const lineSlice = line[0..index];
            const newLine = try allocator.alloc(u8, index);
            @memcpy(newLine, lineSlice);
            lines[lineNo] = newLine;
            //print("processing {s}\n", .{newLine});
            //print("processing {s}\n", .{lines[lineNo]});
            lineNo += 1;
            index = 0;
        } else {
            line[index] = ch;
            index += 1;
        }
    }
    part1Answer = try calculatePart1(lines[0..lineNo]);
    part2Answer = try calculatePart2(lines[0..lineNo]);
    part2Answer = part1Answer + part2Answer;
    for (lines) |gridline| {
        defer allocator.free(gridline);
    }
    print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.", .{ part1Answer, part2Answer });
}

// ..@@.@@@@.
// @@@.@.@.@@
// @@@@@.@.@@
// @.@@@@..@.
// @@.@@@@.@@
// .@@@@@@@.@
// .@.@.@.@@@
// @.@@@.@@@@
// .@@@@@@@@.
// @.@.@@@.@.
// fewer than 4 roles = accessible
// how many accessible?
fn calculatePart1(grid: [][]u8) !usize {
    const Loc = struct { x: usize, y: usize };
    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var points: std.ArrayList(Loc) = .empty;
    defer points.deinit(allocator);
    var answer: usize = 0;
    for (0..grid[0].len) |i| {
        const line: []u8 = grid[i];
        //print("line: {s}\n", .{line});
        for (0..line.len) |j| {
            if (line[j] == '@') {
                var cnt: usize = 0;
                //tl
                if (i != 0 and j != 0) {
                    if (grid[i - 1][j - 1] == '@') {
                        cnt += 1;
                    }
                }
                //tc
                if (i != 0) {
                    if (grid[i - 1][j] == '@') {
                        cnt += 1;
                    }
                }
                //tr
                if (i != 0 and j != line.len - 1) {
                    if (grid[i - 1][j + 1] == '@') {
                        cnt += 1;
                    }
                }
                //l
                if (j != 0) {
                    if (grid[i][j - 1] == '@') {
                        cnt += 1;
                    }
                }
                //r
                if (j != line.len - 1) {
                    if (grid[i][j + 1] == '@') {
                        cnt += 1;
                    }
                }
                //bl
                if (i != line.len - 1 and j != 0) {
                    if (grid[i + 1][j - 1] == '@') {
                        cnt += 1;
                    }
                }
                //bc
                if (i != line.len - 1) {
                    if (grid[i + 1][j] == '@') {
                        cnt += 1;
                    }
                }
                //br
                if (i != line.len - 1 and j != line.len - 1) {
                    if (grid[i + 1][j + 1] == '@') {
                        cnt += 1;
                    }
                }
                if (cnt < 4) {
                    //print("{} {}\n", .{ i, j });
                    answer += 1;
                    const point: Loc = .{ .x = i, .y = j };
                    try points.append(allocator, point);
                    //print("{c}", .{'x'});
                }
                {
                    //print("{c}", .{line[j]});
                }
            } else {
                //print("{c}", .{line[j]});
            }
        }
        //print("\n", .{});
    }
    for (points.items) |point| {
        grid[point.x][point.y] = '.';
    }
    return answer;
}
fn calculatePart2(grid: [][]u8) !usize {
    var cnt: usize = 0;
    while (true) {
        const answer = try calculatePart1(grid);
        if (answer == 0) {
            break;
        }
        cnt += answer;
    }
    return cnt;
}
