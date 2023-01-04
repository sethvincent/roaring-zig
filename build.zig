const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    var lib = add(b, mode);
    lib.install();

    var main_tests = b.addTest("src/test.zig");
    main_tests.setBuildMode(mode);
    main_tests.linkLibrary(lib);
    main_tests.addIncludePath("croaring");

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    var example = b.addExecutable("example", "src/example.zig");
    example.setBuildMode(mode);
    example.linkLibrary(lib);
    example.addIncludePath("croaring");

    const run_example = example.run();
    run_example.step.dependOn(&example.step); // gotta build it first
    b.step("run-example", "Run the example").dependOn(&run_example.step);
}

/// Add Roaring Bitmaps to your build process
pub fn add(b: *Builder, mode: std.builtin.Mode) *std.build.LibExeObjStep {
    var lib = b.addStaticLibrary("roaring-zig", "src/roaring.zig");
    lib.setBuildMode(mode);
    lib.linkLibC();
    lib.addCSourceFile("croaring/roaring.c", &[_][]const u8{""});
    lib.addIncludePath("croaring");
    return lib;
}
