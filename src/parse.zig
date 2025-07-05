const std = @import("std");
const ListView = @import("components/list_view.zig").ListView;

pub const ParseError = error{
    MissingField,
    InvalidType,
};


pub fn parseListViewFromString(allocator: std.mem.Allocator, json: []const u8) ParseError!ListView {
    var parser = std.json.Parser.init(allocator, false);
    defer parser.deinit();

    const value = try parser.parse(json);
    if (value.getType() != .object)
        return ParseError.InvalidType;
    return ListView.parse(allocator, value.object);
}

test "parse list view" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const json_text = \
        "{\\n" ++
        "  \"id\": 1,\\n" ++
        "  \"type\": \"list\",\\n" ++
        "  \"items\": [\\n" ++
        "    {\\n" ++
        "      \"id\": 2,\\n" ++
        "      \"type\": \"li\",\\n" ++
        "      \"content\": \"hello\"\\n" ++
        "    }\\n" ++
        "  ]\\n" ++
        "}\n";

    const lv = try parseListViewFromString(allocator, json_text);
    try std.testing.expectEqual(@as(u16, 1), lv.id);
    try std.testing.expectEqual(@as(usize, 1), lv.items.len);
    try std.testing.expectEqual(@as(u16, 2), lv.items[0].id);
    try std.testing.expect(std.mem.eql(u8, "hello", lv.items[0].content));
}
