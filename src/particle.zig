const std = @import("std");
const assert = std.debug.assert;

const Enemy = @import("enemy.zig").Enemy;
const GameState = @import("GameState.zig");
const JS = @import("JS.zig");
const Projectile = @import("projectile.zig").Projectile;
const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

const Particle = struct {
    ball: Ball2D,

    const Self = @This();
    const friction = 0.99;

    pub fn init(pos: Vector2D, vel: Vector2D, radius: f32, color: RGBColor) Self {
        assert(0.0 <= radius);
        return .{
            .ball = Ball2D.init(pos, vel, radius, color),
        };
    }

    pub fn update(self: *Self) void {
        // Particles slow down as they move away from the impacted area.
        self.ball.vel.x *= friction;
        self.ball.vel.y *= friction;
        self.ball.pos.x += self.ball.vel.x;
        self.ball.pos.y += self.ball.vel.y;
        // Particles also become more transparent as they move away.
        // When the transparency reaches 0, the particle is removed (see below).
        self.ball.color.a -= 0.01;
    }

    pub fn draw(self: Self) void {
        JS.drawBall2D(self.ball);
    }
};

pub const ParticleArrayList = struct {
    array_list: std.ArrayListUnmanaged(Particle),

    const Self = @This();

    pub fn init() Self {
        return .{
            .array_list = std.ArrayListUnmanaged(Particle){},
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

    pub inline fn push(self: *Self, game_state: *GameState, particle: Particle) void {
        self.array_list.append(game_state.allocator, particle) catch unreachable;
    }

    pub fn generate(self: *Self, game_state: *GameState, enemy: *Enemy, projectile: *Projectile) void {
        const pos = projectile.ball.pos;

        var i: f32 = 0.0;
        // The size of the enemy determines how many particles will be produced.
        while (i < enemy.ball.radius) : (i += 1.0) {
            // The particle generated goes in a random direction.
            const vel = Vector2D.init(
                (JS.random() * 2 - 1) * (4 * JS.random()),
                (JS.random() * 2 - 1) * (4 * JS.random()),
            );
            const radius = JS.random() * 2;
            const particle = Particle.init(pos, vel, radius, enemy.ball.color);
            self.push(game_state, particle);
        }
    }

    pub fn step(self: *Self, game_state: *GameState) void {
        const board = game_state.board;
        var items = self.array_list.items;

        var i: usize = 0;
        while (i < self.count()) {
            var particle = &items[i];
            if (particle.ball.color.a <= 0.0 or board.isOutOfBoundary(particle.ball)) {
                // Don't update the index if we remove an item from the list, it still valid.
                self.delete(i);
                continue;
            }
            i += 1;
        }

        for (items) |*particle| {
            particle.update();
            particle.draw();
        }
    }
};
