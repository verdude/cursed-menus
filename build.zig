const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
        .abi = .musl, // musl → fully-static libc
    });
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .linkage = .static, // <- replaces -static
        .strip = true, // <- replaces -s
    });

    exe.linkSystemLibrary("ncurses");
    exe.linkSystemLibrary("tinfo"); // terminfo .a

    exe.addLibraryPath(.{ .cwd_relative = "temp/musl/lib" });
    exe.linkSystemLibrary("ncursesw");
    exe.linkSystemLibrary("tinfo");

    b.installArtifact(exe);
}
