const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const RGBColor = utils.RGBColor;
const Vector2D = utils.Vector2D;

extern fn jsRandom() f32;
extern fn jsClearRectangle(x: f32, y: f32, width: f32, height: f32) void;
extern fn jsDrawCircle(x: f32, y: f32, radius: f32, r: u8, g: u8, b: u8, a: f32) void;
extern fn jsDrawRectangle(x: f32, y: f32, width: f32, height: f32, r: u8, g: u8, b: u8, a: f32) void;

extern fn jsUpdateScore(score: u32) void;

// Lots of imported functions that log to console. See related comment in script.js.
extern fn jsConsoleLogu32(n: u32) void;
extern fn jsConsoleLogf32(n: f32) void;
extern fn jsConsoleLogbool(b: bool) void;
extern fn jsConsoleLogVector2D(x: f32, y: f32) void;

pub inline fn random() f32 {
    return jsRandom();
}

pub inline fn clearRectangle(pos: Vector2D, width: f32, height: f32) void {
    jsClearRectangle(pos.x, pos.y, width, height);
}

pub inline fn drawBall2D(ball: Ball2D) void {
    const p = ball.pos;
    const r = ball.radius;
    const c = ball.color;
    jsDrawCircle(p.x, p.y, r, c.r, c.g, c.b, c.a);
}

pub inline fn drawRectangle(pos: Vector2D, width: f32, height: f32, color: RGBColor) void {
    jsDrawRectangle(pos.x, pos.y, width, height, color.r, color.g, color.b, color.a);
}

pub inline fn updateScore(score: u32) void {
    jsUpdateScore(score);
}

// TODO: Write a wasm Writer.
pub fn consoleLog(comptime T: type, val: T) void {
    switch (T) {
        u32 => {
            jsConsoleLogu32(val);
        },
        f32 => {
            jsConsoleLogf32(val);
        },
        bool => {
            jsConsoleLogbool(val);
        },
        Vector2D => {
            jsConsoleLogVector2D(val.x, val.y);
        },
        else => {
            @compileError("consoleLog does not support the given type");
        },
    }
}
