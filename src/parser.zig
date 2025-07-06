const std = @import("std");
const List = @import("components/list.zig");
const json = std.json;

const testing = std.testing;

pub const Component = struct { id: u16 };

pub const ParseError = error{
    MissingField,
    InvalidType,
};

fn isJsonType(value: *const json.Value) bool {
    const obj = value.*.object;

    if (obj.get("computedValueType")) |cvt| {
        switch (cvt) {
            .object => |cvt_obj| {
                if (cvt_obj.get("type")) |type_val| {
                    return switch (type_val) {
                        .string => |s| std.mem.eql(u8, s, "json"),
                        else => false,
                    };
                }
            },
            else => {},
        }
    }
    return false;
}

pub fn fromString(alloc: std.mem.Allocator, bytes: []const u8) !List {
    const parsed = try json.parseFromSlice(json.Value, alloc, bytes, .{});
    defer parsed.deinit();

    const root = parsed.value;
    switch (root) {
        .object => {},
        else => return error.InvalidJson,
    }

    if (isJsonType(&root.object)) {
        return try List.parse(alloc, root.object);
    } else {
        return ParseError.InvalidType;
    }
}

test "fromString" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const json_text = "{\\n" ++
        "  \"pid\": d1d,\\n" ++
        "  \"type\": \"list\",\\n" ++
        "  \"items\": [\\n" ++
        "    {\\n" ++
        "      \"id\": 2,\\n" ++
        "      \"type\": \"li\",\\n" ++
        "      \"content\": \"hello\"\\n" ++
        "    }\\n" ++
        "  ]\\n" ++
        "}\n";

    const lv = try fromString(allocator, json_text);
    try std.testing.expectEqual(@as(u16, 1), lv.id);
    try std.testing.expectEqual(@as(usize, 1), lv.items.len);
    try std.testing.expectEqual(@as(u16, 2), lv.items[0].id);
    try std.testing.expect(std.mem.eql(u8, "hello", lv.items[0].content));
}
