const std = @import("std");
const build_options = @import("build_options");

const GameState = @import("GameState.zig");
const utils = @import("utils.zig");

extern var memory: u8;

var fixed_buffer: std.heap.FixedBufferAllocator = undefined;
var game_state: GameState = undefined;

export fn game_init(board_width: f32, board_height: f32) void {
    // The imported memory is actually the value of the first element of the memory.
    // To use as an slice, we take the address of the first element and cast it into a slice of bytes.
    // We pass the memory size using build options (see build.zing).
    var memory_buffer_ptr: [*]u8 = @ptrCast(&memory);
    const memory_buffer = memory_buffer_ptr[0..build_options.memory_size];

    // When the upper bound of memory can be established, FixedBufferAllocator is a great choice.
    fixed_buffer = std.heap.FixedBufferAllocator.init(memory_buffer);
    const allocator = fixed_buffer.allocator();

    game_state = GameState.init(allocator, board_width, board_height);
}

export fn game_reset() void {
    game_state.reset();
}

export fn game_step() void {
    game_state.step();
}

export fn spawn_enemy() void {
    game_state.spawnEnemy();
}

export fn get_score() u32 {
    return game_state.score;
}

export fn is_game_over() bool {
    return game_state.game_over;
}

export fn key_down(key: u8) void {
    game_state.player.keyboard.keyDown(key);
}

export fn key_up(key: u8) void {
    game_state.player.keyboard.keyUp(key);
}

export fn shoot_projectile(client_x: f32, client_y: f32) void {
    game_state.shootProjectile(utils.Vector2D.init(client_x, client_y));
}
