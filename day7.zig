const std = @import("std");
const helper = @import("helper.zig");
const print = std.debug.print;

const Point = struct { x: usize, y: usize };
const Cnt = struct { part1: usize, part2: usize };

pub fn main() !void {
    print("Running day ...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 90_000;
    //const file = try std.fs.cwd().readFileAlloc(allocator, "day7eg2.txt", MAX_BYTES);
    //const file = try std.fs.cwd().readFileAlloc(allocator, "day7example.txt", MAX_BYTES);
    const file = try std.fs.cwd().readFileAlloc(allocator, "day7.txt", MAX_BYTES);

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
    var part1Answer: usize = 0;
    var part2Answer: usize = 0;
    for (0..lines.len) |i| {
        for (0..lines[i].len) |j| {
            if (lines[i][j] == 'S') {
                print("{d} {d}", .{ i, j });
                const answer: Cnt = doLaserThing(.{ .x = i, .y = j }, lines);
                part1Answer += answer.part1;
                part2Answer += answer.part2;
            }
        }
    }
    print("\n\n", .{});
    for (0..lines.len) |i| {
        for (0..lines[i].len) |j| {
            print("{c}", .{lines[i][j]});
        }
        print("\n", .{});
    }
    print("Answer for part 1 : {}\nAnswer for part 2 : {}\n Program exit.", .{ part1Answer, part2Answer });
}

//.......S.......
//.......1.......
//......1^4......
//......1.4......
//.....1^4^6.....
//.....1.4.6.....
//.....14^56.....
//.....14.56.....
//part2 should be 6
fn doLaserThing(point: Point, lines: [][]u8) Cnt {
    //print("{d} {d} {d} {d}",.{})
    var cnt: Cnt = .{ .part1 = 0, .part2 = 0 };
    if (point.x < lines.len - 1) {
        const nextChar: u8 = lines[point.x + 1][point.y];
        if (nextChar == '.' or nextChar == '|') {
            //if (nextChar == '.') {
            lines[point.x + 1][point.y] = '|';
            const subCnt: Cnt = doLaserThing(.{ .x = point.x + 1, .y = point.y }, lines);
            cnt.part1 += subCnt.part1;
            cnt.part2 += subCnt.part2;
            //}
        } else if (nextChar == '^' or nextChar == '&') {
            if (nextChar == '^') {
                lines[point.x + 1][point.y] = '&';
                cnt.part1 += 1;
                if (point.y != 0) {
                    lines[point.x + 1][point.y - 1] = '|';
                    const subCnt = doLaserThing(.{ .x = point.x, .y = point.y - 1 }, lines);
                    cnt.part1 += subCnt.part1;
                    cnt.part2 += subCnt.part2;
                }
                if (point.y != lines[point.x].len - 1) {
                    lines[point.x + 1][point.y + 1] = '|';
                    const subCnt = doLaserThing(.{ .x = point.x, .y = point.y + 1 }, lines);
                    cnt.part1 += subCnt.part1;
                    cnt.part2 += subCnt.part2;
                }
            }
        } else {
            print("HOLY MOLY {c}", .{nextChar});
            unreachable;
        }
    } else {
        cnt.part2 += 1;
    }
    return cnt;
}
