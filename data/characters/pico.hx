// Took the one inside the BaseGame source as a base  - Nex
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.effects.FlxFlicker;

var casingFrames = null;

function gamePostCreate() {
	animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (name == "cock" && frameNumber == 3) {
			createCasing();
		}
	}

	animation.finishCallback = (name:String) -> {
		if (name == 'shootMISS') {
			// ERIC: You have to use super instead of this or it breaks.
			// This is because typeof(this) is PolymodAbstractClass.

			// I FUCKING hate the flicker class, WHY DOES IT RELEASES AFTER AFTER THE FINALCALLBACK   - Nex
			FlxFlicker.flicker(this, 1, 1 / 30, true, true);
			new FlxTimer().start(1, function(_) {
				FlxFlicker.flicker(this, 0.5, 1 / 60, true, true);
			});
		}
	}

	// Precaching  - Nex
	var arr = PlayState.instance.SONG.noteTypes;
	if(arr.contains("cockgun")) {
		loadCasingFrames();
		FlxG.sound.load(Paths.sound('pico/Gun_Prep'));
	}
	if(arr.contains("firegun")) {
		FlxG.sound.load(Paths.sound('pico/Pico_Bonk'));
		for (i in 1...4) FlxG.sound.load(Paths.sound('pico/shot' + i));
	}
}

function loadCasingFrames() {
	casingFrames = Paths.getFrames('characters/picoStuff/PicoBullet');
}

function onGameOver(event) {
	if (event.character == this && event.deathCharID == 'pico-stabbed') {
		event.retrySFX = "pico/gameOverEnd";
		if(getAnimName() == "shootMISS") {
			event.deathCharID = "pico-explode";
			event.gameOverSong = "pico/gameOverStart-explode";
			event.lossSFX = "pico/fnf_loss_sfx-pico-explode";
		} else {
			event.gameOverSong = "pico/gameOver";
			event.lossSFX = "pico/fnf_loss_sfx-pico-gutpunch";
		}
	}
}

function onNoteHit(event)
{
	if (event.cancelled) {
		// onNoteHit event was cancelled by the gameplay module.  Its different on cne, but I get it, I'll leave this here if someone wants to do smth through mods  - Nex
		return;
	}

	if (event.character == this) {
		// Override the hit note animation.
		switch(event.noteType) {
			case "cockgun": // HE'S PULLING HIS COCK OUT
				event.animCancelled = true;
				playCockGunAnim();
			case "firegun":
				event.animCancelled = true;
				playFireGunAnim();
		}
	}
}

function onPlayerMiss(event)
{
	// Override the miss note animation.
	if(!event.cancelled && event.character == this) switch(event.noteType) {
		case "cockgun":
			//event.animCancelled = true;
			//playCockMissAnim();
		case "firegun":
			event.animCancelled = true;
			playCanExplodeAnim();
	}
}

var casingGroup:FlxTypedSpriteGroup;

/**
 * A sprite which represents a bullet flying through the air after Pico reloads.
 */
function createCasing() {
	if (casingGroup == null) {
		casingGroup = new FlxTypedSpriteGroup();
		casingGroup.x = this.x + this.globalOffset.x + 250;
		casingGroup.y = this.y + this.globalOffset.y + 100;

		var game = PlayState.instance;
		game.insert(game.members.indexOf(this), casingGroup);
	}

	if(casingFrames == null)
		loadCasingFrames();

	var casing = new FlxSprite();
	casing.frames = casingFrames;
	casing.antialiasing = this.antialiasing;
	casing.scale = this.scale;
	casing.scrollFactor = this.scrollFactor;

	// Active needs to be true to enable updates.
	// This includes velocity/acceleration and frame animations.
	casing.active = true;

	casing.animation.addByPrefix('pop', "Pop0", 24, false);
	casing.animation.addByPrefix('idle', "Bullet0", 24, true);
	casing.animation.play('pop');
	casing.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
		if (name == 'pop' && frameNumber == 40) {
			casing.animation.callback = null; // Save performance.

			// Get the end position of the bullet dynamically.
			casing.x += casing.frame.offset.x - 1;
			casing.y += casing.frame.offset.y + 1;

			casing.angle = 125.1; // Copied from FLA

			// Okay this is the neat part, we can set the velocity and angular acceleration to make it roll without editing update().
			var randomFactorA = FlxG.random.float(3, 10);
			var randomFactorB = FlxG.random.float(1.0, 2.0);
			casing.velocity.x = 20 * randomFactorB;
			casing.drag.x = randomFactorA * randomFactorB;

			casing.angularVelocity = 100;
			// Calculated to ensure angular acceleration is maintained through the whole roll.
			casing.angularDrag = (casing.drag.x / casing.velocity.x) * 100;

			casing.animation.play('idle');
		}
	};

	casingGroup.add(casing);
}

/**
 * Play the animation where Pico readies his gun to shoot the can.
 */
function playCockGunAnim() {
	this.playAnim('cock', true, "LOCK");
	FlxG.sound.play(Paths.sound('pico/Gun_Prep'));

	if(!visible || alpha == 0) return;
	var picoFade = new FlxSprite(this.x, this.y + this.globalOffset.y);
	picoFade.frames = this.frames;
	picoFade.frame = this.frame;
	picoFade.updateHitbox();
	// picoFade.stamp(this, 0, 0);
	picoFade.alpha = 0.3;
	FlxTween.tween(picoFade.scale, {x: 1.3, y: 1.3}, 0.4);
	FlxTween.tween(picoFade, {alpha: 0}, 0.4, {onComplete: function(_) picoFade.destroy()});

	var game = PlayState.instance;
	game.insert(game.members.indexOf(this), picoFade);
}
/**
 * Play the animation where Pico shoots the can successfully.
 */
function playFireGunAnim() {
	this.playAnim('shoot', true);
	FlxG.sound.play(Paths.soundRandom('pico/shot', 1, 4));
}
/**
 * Play the animation where Pico is hit by the exploding can.
 */
function playCanExplodeAnim() {
	this.playAnim('shootMISS', true);
	// Donk.
	FlxG.sound.play(Paths.sound('pico/Pico_Bonk'));
}