const std = @import("std");

const page_size = 65536; // in bytes
// initial and max memory must correspond to the memory size defined in script.js.
const wasm_initial_memory = 10 * page_size;
const wasm_max_memory = wasm_initial_memory;

pub fn build(b: *std.build.Builder) void {
    // Adds the option -Drelease=[bool] to create a release build, which we set to be ReleaseSmall by default.
    b.setPreferredReleaseMode(.ReleaseSmall);
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("game", "src/main.zig", .unversioned);
    lib.setBuildMode(mode);
    lib.setTarget(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .abi = .musl,
    });
    lib.setOutputDir(".");

    // https://github.com/ziglang/zig/issues/8633
    lib.import_memory = true; // import linear memory from the environment
    lib.initial_memory = wasm_initial_memory; // initial size of the linear memory (1 page = 64kB)
    lib.max_memory = wasm_initial_memory; // maximum size of the linear memory
    // lib.global_base = 6560; // offset in linear memory to place global data

    // Pass options from the build script to the files being compiled. This is awesome!
    const lib_options = b.addOptions();
    lib.addOptions("build_options", lib_options);
    lib_options.addOption(usize, "memory_size", wasm_max_memory);

    lib.install();

    const step = b.step("game", "Compiles src/main.zig");
    step.dependOn(&lib.step);
}
