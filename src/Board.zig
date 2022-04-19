const std = @import("std");
const assert = std.debug.assert;

const JS = @import("JS.zig");
const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

pos: Vector2D,
width: f32,
height: f32,
color: RGBColor,

const Self = @This();

pub fn init(width: f32, height: f32) Self {
    assert(0.0 <= width and 0.0 <= height);
    return .{
        .pos = Vector2D.init(0.0, 0.0),
        .color = RGBColor.init(255, 255, 255),
        .width = width,
        .height = height,
    };
}

// Useful for resetting the position of the player.
pub inline fn center(self: Self) Vector2D {
    return .{
        .x = self.pos.x + self.width / 2,
        .y = self.pos.y + self.height / 2,
    };
}

pub fn step(self: Self) void {
    JS.clearRectangle(self.pos, self.width, self.height);
    JS.drawRectangle(self.pos, self.width, self.height, self.color);
}

// Computes a random position (close to the board's margin) for a newly generated enemy.
pub fn getRandomPosition(self: Self, radius: f32) Vector2D {
    if (JS.random() < 0.5) {
        return .{
            .x = if (JS.random() < 0.5) (self.pos.x + radius) else (self.pos.x + self.width - radius),
            .y = JS.random() * (self.height - radius) + self.pos.y + radius,
        };
    } else {
        return .{
            .x = JS.random() * (self.width - radius) + self.pos.x + radius,
            .y = if (JS.random() < 0.5) (self.pos.y + radius) else (self.pos.y + self.height - radius),
        };
    }
}

pub fn isOutOfBoundary(self: Self, ball: Ball2D) bool {
    const x = ball.pos.x;
    const y = ball.pos.y;
    const radius = ball.radius;
    return ((x + radius < self.pos.x) or
        (x - radius > self.width + self.pos.x) or
        (y + radius < self.pos.y) or
        (y - radius > self.height + self.pos.y));
}
