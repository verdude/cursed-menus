//const SimpleReader = @import("read_file.zig");
const std = @import("std");
const lib = @import("cursed_menus_lib");

fn readStringFromStdin(buffer: []u8) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const read_bytes = try stdin.readUntilDelimiterOrEof(buffer, 0);
    return buffer[0..read_bytes.?.len];
}

pub fn main() !void {
    var buf: [1024]u8 = undefined;
    const input = try readStringFromStdin(&buf);
    //const reader = try SimpleReader.loadStdIn(&buf);
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{input});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
