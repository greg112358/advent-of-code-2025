const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    print("Running day ...\n", .{});

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const MAX_BYTES: usize = 100_000;
    // const file = try std.fs.cwd().readFileAlloc(allocator, "day3example.txt", MAX_BYTES);
    const file = try std.fs.cwd().readFileAlloc(allocator, "day3.txt", MAX_BYTES);

    defer allocator.free(file);
    const fileSize = file.len;
    std.debug.print("File Size: {} \n", .{fileSize});
    if (fileSize == MAX_BYTES) {
        unreachable;
    }

    var part1Answer: usize = 0;
    var part2Answer: usize = 0;
    var line: [200]u8 = [_]u8{0} ** 200;
    var index: usize = 0;
    const answerSize = 12;
    var answer: [answerSize]u8 = [_]u8{0} ** answerSize;
    for (file) |ch| {
        if (std.ascii.isWhitespace(ch)) {
            const lineSlice = line[0..index];
            //print("processing {s}\n", .{lineSlice});
            const localAnswer1 = answer[0..2];
            try processLine(lineSlice, 0, localAnswer1, 0, 2);
            print("answer for {s} part 1 is {s}\n", .{ lineSlice, localAnswer1 });
            const localAnswerInt: usize = try std.fmt.parseInt(usize, localAnswer1, 10);
            part1Answer += localAnswerInt;
            const localAnswer2 = answer[0..answer.len];
            try processLine(lineSlice, 0, localAnswer2, 0, answerSize);
            print("answer for {s} part 1 is {s}\n", .{ lineSlice, localAnswer2 });
            const localAnswerInt2: usize = try std.fmt.parseInt(usize, localAnswer2, 10);
            part2Answer += localAnswerInt2;
            index = 0;
        } else {
            line[index] = ch;
            index += 1;
        }
    }
    print("Answer for part 1: {}\nAnswer for part 2: {}\n Program exit.", .{ part1Answer, part2Answer });
}

//987654321111111
//811111111111119
//234234234234278
//818181911112111
fn processLine(line: []u8, searchIndex: usize, answer: []u8, digitIndex: usize, digitCnt: usize) !void {
    //print("line.len {}\n", .{line.len});
    const HOLYSENTINEL = 9999;
    var firstDigitIndex: usize = HOLYSENTINEL;
    var firstDigit: usize = 10;
    var firstDigitChar: u8 = 0;
    for (1..10) |inverseDigit| {
        // digit is 9 - 1
        const digit = 10 - inverseDigit;
        for (searchIndex..line.len - ((digitCnt - digitIndex) - 1)) |i| {
            firstDigit = try std.fmt.parseInt(usize, &.{line[i]}, 10);
            print("| {}, {}", .{ firstDigit, digit });
            if (firstDigit == digit) {
                firstDigitIndex = i;
                firstDigitChar = line[i];
                break;
            }
        }
        if (firstDigitIndex != HOLYSENTINEL) break;
    }
    answer[digitIndex] = firstDigitChar;
    print("\n\n", .{});
    if (digitCnt - 1 > digitIndex) try processLine(line, firstDigitIndex + 1, answer, digitIndex + 1, digitCnt);
    return;
}
