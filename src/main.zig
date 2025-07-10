const std = @import("std");
const FixedBufferAllocator = std.heap.FixedBufferAllocator;
const parser = @import("parser.zig");
const logger = @import("log.zig").liblog;

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
    var fba = FixedBufferAllocator.init(&buf2);
    const alloc = fba.allocator();
    _ = try parser.fromString(alloc, input);
    logger.debug("oh christler", .{});
}
