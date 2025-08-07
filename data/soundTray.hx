//
import flixel.system.ui.FlxSoundTray;
import openfl.display.Bitmap;

var trueY:Float = 0;  // Since the Y gets changed on show()  - Nex
var lerpYPos:Float = 0;
var alphaTarget:Float = 0;

function postCreate() {
	FlxSoundTray.volumeDownChangeSFX = Paths.sound('menu/Voldown');
	FlxSoundTray.volumeUpChangeSFX = Paths.sound('menu/Volup');
	FlxSoundTray.volumeMaxChangeSFX = Paths.sound('menu/VolMAX');
	removeChild(text); text.__cleanup();

	var index:Int = getChildIndex(background);
	removeChild(background); background.bitmapData.dispose();
	addChildAt(background = new Bitmap(Assets.getBitmapData(Paths.image("soundTray/volumebox"))), index);
	_defaultScale = 0.6;
	screenCenter();
}

function postUpdate(elapsed:Float) {
	y = trueY = CoolUtil.fpsLerp(trueY, lerpYPos, 0.1);
	alpha = CoolUtil.fpsLerp(alpha, alphaTarget, 0.25);

	if (_timer > 0) alphaTarget = 1;
	else if (y >= -height) {
		lerpYPos = -height - 10;
		alphaTarget = 0;
	}
}

function postShow(_) {
	y = trueY;
	lerpYPos = 10;
}

function regenerateBars(event) {
	event.cancelled = true;

	@:bypassAccessor
	barsAmount = 10;
	regenerateBarsArray();

	var daX = 27;
	for (i in 0...barsAmount)
	{
		var bar:Bitmap;
		addChild(bar = new Bitmap(Assets.getBitmapData(Paths.image("soundTray/bar_" + (i + 1)))));
		bar.x = daX; bar.y = 75 - bar.height;
		daX += bar.width;
		_bars.push(bar);
	}
}