const text_decoder = new TextDecoder();
let console_log_buffer = "";

const startGameButton = document.getElementById("start-game-button");
const currentScoreElement = document.getElementById("current-score");
const finalScoreElement = document.getElementById("final-score");

const canvas = document.getElementById("game-canvas");
const context = canvas.getContext("2d");

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const gameOverContainer = document.getElementById("game-over-container-div");

/* utilities */

function colorToStyle(r, g, b, a) {
    return "rgb(" + r + ", " + g + ", " + b + ", " + a + ")";
}

/* WASM imported symbols */

function jsClearRectangle(x, y, width, height) {
    // context.clearRect(x, y, width, height);
    context.fillStyle = "rgba(0, 0, 0, .1)";
    context.fillRect(x, y, width, height);
}

function jsDrawCircle(x, y, radius, r, g, b, a) {
    context.beginPath();
    context.arc(x, y, radius, 0, Math.PI * 2);
    context.fillStyle = colorToStyle(r, g, b, a);
    context.fill();
}

function jsDrawRectangle(x, y, width, height, r, g, b, a) {
    context.beginPath();
    context.strokeRect(x, y, width, height);
    context.fillStyle = colorToStyle(r, g, b, a);
    context.lineWidth = 5;
    context.fill();
}

function jsUpdateScore(score) {
    currentScoreElement.innerHTML = score;
}

// See build.zig for reasoning
var memory = new WebAssembly.Memory({
    initial: 17 /* pages */,
    maximum: 17 /* pages */,
});

const wasm = {
    imports: {
        env: {
            jsRandom: function () {
                return Math.random();
            },
            jsClearRectangle: jsClearRectangle,
            jsDrawCircle: jsDrawCircle,
            jsDrawRectangle: jsDrawRectangle,
            jsUpdateScore: jsUpdateScore,

            jsConsoleLogWrite: function (ptr, len) {
                const str = text_decoder.decode(new Uint8Array(memory.buffer, ptr, len));
                console_log_buffer += str;
            },
            jsConsoleLogFlush: function () {
                console.log(console_log_buffer);
                console_log_buffer = "";
            },

            memory: memory,
        },
    },
    exports: {},
};

function loadGame() {
    WebAssembly.instantiateStreaming(fetch("zig-out/bin/DodgeBallz.wasm"), wasm.imports).then((result) => {
        wasm.exports = result.instance.exports;
        window.addEventListener("keydown", (event) => {
            const key = event.key;
            const char = key.charCodeAt(0);
            wasm.exports.key_down(char);
        });
        window.addEventListener("keyup", (event) => {
            const key = event.key;
            const char = key.charCodeAt(0);
            wasm.exports.key_up(char);
        });
        window.addEventListener("click", (event) => {
            const client_x = event.clientX;
            const client_y = event.clientY;
            wasm.exports.shoot_projectile(client_x, client_y);
        });
        startGameButton.addEventListener("click", (event) => {
            restartGame();
        });
        wasm.exports.game_init(canvas.width, canvas.height);
        restartGame();
        // gameOverContainer.style.display = "flex";
    });
}

function resetGame() {
    currentScoreElement.innerHTML = 0;
    gameOverContainer.style.display = "none";
    wasm.exports.game_reset();
}

function runGame() {
    wasm.exports.game_step();

    if (!wasm.exports.is_game_over()) {
        window.requestAnimationFrame(runGame);
    } else {
        // If the game is over, show the Game Over container (with the start buttong) and the achieved score.
        gameOverContainer.style.display = "flex";
        finalScoreElement.innerHTML = wasm.exports.get_score();
    }
}

function restartGame() {
    resetGame();
    // Set the rate at which the enemies will be spawned.
    setInterval(wasm.exports.spawn_enemy, 500);
    runGame();
}

function main() {
    loadGame();
}

main();
