const std = @import("std");
const Allocator = std.mem.Allocator;

const Board = @import("Board.zig");
const EnemyArrayList = @import("enemy.zig").EnemyArrayList;
const Player = @import("Player.zig");
const ParticleArrayList = @import("particle.zig").ParticleArrayList;
const ProjectileArrayList = @import("projectile.zig").ProjectileArrayList;
const JS = @import("JS.zig");
const utils = @import("utils.zig");

const Ball2D = utils.Ball2D;
const Vector2D = utils.Vector2D;

game_over: bool = false,
score: u32 = 0,

allocator: Allocator,

board: Board,
player: Player,
enemies: EnemyArrayList,
projectiles: ProjectileArrayList,
particles: ParticleArrayList,

const Self = @This();

pub fn init(allocator: Allocator, board_width: f32, board_height: f32) Self {
    var board = Board.init(board_width, board_height);
    return .{
        .allocator = allocator,
        .board = board,
        .player = Player.init(board.center()),
        .enemies = EnemyArrayList.init(),
        .projectiles = ProjectileArrayList.init(),
        .particles = ParticleArrayList.init(),
    };
}

pub fn deinit(self: Self) void {
    self.allocator.deinit();
}

pub fn reset(self: *Self) void {
    self.game_over = false;
    self.score = 0;
    self.player.reset(self);
    self.enemies.reset(self);
    self.projectiles.reset(self);
    self.particles.reset(self);
}

pub fn spawnEnemy(self: *Self) void {
    self.enemies.spawn(self);
}

pub fn shootProjectile(self: *Self, client_pos: Vector2D) void {
    self.projectiles.emit(self, client_pos);
}

pub fn handleCollisions(self: *Self) void {
    const player = self.player;

    for (self.enemies.array_list.items) |*enemy| {
        if (Ball2D.collision(player.ball, enemy.ball)) {
            // If some enemy touches the player, game over.
            self.game_over = true;
            return;
        }

        for (self.projectiles.array_list.items, 0..) |*projectile, p_i| {
            if (Ball2D.collision(projectile.ball, enemy.ball)) {
                // If a projectile and an enemy collide, we do 3 things:
                //    * Delete the projectile
                //    * Generate impact particles
                //    * reduce the radius of the enemy
                self.projectiles.delete(p_i);
                self.particles.generate(self, enemy, projectile);
                enemy.ball.radius *= 0.8;
            }
        }
    }
}

// This updates the score and callbacks the jsUpdateScore function coming from JS.
pub fn updateScore(self: *Self) void {
    // Score should probably depend on the enemy size.
    self.score += 100;
    JS.updateScore(self.score);
}

pub fn step(self: *Self) void {
    self.board.step();
    self.player.step(self);
    self.enemies.step(self);
    self.projectiles.step(self);
    self.particles.step(self);
    self.handleCollisions();
}
