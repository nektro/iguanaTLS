const std = @import("std");
const Builder = std.Build;

pub fn build(b: *Builder) void {
    const mode = b.option(std.builtin.Mode, "mode", "") orelse .Debug;
    const target = b.standardTargetOptions(.{});
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    _ = b.addModule("iguanaTLS", .{
        .root_source_file = b.path("src/main.zig"),
    });

    const lib = b.addStaticLibrary(.{
        .name = "iguanaTLS",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = mode,
    });
    lib.use_llvm = !disable_llvm;
    lib.use_lld = !disable_llvm;
    b.installArtifact(lib);

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .optimize = mode,
    });
    main_tests.root_module.addImport("self/files", b.addModule("self/files", .{
        .root_source_file = b.path("files.zig"),
    }));
    main_tests.use_llvm = !disable_llvm;
    main_tests.use_lld = !disable_llvm;

    const test_step = b.step("test", "Run all library tests");
    const test_run = b.addRunArtifact(main_tests);
    test_step.dependOn(&test_run.step);
}
