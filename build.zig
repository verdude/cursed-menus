const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
        .abi = .musl,
    });
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "cursed_menus",
        .root_module = lib_mod,
    });

    exe_mod.addImport("cursed_menus_lib", lib_mod);

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_module = exe_mod,
        .optimize = optimize,
        .link_libc = true,
        .linkage = .static,
        .strip = true,
    });

    lib.addLibraryPath(.{ .cwd_relative = "temp/musl/lib" });
    lib.linkSystemLibrary("ncursesw");
    lib.linkSystemLibrary("tinfow");

    b.installArtifact(lib);
    b.installArtifact(exe);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_exe_tests = b.addRunArtifact(exe_unit_tests);
    const run_lib_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(&run_lib_tests.step);
}
