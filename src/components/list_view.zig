const ListItem = @import("list_item.zig").ListItem;
const std = @import("std");
const ParseError = @import("../parse.zig").ParseError;

pub const ListView = struct {
    const IDB = @This();

    id: u16,
    items: []const ListItem,

    pub fn parse(allocator: std.mem.Allocator, obj: std.json.ObjectMap) ParseError!ListView {
        const id_value = obj.get("id") orelse return ParseError.MissingField;
        const items_value = obj.get("items") orelse return ParseError.MissingField;

        if (id_value.getType() != .integer)
            return ParseError.InvalidType;
        if (items_value.getType() != .array)
            return ParseError.InvalidType;

        const id = @as(u16, @intCast(id_value.integer));

        var items_list = std.ArrayList(ListItem).init(allocator);
        for (items_value.array.items) |item_val| {
            if (item_val.getType() != .object)
                return ParseError.InvalidType;
            const li = try ListItem.parse(allocator, item_val.object);
            try items_list.append(li);
        }
        const items = try items_list.toOwnedSlice();
        return ListView{ .id = id, .items = items };
    }
};
