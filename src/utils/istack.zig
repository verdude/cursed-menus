// index stack for in-object indices
const iStack = @This();

stack: std.ArrayList(u32),

pub fn init(alloc: std.mem.Allocator) iStack {
    return .{
        .stack = std.ArrayList(u32).init(alloc),
    };
}

pub fn push(self: *iStack, index: u32) void {
    return self.stack.append(index);
}

pub fn peek(self: *iStack) ?u32 {
    return self.stack.getLastOrNull();
}

pub fn pop(self: *iStack) ?u32 {
    return self.stack.pop();
}

pub fn deinit(self: *iStack) void {
    self.stack.deinit();
}

const std = @import("std");
