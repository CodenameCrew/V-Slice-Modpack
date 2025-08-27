var game = GameOverSubstate.instance;

function create(){
    game.gameOverSong = "gameplay/gameover/gameOver-pico";
    game.gameOverSongBPM = 60;
    game.retrySFX = "gameplay/gameover/gameOverEnd-pico";
    game.lossSFXName = "gameplay/gameover/fnf_loss_sfx-pico-and-nene";
}

function postCreate() {
    Conductor.changeBPM(game.gameOverSongBPM);
}

function update()
    Conductor.changeBPM(game.gameOverSongBPM);
