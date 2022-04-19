const std = @import("std");
const math = std.math;
const assert = std.debug.assert;

pub const Vector2D = struct {
    x: f32,
    y: f32,

    const Self = @This();

    pub fn init(x: f32, y: f32) Self {
        return .{
            .x = x,
            .y = y,
        };
    }

    pub inline fn magnitude(self: Self) f32 {
        return math.sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn unitVector(self: Self) Self {
        const r = self.magnitude();
        return .{
            .x = self.x / r,
            .y = self.y / r,
        };
    }

    pub inline fn displacement(vf: Self, vi: Self) Self {
        return .{
            .x = vf.x - vi.x,
            .y = vf.y - vi.y,
        };
    }

    pub inline fn direction(vf: Self, vi: Self) Self {
        return vf.displacement(vi).unitVector();
    }

    pub inline fn distance(vf: Self, vi: Self) f32 {
        return vf.displacement(vi).magnitude();
    }

    pub fn scalarMultiply(self: Self, scalar: f32) Self {
        return .{
            .x = self.x * scalar,
            .y = self.y * scalar,
        };
    }

    pub fn vectorAdd(self: Self, vector: Self) Self {
        return .{
            .x = self.x + vector.x,
            .y = self.y + vector.y,
        };
    }
};

pub const RGBColor = struct {
    r: u8,
    g: u8,
    b: u8,
    a: f32 = 1.0,

    const Self = @This();

    pub fn init(r: u8, g: u8, b: u8) Self {
        return .{
            .r = r,
            .g = g,
            .b = b,
        };
    }

    pub fn setAlpha(self: *Self, a: f32) void {
        assert(0.0 <= a and a <= 1.0);
        self.a = a;
    }
};

pub const Ball2D = struct {
    pos: Vector2D,
    vel: Vector2D,
    radius: f32,
    color: RGBColor,

    const Self = @This();

    pub fn init(pos: Vector2D, vel: Vector2D, radius: f32, color: RGBColor) Self {
        assert(0.0 <= radius);
        return .{
            .pos = pos,
            .vel = vel,
            .radius = radius,
            .color = color,
        };
    }

    pub fn collision(ball1: Self, ball2: Self) bool {
        const distance = Vector2D.distance(ball1.pos, ball2.pos);
        return distance < (ball1.radius + ball2.radius);
    }
};
