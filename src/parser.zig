const List = @import("components/list.zig");
const String = @import("components/string.zig");
const comps = @import("components.zig");
const Tokenizer = @import("parser/tokenizer.zig");
const logger = @import("log.zig").liblog;

pub const ParseError = error{
    MissingField,
    InvalidType,
    SyntaxError,
};

pub fn fromString(alloc: std.mem.Allocator, bytes: []const u8) !List {
    _ = alloc;
    var tokenizer = Tokenizer.init(bytes);
    const structure = try tokenizer.parse();
    logger.debug("structure: {?}", .{structure});

    return structure;
}

test "fromString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const json_fmt =
        \\ {{
        \\   "id": 1,
        \\   "type": {},
        \\   "items": [
        \\     {{
        \\       "id": 2,
        \\       "type": {},
        \\       "content": "hello"
        \\     }}
        \\   ]
        \\ }}
    ;

    var json_text: [1024]u8 = undefined;
    const slice = try std.fmt.bufPrint(
        &json_text,
        json_fmt,
        .{ comps.ComponentType.list, comps.ComponentType.string },
    );

    const comp = try fromString(allocator, slice);
    try std.testing.expectEqual(@as(u16, 1), comp.id);
    try std.testing.expectEqual(@as(usize, 1), comp.items.len);
    try std.testing.expectEqual(@as(u16, 2), comp.items[0].id);
    try std.testing.expect(std.mem.eql(u8, "hello", comp.items[0].content));
}

const testing = std.testing;
const std = @import("std");
const json = std.json;
