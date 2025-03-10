const std = @import("std");

// Initial and max memory must correspond to the memory size defined in script.js.
// TODO: This used to be 10 pages. Find out why this needs 17 pages.
const wasm_initial_memory = 17 * std.wasm.page_size;
const wasm_max_memory = wasm_initial_memory;

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });
    const exe = b.addExecutable(.{
        .name = "DodgeBallz",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = .ReleaseSmall,
    });
    exe.entry = .disabled;
    //exe.global_base = 6560;
    exe.rdynamic = true;
    exe.import_memory = true;
    exe.import_symbols = true;
    //exe.initial_memory = wasm_initial_memory; // initial size of the linear memory (1 page = 64kB)
    //exe.max_memory = wasm_initial_memory; // maximum size of the linear memory

    // https://github.com/ziglang/zig/issues/8633
    // lib.global_base = 6560;
    // lib.rdynamic = true;
    // lib.import_memory = true; // import linear memory from the environment
    // lib.initial_memory = wasm_initial_memory; // initial size of the linear memory (1 page = 64kB)
    // lib.max_memory = wasm_initial_memory; // maximum size of the linear memory

    // Pass options from the build script to the files being compiled. This is awesome!
    const exe_options = b.addOptions();
    exe_options.addOption(usize, "memory_size", wasm_max_memory);
    exe.root_module.addOptions("build_options", exe_options);

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(exe);
}
