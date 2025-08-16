// Took the one inside the BaseGame source as a base  - Nex
import funkin.backend.system.Flags;

function postCreate() {
	var game = GameOverSubstate.instance;
	this.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (name == "firstDeath" && frameNumber == 35) {
			if(!game.isEnding) CoolUtil.playMusic(Paths.music(game?.gameOverSong), false, 1, true, Flags.DEFAULT_BPM);
			// force the deathloop to play in here, since we are starting the music early it
			// doesn't check this in gameover substate !
			// also no animation suffix 🤔
			playAnim("deathLoop", true, "DANCE");
		}
	}

	var gf = PlayState.instance.gf;
	if(gf.curCharacter != "nene") return;
	var deathSpriteNene = new FunkinSprite(0, 0, Paths.image("characters/picoStuff/picoGameover/NeneKnifeToss"));
	deathSpriteNene.x = gf.x + gf.globalOffset.x + 280;
	deathSpriteNene.y = gf.y + gf.globalOffset.y + 70;
	deathSpriteNene.antialiasing = gf.antialiasing;
	deathSpriteNene.animation.addByPrefix('throw', "knife toss0", 24, false);
	deathSpriteNene.animation.finishCallback = function(name:String) {
		deathSpriteNene.visible = false;
	}

	game.add(deathSpriteNene);
	deathSpriteNene.animation.play("throw");
}