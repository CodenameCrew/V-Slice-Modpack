// Took the one inside the BaseGame source as a base  - Nex
import funkin.backend.utils.AudioAnalyzer;
import Lambda;

var pupilState:Int = 0;

var PUPIL_STATE_NORMAL = 0;
var PUPIL_STATE_LEFT = 1;

var abot:FunkinSprite;
var stereoBG:FunkinSprite;
var eyeWhites:FunkinSprite;
var pupil:FunkinSprite;

var abotViz:FlxSpriteGroup;
var analyzer:AudioAnalyzer;
var analyzerLevelsCache:Array<Float>;
var analyzerTimeCache:Float;

var animationFinished:Bool = false;

function postCreate() {
	stereoBG = new FunkinSprite(0, 0, Paths.image('characters/abot/stereoBG'));
	eyeWhites = new FunkinSprite().makeSolid(160, 60);
	pupil = new FunkinSprite(0, 0, Paths.image("characters/abot/systemEyes"));
	abot = new FunkinSprite(0, 0, Paths.image('characters/abot/abotSystem'));

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
	var visFrms = Paths.loadFrames(Paths.image('characters/abot/aBotViz'));

	// these are the differences in X position, from left to right
	var positionX:Array<Float> = [0, 59, 56, 66, 54, 52, 51];
	var positionY:Array<Float> = [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

	for (lol in 1...8)
	{
		var sum = function(num:Float, total:Float) return total += num;
		var posX:Float = Lambda.fold(positionX.slice(0, lol), sum, 0);
		var posY:Float = Lambda.fold(positionY.slice(0, lol), sum, 0);

		var viz:FlxSprite = new FlxSprite(posX, posY);
		viz.frames = visFrms;
		abotViz.add(viz);

		viz.animation.addByPrefix('VIZ', 'viz' + lol, 0);
		viz.animation.play('VIZ', false, false, 6);
	}
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

function movePupilsLeft() {
	//pupil.stopAnimation();
	if (pupilState == PUPIL_STATE_LEFT) return;
	pupil.globalCurFrame = 17;

	pupil.playAnim('', true, null, false, 0);
}

function movePupilsRight() {
	//pupil.stopAnimation();
	if (pupilState == PUPIL_STATE_NORMAL) return;
	pupil.globalCurFrame = 31;
	pupil.playAnim('', true, null, false, 17);
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
	stereoBG.draw();
	abotViz.draw();
	eyeWhites.draw();
	pupil.draw();
	abot.draw();
}

function updateFFT() {
	if (analyzer != null && FlxG.sound.music.playing) {
		var time = FlxG.sound.music.time;
		if (analyzerTimeCache != time)
			analyzerLevelsCache = analyzer.getLevels(analyzerTimeCache = time, FlxG.sound.music.calcTransformVolume(), abotViz.group.members.length, analyzerLevelsCache, CoolUtil.getFPSRatio(0.4), -65, -10, 500, 20000);
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
	stereoBG.visible = eyeWhites.visible = pupil.visible = abot.visible = this.visible;
	stereoBG.antialiasing = eyeWhites.antialiasing = pupil.antialiasing = abot.antialiasing = this.antialiasing;
	stereoBG.scrollFactor = eyeWhites.scrollFactor = pupil.scrollFactor = abot.scrollFactor = this.scrollFactor;
	stereoBG.flipX = eyeWhites.flipX = pupil.flipX = abot.flipX = this.flipX;
	stereoBG.scale = pupil.scale = abot.scale = this.scale; eyeWhites.scale.set(this.scale.x * 160, this.scale.y * 60);
	abotViz.forEachAlive(function (spr) {
		spr.visible = this.visible;
		spr.antialiasing = this.antialiasing;
		spr.scrollFactor = this.scrollFactor;
		spr.flipX = this.flipX;
		spr.scale = this.scale;
	});

	if (!pupil.isAnimFinished())
	{
		switch (pupilState)
		{
			case PUPIL_STATE_NORMAL:
				if (pupil.globalCurFrame >= 17)
				{
					pupilState = PUPIL_STATE_LEFT;
					pupil.stopAnimation();
				}

			case PUPIL_STATE_LEFT:
				if (pupil.globalCurFrame >= 31)
				{
					pupilState = PUPIL_STATE_NORMAL;
					pupil.stopAnimation();
				}

		}
	}

	abot.update(elapsed);
	abot.setPosition(globalOffset.x + this.x - 100, globalOffset.y + this.y + 316);

	updateFFT();
	abotViz.update(elapsed);
	abotViz.setPosition(abot.x + 200, abot.y + 90);

	eyeWhites.update(elapsed);
	eyeWhites.setPosition(abot.x + 40, abot.y + 250);

	pupil.update(elapsed);
	pupil.setPosition(abot.x - 507, abot.y - 492);

	stereoBG.update(elapsed);
	stereoBG.setPosition(abot.x + 140, abot.y + 30);

	if (shouldTransitionState()) {
		transitionState();
	}
}

function onStartSong() {
	analyzer = new AudioAnalyzer(FlxG.sound.music, 256);
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

function destroy() {
	stereoBG.destroy();
	eyeWhites.destroy();
	pupil.destroy();
	abot.destroy();
	abotViz.destroy();
}