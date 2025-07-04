const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .strip = true, // <- replaces -s
    });

    exe.linkSystemLibrary("ncurses");
    exe.linkSystemLibrary("tinfo"); // terminfo .a

    exe.linkSystemLibrary("ncursesw");
    exe.linkSystemLibrary("tinfo");

    b.installArtifact(exe);
}
