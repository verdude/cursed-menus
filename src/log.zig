pub const std_options = .{
    .log_level = .debug,
};

pub const liblog = std.log.scoped(.cursed_menus);

const std = @import("std");
