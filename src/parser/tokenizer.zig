const Tokenizer = @This();

const List = @import("../components/list.zig");
const comps = @import("../components.zig");
const ComponentType = comps.ComponentType;
const Component = comps.Component;
const Unknown = comps.Unknown;
const ParseError = @import("../parser.zig").ParseError;
const logger = @import("../log.zig").liblog;

buf: []const u8,
index: u32,

const Value = union(enum) {
    comp: Component,
    string: []const u8,
};

const KV = struct {
    key: []const u8,
    val: Value,
};

const Tokens = enum(u8) {
    ocb = '{',
    ccb = '}',
    bs = '\\',
    com = ',',
    quo = '"',
    osb = '[',
    csb = ']',
    col = ':',
    sp = 0x20,
    tab = '\t',
    rc = '\r',
    _,
};

pub fn getJsonString(self: *Tokenizer) ![]const u8 {
    if (self.buf[self.index] != @intFromEnum(Tokens.quo)) {
        return error.ParserUnalignedExpectedQuote;
    }
    const start = self.index;
    self.findNext(.{ .token = Tokens.quo });
    return self.buf[start..self.index];
}

pub fn parseKeys(self: *Tokenizer, comp: *Component) !void {
    const key = try self.getJsonString();
    logger.debug("string key: [{s}]", .{key});
    self.index += 1;
    try self.seekValue();
    var value: Value = undefined;

    if (std.mem.eql(u8, key, "type")) {
        if (self.buf[self.index] != @intFromEnum(Tokens.quo)) {
            return ParseError.SyntaxError;
        }
        if (comps.getComponent(key)) |c| {
            comp.* = c;
        } else {
            return error.UnknownType;
        }
    } else {
        value = try self.parseValue();
    }
}

pub fn parse(self: *Tokenizer) !List {
    self.skipSpace();
    const c = self.buf[self.index - 1];
    self.index += 1;
    var comp = Component{
        .unknown = .{
            .strings = undefined,
            .lists = undefined,
        },
    };
    // intFromEnum for range case
    switch (c) {
        @intFromEnum(Tokens.ocb), @intFromEnum(Tokens.osb) => {
            try self.parseKeys(&comp);
        },
        @intFromEnum(Tokens.sp), @intFromEnum(Tokens.tab)...@intFromEnum(Tokens.rc) => {
            return ParseError.SyntaxError;
        },
        else => {
            logger.debug("other token {d}", .{self.buf[self.index]});
            return ParseError.SyntaxError;
        },
    }
}

const FindNextOpts = struct {
    token: Tokens,
    ignore_escaped: bool = false,
};

fn findNext(self: *Tokenizer, opts: FindNextOpts) void {
    self.index += 1;
    while (self.buf[self.index] != @intFromEnum(opts.token)) {
        if (self.buf[self.index] == @intFromEnum(Tokens.bs) and opts.ignore_escaped) {
            self.index += 1;
        }
        self.index += 1;
    }
}

fn skipSpace(self: *Tokenizer) void {
    while (std.ascii.isWhitespace(self.buf[self.index])) {
        self.index += 1;
    }
}

fn seekValue(self: *Tokenizer) !void {
    std.debug.assert(self.buf[self.index] == '"');
    self.skipSpace();
    if (self.buf[self.index] != @intFromEnum(Tokens.col)) {
        return ParseError.SyntaxError;
    }
    self.skipSpace();
}

fn parseValue(self: *Tokenizer) !Value {
    return switch (@as(Tokens, @enumFromInt(self.buf[self.index]))) {
        Tokens.ocb => Value{ .comp = try self.parse() },
        Tokens.osb => {},
        Tokens.quo => Value{ .string = try self.getJsonString() },
        else => ParseError.SyntaxError,
    };
}

pub fn init(bytes: []const u8) Tokenizer {
    return .{
        .buf = bytes,
        .index = 0,
    };
}

pub fn deinit(self: *Tokenizer) void {
    _ = self;
}

const std = @import("std");
