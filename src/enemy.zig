const std = @import("std");
const assert = std.debug.assert;

const GameState = @import("GameState.zig");
const JS = @import("JS.zig");
const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

pub const Enemy = struct {
    ball: Ball2D,

    const Self = @This();

    pub fn init(pos: Vector2D, vel: Vector2D, radius: f32, color: RGBColor) Self {
        assert(0.0 <= radius);
        return .{
            .ball = Ball2D.init(pos, vel, radius, color),
        };
    }

    pub fn update(self: *Self) void {
        self.ball.pos.x += self.ball.vel.x;
        self.ball.pos.y += self.ball.vel.y;
    }

    pub fn draw(self: Self) void {
        JS.drawBall2D(self.ball);
    }
};

// Enemies can only be one of these 5 colors.
const enemy_colors: [5]RGBColor = .{
    RGBColor.init(0x8E, 0xCA, 0xE6),
    RGBColor.init(0x21, 0x9E, 0xBC),
    RGBColor.init(0xE6, 0x39, 0x46),
    RGBColor.init(0xFF, 0xB7, 0x03),
    RGBColor.init(0xFB, 0x85, 0x00),
};

pub const EnemyArrayList = struct {
    array_list: std.ArrayListUnmanaged(Enemy),

    const max_count = 10;
    const min_radius = 10;
    const max_radius = 40;
    const initial_speed = 2;

    const Self = @This();

    pub fn init() Self {
        return .{
            .array_list = std.ArrayListUnmanaged(Enemy){},
        };
    }

    pub fn reset(self: *Self, game_state: *GameState) void {
        self.array_list.clearAndFree(game_state.allocator);
    }

    pub inline fn count(self: Self) usize {
        return self.array_list.items.len;
    }

    pub inline fn delete(self: *Self, index: usize) void {
        _ = self.array_list.swapRemove(index);
    }

    pub inline fn push(self: *Self, game_state: *GameState, enemy: Enemy) void {
        self.array_list.append(game_state.allocator, enemy) catch unreachable;
    }

    pub fn spawn(self: *Self, game_state: *GameState) void {
        const board = game_state.board;
        const player = game_state.player;

        if (self.count() < max_count) {
            const radius = JS.random() * (max_radius - min_radius) + min_radius;
            const pos = board.getRandomPosition(radius);
            // New enemies will move towards the current position of the player.
            const vel = Vector2D.direction(player.ball.pos, pos).scalarMultiply(initial_speed);
            const color = enemy_colors[@as(usize, @intFromFloat(JS.random() * 5))];

            const enemy = Enemy.init(pos, vel, radius, color);
            self.push(game_state, enemy);
        }
    }

    pub fn step(self: *Self, game_state: *GameState) void {
        const board = game_state.board;
        var items = self.array_list.items;

        var i: usize = 0;
        while (i < self.count()) {
            var enemy = &items[i];
            const is_out = board.isOutOfBoundary(enemy.ball);
            if (is_out or enemy.ball.radius < min_radius) {
                if (!is_out) {
                    // Why would you give free points?.
                    game_state.updateScore();
                }
                // Don't update the index if we remove an item from the list, it still valid (see ArrayList.swapRemove).
                self.delete(i);
                continue;
            }
            i += 1;
        }

        for (items) |*enemy| {
            enemy.update();
            enemy.draw();
        }
    }
};
