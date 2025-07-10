const std = @import("std");
const parser = @import("parser.zig");
const List = @import("components/list.zig");

export fn parse(bytes: [*]const u8, len: u32) void {
    const result = parser.fromString(std.heap.page_allocator, bytes[0..len]) catch null;
    if (result) |list| {
        std.log.debug("list: {?}", .{list});
    }
}

test "parse" {
    const str = "{\"id\":1}";
    parse(str, str.len);
}
