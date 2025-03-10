const std = @import("std");
const assert = std.debug.assert;

const GameState = @import("GameState.zig");
const JS = @import("JS.zig");
const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

pub const Projectile = struct {
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

pub const ProjectileArrayList = struct {
    array_list: std.ArrayListUnmanaged(Projectile),

    const radius = 5.0;
    const color = RGBColor.init(255, 255, 255);

    const Self = @This();

    pub fn init() Self {
        return .{
            .array_list = std.ArrayListUnmanaged(Projectile){},
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

    pub inline fn push(self: *Self, game_state: *GameState, projectile: Projectile) void {
        self.array_list.append(game_state.allocator, projectile) catch unreachable;
    }

    pub fn emit(self: *Self, game_state: *GameState, client_pos: Vector2D) void {
        const player_ball = game_state.player.ball;

        // The projectile's direction depends on event.clientX and event.clientY coming from JS.
        const direction = Vector2D.displacement(client_pos, player_ball.pos).unitVector();

        const pos = player_ball.pos.vectorAdd(direction.scalarMultiply(player_ball.radius + radius));

        // The projectile's speed depends on the speed of the player at the current moment.
        const boost = player_ball.vel.magnitude() * 0.5;
        const vel = Vector2D.init(direction.x, direction.y).scalarMultiply(2 + boost);

        const projectile = Projectile.init(pos, vel, radius, color);
        self.push(game_state, projectile);
    }

    pub fn step(self: *Self, game_state: *GameState) void {
        const board = game_state.board;
        var items = self.array_list.items;

        var i: usize = 0;
        while (i < self.count()) {
            const projectile = &items[i];
            if (board.isOutOfBoundary(projectile.ball)) {
                // Don't update the index if we remove an item from the list, it still valid.
                self.delete(i);
                continue;
            }
            i += 1;
        }

        for (items) |*projectile| {
            projectile.update();
            projectile.draw();
        }
    }
};
