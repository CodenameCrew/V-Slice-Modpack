import flixel.tweens.FlxTween.FlxTweenType;
import flixel.FlxSubState;

var shader:FunkinShader;
var idleTimer:Float = 0;
var idleMaxTimer:Float = 120;

function create() CoolUtil.playMenuSong(true);

function postCreate() {
	shader = new CustomShader("colorSwap");
	shader.uTime = 0;

	titleText.shader = shader;
	titleScreenSprites.forEach((spr) -> spr.shader = shader);
}

function update(elapsed:Float) {
	if (controls.BACK) window.close();

	if (FlxG.keys.justPressed.Y) {
		FlxTween.cancelTweensOf(window, ["x", "y"]);
		FlxTween.tween(window, {x: window.x + 300}, 1.4, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG, startDelay: 0.35});
		FlxTween.tween(window, {y: window.y + 100}, 0.7, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
	}
	else if (FlxG.keys.justPressed.NINE) {
		move2attract();
		return;
	}

	if (controls.LEFT) updateColorSwapShader(-elapsed * 0.1);
	if (controls.RIGHT) updateColorSwapShader(elapsed * 0.1);

	if (!jingleActive && skippedIntro) {
		jingleInput();
		if (FlxG.keys.justPressed.ANY) idleTimer = 0;
		else if ((idleTimer += elapsed) > idleMaxTimer) move2attract();
	}
}

function updateColorSwapShader(change:Float) shader.uTime += change;

function move2attract() {
	// hacky cool ass transition fade
	persistentUpdate = false;
	persistentDraw = true;

	openSubState(new FlxSubState());
	FlxG.camera.fade(FlxColor.BLACK, 1, false, () -> FlxG.switchState(new ModState("AttractState")), true);
	FlxG.sound.music.fadeOut();
}

function beatHit(curBeat:Int) {
	if (jingleActive && curBeat % 2 == 0) updateColorSwapShader(0.125);
}

function destroy() {
	if (jingleActive) CoolUtil.playMenuSong();
}

var jingleArray:Array<Int> = [0x0001, 0x0010, 0x0001, 0x0010, 0x0100, 0x1000, 0x0100, 0x1000];
var curJinglePos:Int = 0;
var jingleActive:Bool = false;

function jingleInput() {
	if (controls.NOTE_LEFT_P || controls.LEFT_P) jingleCode(0x0001);
	if (controls.NOTE_DOWN_P || controls.DOWN_P) jingleCode(0x1000);
	if (controls.NOTE_UP_P || controls.UP_P) jingleCode(0x0100);
	if (controls.NOTE_RIGHT_P || controls.RIGHT_P) jingleCode(0x0010);
}

function jingleCode(input:Int) {
	if (input == jingleArray[curJinglePos]) {
		if ((++curJinglePos) >= jingleArray.length) startJingle();
	}
	else
		curJinglePos = 0;
}

function startJingle() {
	jingleActive = true;

	CoolUtil.playMusic(Paths.music("girlfriendsRingtone"), false, 0, true, 160);
	FlxG.sound.music.fadeIn(4, 0, 1);

	FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
	CoolUtil.playMenuSFX(1);
}