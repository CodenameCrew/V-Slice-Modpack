import flixel.addons.display.FlxPieDial.FlxPieDialShape;
import flixel.addons.display.FlxPieDial;
import hxvlc.flixel.FlxVideoSprite;

var daVideo:String = Paths.video("toyCommercial");

var video:FlxVideo;
var pie:FlxPieDial;

function create() {
	if (FlxG.sound.music != null) {
		FlxG.sound.music.destroy();
		FlxG.sound.music = null;
	}

	video = new FlxVideoSprite();
	video.load(daVideo);
	video.bitmap.onEndReached.add(endVideo);
	video.bitmap.onFormatSetup.add(() -> {
		video.setGraphicSize(FlxG.width, FlxG.height);
		video.updateHitbox();
		video.screenCenter();
	});
	video.antialiasing = true;
	add(video);

	pie = new FlxPieDial(0, 0, 40, FlxColor.WHITE, 45, FlxPieDialShape.CIRCLE, true, 20);
	pie.x = FlxG.width - (pie.width * 1.5);
	pie.y = FlxG.height - (pie.height * 1.5);
	pie.replaceColor(FlxColor.BLACK, FlxColor.TRANSPARENT);
	pie.amount = 0;
	pie.scale.x = pie.scale.y = 0.8;
	pie.antialiasing = true;
	add(pie);

	video.play();
}

var holdTimer:Float = 0;
var holdMax:Float = 1.5;

function update(elapsed:Float) {
	if (FlxG.keys.pressed.ANY) {
		holdTimer = Math.min(holdTimer + elapsed, holdMax);
		pie.scale.x = pie.scale.y = lerp(pie.scale.x, 1, 0.1);
	}
	else if (holdTimer > 0) {
		holdTimer = Math.max(lerp(holdTimer, -0.1, 0.1), 0);
		pie.scale.x = pie.scale.y = lerp(pie.scale.x, 0.8, 0.3);
	}

	pie.amount = Math.min(1, Math.max(0, (holdTimer / holdMax) * 1.025));
	pie.alpha = FlxMath.remapToRange(pie.amount, 0.025, 1, 0, 1);

	if (pie.amount >= 1) endVideo();
}

function destroy() {
	video.stop();
	video.destroy();
}

function endVideo() {
	if (FlxG.sound.music != null) {
		FlxG.sound.music.destroy();
		FlxG.sound.music = null;
	}

	video.stop();
	remove(video);

	FlxG.switchState(new TitleState());
}