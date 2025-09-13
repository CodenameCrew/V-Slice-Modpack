// Took the one inside the BaseGame source as a base  - Nex
import funkin.backend.system.Flags;

function postCreate() {

	var game = GameOverSubstate.instance;

	game.retrySFX = 'pico/gameOverEnd-pixel-pico';
	game.lossSFXName = 'pico/fnf_loss_sfx-pixel-pico';
	game.gameOverSong = 'pico/gameOver-pixel-pico';
	game.gameOverSongBPM = 90;

	this.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (name == "firstDeath" && frameNumber == 49) {
			if(!game.isEnding) CoolUtil.playMusic(Paths.music(game.gameOverSong), false, 1, true, Flags.DEFAULT_BPM);
			playAnim("deathLoop", true, "DANCE");
		}
	}

	var gf = PlayState.instance.gf;
	if(gf.curCharacter != "nene-pixel") return;
	var deathSpriteNene = new FunkinSprite(0, 0, Paths.image("characters/nenePixelKnifeToss"));
	deathSpriteNene.x = gf.x + gf.globalOffset.x + 280;
	deathSpriteNene.y = gf.y + gf.globalOffset.y + 70;
	deathSpriteNene.scale.set(6,6);
	deathSpriteNene.antialiasing = false;
	deathSpriteNene.animation.addByPrefix('throw', "knifetosscolor0", 24, false);
	deathSpriteNene.animation.finishCallback = function(name:String) {
		deathSpriteNene.visible = false;
	}

	game.add(deathSpriteNene);
	deathSpriteNene.animation.play("throw");
}