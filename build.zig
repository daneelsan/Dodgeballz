const std = @import("std");

const page_size = 65536; // in bytes
// Initial and max memory must correspond to the memory size defined in script.js.
// TODO: This used to be 10 pages. Find out why this needs 17 pages.
const wasm_initial_memory = 17 * page_size;
const wasm_max_memory = wasm_initial_memory;

pub fn build(b: *std.build.Builder) void {

    const lib = b.addSharedLibrary(.{
        .name = "DodgeBallz",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
            .abi = .musl,
        },
        .optimize = .ReleaseSmall,
    });

    // https://github.com/ziglang/zig/issues/8633
    lib.global_base = 6560;
    lib.import_memory = true; // import linear memory from the environment
    lib.initial_memory = wasm_initial_memory; // initial size of the linear memory (1 page = 64kB)
    lib.max_memory = wasm_initial_memory; // maximum size of the linear memory

    // Pass options from the build script to the files being compiled. This is awesome!
    const lib_options = b.addOptions();
    lib.addOptions("build_options", lib_options);
    lib_options.addOption(usize, "memory_size", wasm_max_memory);

     // This declares intent for the library to be installed into the standard
     // location when the user invokes the "install" step (the default step when
     // running `zig build`).
     b.installArtifact(lib);
}
