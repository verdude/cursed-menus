pub const String = @This();

const std = @import("std");
const ParseError = @import("../parser.zig").ParseError;

id: u16,
content: []const u8,

pub fn parse(allocator: std.mem.Allocator, obj: std.json.ObjectMap) !String {
    _ = allocator;
    const id_value = obj.get("id") orelse return ParseError.MissingField;
    const content_value = obj.get("content") orelse return ParseError.MissingField;

    const id = @as(u16, @intCast(id_value.integer));
    const content_str = content_value.string;

    return String{ .id = id, .content = content_str };
}

pub fn match(char: u8, index: u8) bool {
    return "string"[index] == char;
}
