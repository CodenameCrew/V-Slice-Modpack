// Took the one inside the BaseGame source as a base  - Nex
import funkin.backend.utils.AudioAnalyzer;
import Lambda;

var pupilState:Int = 0;

var PUPIL_STATE_NORMAL = 0;
var PUPIL_STATE_LEFT = 1;

var abot:FunkinSprite;
var abotBack:FunkinSprite;
var pupil:FunkinSprite;

var abotViz:FlxSpriteGroup;
var analyzer:AudioAnalyzer;
var analyzerLevelsCache:Array<Float>;
var analyzerTimeCache:Float;
importScript('data/scripts/dropshadow-effect');

var animationFinished:Bool = false;
function postCreate() {
    abotSpeaker = new FunkinSprite(0, 0, Paths.image('characters/abotPixel/aBotPixelSpeaker'));
    abotSpeaker.scale.set(6, 6);
    abotSpeaker.origin.x = Math.round(abotSpeaker.origin.x);
    abotSpeaker.origin.y = Math.round(abotSpeaker.origin.y);
    abotSpeaker.antialiasing = false;
    abotSpeaker.x = this.x;
    abotSpeaker.y = this.y;
	//abotSpeaker.ds_applyShader();
    abotSpeaker.animation.addByPrefix('danceLeft', 'danceLeft', 24, false);
    abotSpeaker.animation.addByPrefix('danceRight', 'danceRight', 24, false);

	abotBack = new FunkinSprite(0, 0, Paths.image('characters/abotPixel/aBotPixelBack'));
    abotBack.scale.set(6.1, 6);
    abotBack.antialiasing = false;
    abotBack.x = this.x;
    abotBack.y = this.y;
	//	abot = new FunkinSprite(0, 0, Paths.image('characters/abot/abotSystem'));



    abot = new FunkinSprite(0,0,Paths.image('characters/abotPixel/aBotPixelBody'));
    abot.scale.set(6, 6);
    abot.origin.x = Math.round(abot.origin.x);
    abot.origin.y = Math.round(abot.origin.y);
    abot.antialiasing = false;
    abot.x = this.x;
    abot.y = this.y;
    abot.animation.addByPrefix('danceLeft', 'danceLeft', 24, false);
    abot.animation.addByPrefix('danceRight', 'danceRight', 24, false);
    abot.animation.addByPrefix('lowerKnife', 'return', 24, false);

	abotHead = new FunkinSprite(0, 0, Paths.image('characters/abotPixel/abotHead'));
    abotHead.scale.set(6, 6);
    abotHead.antialiasing = false;
    abotHead.animation.addByPrefix('toleft', 'toleft0', 24, false);
    abotHead.animation.addByPrefix('toright', 'toright0', 24, false);
    abotHead.animation.finishCallback = function(name:String):Void {
      if (name == 'toleft')
      {
        pupilState = PUPIL_STATE_LEFT;
      }

      if (name == 'toright')
      {
        pupilState = PUPIL_STATE_NORMAL;
      }
    }


	animation.finishCallback = function (name:String) {
		switch(currentState) {
			case STATE_RAISE:
				if (name == "raiseKnife") {
					animationFinished = true;
					transitionState();
				}
			case STATE_LOWER:
				if (name == "lowerKnife") {
					animationFinished = true;
					transitionState();
				}
			default:
				// Ignore.
		}
	}

	// The audio visualizer  - Nex
	abotViz = new FlxSpriteGroup();
	var visFrms = Paths.loadFrames(Paths.image('characters/abotPixel/aBotVizPixel'));
	var pixel = true;
	// these are the differences in X position, from left to right
    var positionX:Array<Float> = pixel ? [0, 7 * 6, 8 * 6, 9 * 6, 10 * 6, 6 * 6, 7 * 6] : [0, 59, 56, 66, 54, 52, 51];
    var positionY:Array<Float> = pixel ? [0, -2 * 6, -1 * 6, 0, 0, 1 * 6, 2 * 6] : [0, -8, -3.5, -0.4, 0.5, 4.7, 7];


	for (lol in 1...8)
	{
		var sum = function(num:Float, total:Float) return total += num;
		var posX:Float = Lambda.fold(positionX.slice(0, lol), sum, 0);
		var posY:Float = Lambda.fold(positionY.slice(0, lol), sum, 0);

		var viz:FlxSprite = new FlxSprite(posX, posY);
		viz.frames = visFrms;
		viz.antialiasing = false;
		viz.scale.set(6,6);
		abotViz.add(viz);

		viz.animation.addByPrefix('VIZ', 'viz' + lol, 0);
		viz.animation.play('VIZ', false, false, 6);
	}

	/*    abot.shader = noRimShader;
    abotBack.shader = noRimShader;
    abotHead.shader = noRimShader;
    abotViz.shader = noRimShader;
    abotSpeaker.shader = abotSpeakerShader;*/
	for(i in [abotHead, abotBack, abot]){
		var dropShadow = getDropShadow(i);
		dropShadow.setAdjustColor(-66, -10, 24, -23); // brightness, hue, contrast, saturation
		dropShadow.color = 0xFF52351d; // the color for your drop shadow
		dropShadow.angle = 90; // the angle for your drop shadow
		dropShadow.distance = 5; // the distance for your drop shadow
		dropShadow.threshold = 1; // the brightness for your drop shadow
		dropShadow.antialiasAmt = 0; // the amount of antialias for your drop shadow
		dropShadow.pixelPerfect = true; // whether the pixels are aligned perfectly
	}

	var abotSpeakerShader = getDropShadow(abotSpeaker);
	abotSpeakerShader.setAdjustColor(-66, -10, 24, -23); // brightness, hue, contrast, saturation
	abotSpeakerShader.altMaskImage = Paths.image('stages/school/erect/masks/aBotPixelSpeaker_mask');
	abotSpeakerShader.useAltMask = true;
	abotSpeakerShader.maskThreshold = 0;
	abotSpeakerShader.color = 0xFF52351d; // the color for your drop shadow
	abotSpeakerShader.angle = 90; // the angle for your drop shadow
	abotSpeakerShader.distance = 1; // the distance for your drop shadow
	abotSpeakerShader.threshold = 1; // the brightness for your drop shadow
	abotSpeakerShader.antialiasAmt = 0; // the amount of antialias for your drop shadow
	abotSpeakerShader.pixelPerfect = true; // whether the pixels are aligned perfectly
	abotSpeakerShader.attachedSprite = abotSpeaker;
    abotSpeaker.animation.onFrameChange.add(function() {
      abotSpeakerShader.updateFrameInfo(abotSpeaker.frame);
    });
	//for(i in abotViz) i.shader = abotHead.shader;
}

function gamePostCreate()
	checkForEyes(PlayState.instance.curCameraTarget);

/**
 * At this amount of life, Nene will raise her knife.
 */
var VULTURE_THRESHOLD = 0.25 * 2;

/**
 * Nene is in her default state. 'danceLeft' or 'danceRight' may be playing right now,
 * or maybe her 'combo' or 'drop' animations are active.
 *
 * Transitions:
 * If player health <= VULTURE_THRESHOLD, transition to STATE_PRE_RAISE.
 */
var STATE_DEFAULT = 0;

/**
 * Nene has recognized the player is at low health,
 * but has to wait for the appropriate point in the animation to move on.
 *
 * Transitions:
 * If player health > VULTURE_THRESHOLD, transition back to STATE_DEFAULT without changing animation.
 * If current animation is combo or drop, transition when animation completes.
 * If current animation is danceLeft, wait until frame 14 to transition to STATE_RAISE.
 * If current animation is danceRight, wait until danceLeft starts.
 */
var STATE_PRE_RAISE = 1;

/**
 * Nene is raising her knife.
 * When moving to this state, immediately play the 'raiseKnife' animation.
 *
 * Transitions:
 * Once 'raiseKnife' animation completes, transition to STATE_READY.
 */
var STATE_RAISE = 2;

/**
 * Nene is holding her knife ready to strike.
 * During this state, hold the animation on the first frame, and play it at random intervals.
 * This makes the blink look less periodic.
 *
 * Transitions:
 * If the player runs out of health, move to the GameOverSubState. No transition needed.
 * If player health > VULTURE_THRESHOLD, transition to STATE_LOWER.
 */
var STATE_READY = 3;

/**
 * Nene is raising her knife.
 * When moving to this state, immediately play the 'lowerKnife' animation.
 *
 * Transitions:
 * Once 'lowerKnife' animation completes, transition to STATE_DEFAULT.
 */
var STATE_LOWER = 4;

/**
 * Nene's animations are tracked in a simple state machine.
 * Given the current state and an incoming event, the state changes.
 */
var currentState:Int = STATE_DEFAULT;

/**
 * Nene blinks every X beats, with X being randomly generated each time.
 * This keeps the animation from looking too periodic.
 */
var MIN_BLINK_DELAY:Int = 3;
var MAX_BLINK_DELAY:Int = 7;
var blinkCountdown:Int = MIN_BLINK_DELAY;

// Then, perform the appropriate animation for the current state.
function onDance(event) {
	//abot.playAnim("", forceRestart);

	if(currentState == STATE_PRE_RAISE && danced) {
		event.cancelled = animationFinished = true;
		transitionState();
	}
}

function onTryDance(event) {
	if (currentState == STATE_READY) {
		event.cancelled = true;
		if (blinkCountdown == 0) {
			playAnim('idleKnife', true, "DANCE");
			blinkCountdown = FlxG.random.int(MIN_BLINK_DELAY, MAX_BLINK_DELAY);
		} else {
			blinkCountdown--;
		}
	}
}

function checkForEyes(target:Int) {
	var bf = PlayState.instance.boyfriend; var dad = PlayState.instance.dad;
	if (target == 1 && (bf.x + bf.globalOffset.x) >= (dad.x + dad.globalOffset.x)) movePupilsRight();
	else movePupilsLeft();
}

function onEvent(e)
	if (PlayState.instance.strumLines != null && e.event.name == "Camera Movement") checkForEyes(e.event.params[0]);

function movePupilsLeft():Void
{
if (pupilState == PUPIL_STATE_LEFT) return;
// trace('Move pupils left');

abotHead.animation.play('toleft');
}

function movePupilsRight():Void
{
if (pupilState == PUPIL_STATE_NORMAL) return;
// trace('Move pupils right');

abotHead.animation.play('toright');
}

function moveByNoteKind(kind:String) {
	// Force ABot to look where the action is happening.
	switch(kind) {
		case "Light Can":
			movePupilsLeft();
		case "Cock Gun":
			movePupilsRight();
		default: // Nothing
	}
}

function onNoteHit(event) moveByNoteKind(event.noteType);
function onNoteMiss(event) moveByNoteKind(event.noteType);

function draw(_) {
	abotSpeaker.draw();
	abotBack.draw();
	abotViz.draw();
	abot.draw();
	abotHead.draw();
	//pupil.draw();
}

function updateFFT() {
	if (analyzer != null && FlxG.sound.music.playing) {
		var time = FlxG.sound.music.time;
		if (analyzerTimeCache != time)
			analyzerLevelsCache = analyzer.getLevels(analyzerTimeCache = time, 1, abotViz.group.members.length, analyzerLevelsCache, CoolUtil.getFPSRatio(0.2), -30, 0, 100, 24000);
	}
	else {
		if (analyzerLevelsCache == null) analyzerLevelsCache = [];
		analyzerLevelsCache.resize(abotViz.group.members.length);
		//for (i in 0...analyzerLevelsCache.length) analyzerLevelsCache[i] = 0;
	}

	for (i in 0...analyzerLevelsCache.length) {
		var animFrame:Int = CoolUtil.bound(Math.round(analyzerLevelsCache[i] * 6), 0, 6);
		if (abotViz.group.members[i].visible = animFrame > 0) {
			abotViz.group.members[i].animation.curAnim.curFrame = 5 - (animFrame - 1);
		}
	}
}

function update(elapsed) {
	abotBack.visible = abot.visible = abotHead.visible = this.visible;
	abotBack.antialiasing = abot.antialiasing = abotHead.antialiasing = false;
	abotBack.scrollFactor = abot.scrollFactor = abotHead.scrollFactor = this.scrollFactor;
	abotBack.flipX = abot.flipX = abotHead.flipX = this.flipX;
	abotBack.scale = abot.scale = abotHead.scale = this.scale;
	abotViz.forEachAlive(function (spr) {
		spr.visible = this.visible;
		spr.antialiasing = this.antialiasing;
		spr.scrollFactor = this.scrollFactor;
		spr.flipX = this.flipX;
		spr.scale = this.scale;
	});

	// if (!pupil.isAnimFinished())
	// {
	// 	switch (pupilState)
	// 	{
	// 		case PUPIL_STATE_NORMAL:
	// 			if (pupil.globalCurFrame >= 17)
	// 			{
	// 				pupilState = PUPIL_STATE_LEFT;
	// 				pupil.stopAnimation();
	// 			}

	// 		case PUPIL_STATE_LEFT:
	// 			if (pupil.globalCurFrame >= 31)
	// 			{
	// 				pupilState = PUPIL_STATE_NORMAL;
	// 				pupil.stopAnimation();
	// 			}

	// 	}
	// }

	abot.update(elapsed);
	abot.x = this.x + 296;
	abot.y = this.y + 430;
    abot.playAnim(PlayState.instance.gf.animation.curAnim.name);

	updateFFT();
	abotViz.update(elapsed);
	abotViz.x = abot.x - 160;
	abotViz.y = abot.y + 13;

	abotBack.update(elapsed);
	abotBack.x = abot.x - 55;
	abotBack.y = abot.y + 0;

	abotSpeaker.update(elapsed);
	abotSpeaker.x = abot.x - 78;
	abotSpeaker.y = abot.y + 9;
    abotSpeaker.playAnim(PlayState.instance.gf.animation.curAnim.name);

	abotHead.update(elapsed);
	abotHead.x = abot.x - 325;
	abotHead.y = abot.y + 72;

	if (shouldTransitionState()) {
		transitionState();
	}
}

function onStartSong() {
	analyzer = new AudioAnalyzer(FlxG.sound.music, 512);
}

function shouldTransitionState():Bool
	return PlayState.instance.boyfriend?.curCharacter != "pico-blazin";

function transitionState() {
	switch (currentState) {
		case STATE_DEFAULT:
			if (PlayState.instance.health <= VULTURE_THRESHOLD) {
				// trace('NENE: Health is low, transitioning to STATE_PRE_RAISE');
				currentState = STATE_PRE_RAISE;
			}
		case STATE_PRE_RAISE:
			if (PlayState.instance.health > VULTURE_THRESHOLD) {
				// trace('NENE: Health went back up, transitioning to STATE_DEFAULT');
				currentState = STATE_DEFAULT;
			} else if (animationFinished) {
				//trace('NENE: Animation finished, transitioning to STATE_RAISE');
				currentState = STATE_RAISE;
				playAnim('raiseKnife', true, "LOCK");
				animationFinished = false;
			}
		case STATE_RAISE:
			if (animationFinished) {
				// trace('NENE: Animation finished, transitioning to STATE_READY');
				currentState = STATE_READY;
				animationFinished = false;
			}
		case STATE_READY:
			if (PlayState.instance.health > VULTURE_THRESHOLD) {
				// trace('NENE: Health went back up, transitioning to STATE_LOWER');
				currentState = STATE_LOWER;
				playAnim('lowerKnife', true);
			}
		case STATE_LOWER:
			if (animationFinished) {
				// trace('NENE: Animation finished, transitioning to STATE_DEFAULT');
				currentState = STATE_DEFAULT;
				danced = !(animationFinished = false);
			}
		default:
			// trace('UKNOWN STATE ' + currentState);
			currentState = STATE_DEFAULT;
	}
}
