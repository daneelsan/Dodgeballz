const std = @import("std");
const assert = std.debug.assert;

const GameState = @import("GameState.zig");
const JS = @import("JS.zig");
const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

const Keyboard = struct {
    up: f32 = 0,
    down: f32 = 0,
    left: f32 = 0,
    right: f32 = 0,

    pub fn keyDown(self: *Keyboard, key: u8) void {
        switch (key) {
            'w' => self.up = -1,
            'a' => self.left = -1,
            's' => self.down = 1,
            'd' => self.right = 1,
            else => {},
        }
    }

    pub fn keyUp(self: *Keyboard, key: u8) void {
        switch (key) {
            'w' => self.up = 0,
            'a' => self.left = 0,
            's' => self.down = 0,
            'd' => self.right = 0,
            else => {},
        }
    }
};

ball: Ball2D,
keyboard: Keyboard = Keyboard{},

const initial_radius: f32 = 10.0;
const initial_velocity = Vector2D.init(0.0, 0.0);
const initial_color = RGBColor.init(255, 255, 255);
const speed: f32 = 5.0;

const Self = @This();

pub fn init(pos: Vector2D) Self {
    const ball = Ball2D.init(pos, initial_velocity, initial_radius, initial_color);
    return .{
        .ball = ball,
    };
}

pub fn reset(self: *Self, game_state: *GameState) void {
    // Default position is the center of the board.
    self.ball.pos = game_state.board.center();
    self.ball.vel = Vector2D.init(0.0, 0.0);
}

pub fn update(self: *Self, game_state: *GameState) void {
    const vel_x = speed * (self.keyboard.left + self.keyboard.right);
    const vel_y = speed * (self.keyboard.up + self.keyboard.down);

    const board = game_state.board;
    const pos = self.ball.pos;
    const radius = self.ball.radius;

    // Player can't move outside the bounding region of the board.
    self.ball.pos = Vector2D.init(
        std.math.clamp(pos.x + vel_x, board.pos.x + radius, board.pos.x + board.width - radius),
        std.math.clamp(pos.y + vel_y, board.pos.y + radius, board.pos.y + board.height - radius),
    );

    self.ball.vel = Vector2D.displacement(self.ball.pos, pos);
}

pub fn draw(self: Self) void {
    JS.drawBall2D(self.ball);
}

pub fn step(self: *Self, game_state: *GameState) void {
    self.update(game_state);
    self.draw();
}
