const std = @import("std");
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const lib = @import("cursed_menus_lib");
const parser = lib.parser;

fn readStringFromStdin(buffer: []u8) ![]u8 {
    const stdin = std.io.getStdIn().reader();
    const read_bytes = try stdin.readUntilDelimiterOrEof(buffer, 0);
    return buffer[0..read_bytes.?.len];
}

pub fn main() !void {
    const len: u16 = 1024;
    var buf: [len]u8 = undefined;
    var buf2: [len]u8 = undefined;
    const input = try readStringFromStdin(&buf);
    //const reader = try SimpleReader.loadStdIn(&buf);
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{input});
    var fba = FixedBufferAllocator.init(&buf2);
    const alloc = fba.allocator();
    _ = try parser.fromString(alloc, &buf2);

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // Don't forget to flush!
}
