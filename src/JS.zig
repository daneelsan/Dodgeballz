const std = @import("std");
const utils = @import("utils.zig");

const Imports = struct {
    extern fn jsConsoleLogWrite(ptr: [*]const u8, len: usize) void;
    extern fn jsConsoleLogFlush() void;

    extern fn jsRandom() f32;

    extern fn jsClearRectangle(x: f32, y: f32, width: f32, height: f32) void;
    extern fn jsDrawCircle(x: f32, y: f32, radius: f32, r: u8, g: u8, b: u8, a: f32) void;
    extern fn jsDrawRectangle(x: f32, y: f32, width: f32, height: f32, r: u8, g: u8, b: u8, a: f32) void;
    extern fn jsUpdateScore(score: u32) void;
};

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

pub inline fn random() f32 {
    return Imports.jsRandom();
}

pub inline fn clearRectangle(pos: Vector2D, width: f32, height: f32) void {
    Imports.jsClearRectangle(pos.x, pos.y, width, height);
}

pub inline fn drawBall2D(ball: Ball2D) void {
    const p = ball.pos;
    const r = ball.radius;
    const c = ball.color;
    Imports.jsDrawCircle(p.x, p.y, r, c.r, c.g, c.b, c.a);
}

pub inline fn drawRectangle(pos: Vector2D, width: f32, height: f32, color: RGBColor) void {
    Imports.jsDrawRectangle(pos.x, pos.y, width, height, color.r, color.g, color.b, color.a);
}

pub inline fn updateScore(score: u32) void {
    Imports.jsUpdateScore(score);
}

pub const Console = struct {
    pub const Logger = struct {
        pub const Error = error{};
        pub const Writer = std.io.Writer(void, Error, write);

        fn write(_: void, bytes: []const u8) Error!usize {
            Imports.jsConsoleLogWrite(bytes.ptr, bytes.len);
            return bytes.len;
        }
    };

    const logger = Logger.Writer{ .context = {} };
    pub fn log(comptime format: []const u8, args: anytype) void {
        logger.print(format, args) catch return;
        Imports.jsConsoleLogFlush();
    }
};
