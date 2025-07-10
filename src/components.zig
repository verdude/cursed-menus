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
    return std.meta.stringToEnum(Component, val);
}

const std = @import("std");
