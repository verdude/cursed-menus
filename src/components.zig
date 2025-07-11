const List = @import("components/list.zig");
const String = @import("components/string.zig");

pub const ComponentType = enum {
    list,
    string,
    unknown,
};

pub const Unknown = struct {
    strings: []String,
    lists: []List,
};

pub const Component = union(ComponentType) {
    list: List,
    string: String,
    unknown: Unknown,
};

pub fn getComponent(val: []const u8) ?Component {
    const t = std.meta.stringToEnum(ComponentType, val);
    if (t == null) {
        return null;
    }
    return switch (t.?) {
        ComponentType.list => .{ .list = .{ .id = 0, .items = undefined } },
        ComponentType.string => .{ .string = .{ .id = 0, .content = undefined } },
        else => null,
    };
}

const std = @import("std");
