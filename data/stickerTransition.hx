import flixel.util.FlxTimerManager;
import funkin.backend.MusicBeatTransition;
import haxe.io.Path;
import StickerPack;

public static var defaultStickerPackID:String = "default";

static var lastStickers:Array<{
	var stickerPath:String;
	var position:FlxPoint;
	var scale:FlxPoint;
	var angle:Float;
	var timing:Float;
	var showedInRegen:Bool;
}> = [];

var stickerPack:StickerPack = null;

var soundSelections:Array<String> = [];
var soundSelection:String = "";
var sounds:Array<String> = [];

var grpStickers:FlxGroup;
var timerManager:FlxTimerManager;

function create(event) {
	stickerPack = new StickerPack(PlayState.SONG.meta.customValues?.stickerPack ?? defaultStickerPackID);

	grpStickers = new FlxGroup();
	add(grpStickers);

	timerManager = new FlxTimerManager();
	add(timerManager);

	soundSelections = Paths.getFolderDirectories('sounds/stickersounds/', true);
	soundSelection = getRandomString(soundSelections);

	for (file in Paths.getFolderContent(soundSelection, true))
	{
		sounds.push(Path.withoutExtension(file.substring('sounds/'.length)));
	}

	if(event.transOut)
		regenStickers();
	else
		degenStickers();

	event.cancel();
}

function regenStickers()
{
	lastStickers = [];

	var xPos:Float = -100;
    var yPos:Float = -100;
	while(xPos <= FlxG.width)
	{
		var stickerPath:String = stickerPack.getRandomStickerPath(false);
		var sticky:FlxSprite = new FlxSprite(0, 0);
		CoolUtil.loadAnimatedGraphic(sticky, Paths.image(stickerPath));
		sticky.visible = false;

		sticky.x = xPos;
		sticky.y = yPos;
		sticky.antialiasing = true;
		xPos += sticky.frameWidth * 0.5;

		if (xPos >= FlxG.width)
		{
			if (yPos <= FlxG.height)
			{
				xPos = -100;
				yPos += FlxG.random.float(70, 120);
			}
		}

		sticky.angle = FlxG.random.int(-60, 70);
		grpStickers.add(sticky);

		lastStickers.push({
			stickerPath: stickerPath,
			position: FlxPoint.get(sticky.x, sticky.y),
			scale: FlxPoint.get(),
			angle: sticky.angle,
			timing: 0,
			showedInRegen: false
		});
	}

	grpStickers.members = shuffleStickers(grpStickers.members);

	var lastStickerPath:String = stickerPack.getRandomStickerPath(true);
    var lastSticker:FlxSprite = new FlxSprite(0, 0);
	CoolUtil.loadAnimatedGraphic(lastSticker, Paths.image(lastStickerPath));
    lastSticker.visible = false;
    lastSticker.updateHitbox();
    lastSticker.angle = 0;
    lastSticker.screenCenter();
    grpStickers.add(lastSticker);

	lastStickers.push({
		stickerPath: lastStickerPath,
		position: FlxPoint.get(lastSticker.x, lastSticker.y),
		scale: FlxPoint.get(),
		angle: 0,
		timing: 0,
		showedInRegen: false
	});

	for (ind => sticker in grpStickers.members)
	{
		lastStickers[ind].timing = FlxMath.remapToRange(ind, 0, grpStickers.members.length, 0, 0.9);

		new FlxTimer(timerManager).start(lastStickers[ind].timing, function(_) {
			sticker.visible = true;
			var daSound:String = getRandomString(sounds);
			FlxG.sound.play(Paths.sound(daSound));

			lastStickers[ind].showedInRegen = true;

			var frameTimer:Int = FlxG.random.int(0, 2);

			// always make the last one POP
			if (ind == grpStickers.members.length - 1) frameTimer = 2;

			new FlxTimer(timerManager).start((1 / 24) * frameTimer, function(_) {
				sticker.scale.x = sticker.scale.y = FlxG.random.float(0.97, 1.02);
				lastStickers[ind].scale.set(sticker.scale.x, sticker.scale.y);

				if (ind == grpStickers.members.length - 1)
				{
					finish();
				}
			});
		});
	}
}

function degenStickers()
{
	for(ind => prop in lastStickers)
	{
		var sticky:FlxSprite = new FlxSprite(prop.position.x, prop.position.y);
		CoolUtil.loadAnimatedGraphic(sticky, Paths.image(prop.stickerPath));
		sticky.updateHitbox();
		sticky.scale.set(prop.scale.x, prop.scale.y);
		sticky.antialiasing = true;
		sticky.angle = prop.angle;
		grpStickers.add(sticky);
	}

	for (ind => sticker in grpStickers.members)
    {
		new FlxTimer(timerManager).start(lastStickers[ind].timing, _ -> {
			sticker.visible = false;
			var daSound:String = getRandomString(sounds);
			FlxG.sound.play(Paths.sound(daSound));

			if (ind == grpStickers.members.length - 1)
			{
				finish();
			}
		});
    }
}

function onSkip(event)
{
	timerManager.clear();

	for(ind => prop in lastStickers)
	{
		if(!prop.showedInRegen)
			lastStickers.remove(prop);
	}
}

function onFinish(event)
{
	if(!this.transOut)
	{
		MusicBeatTransition.script = '';
	}
}

// functions below are stolen from FlxRandom, because they don't work normally!!

function shuffleStickers(array:Array<FlxSprite>)
{
	var maxValidIndex = array.length - 1;
	for (i in 0...maxValidIndex)
	{
		var j:Int = FlxG.random.int(i, maxValidIndex);
		var tmp:FlxSprite = array[i];
		array[i] = array[j];
		array[j] = tmp;

		// prop stuff
		var tmpProp = lastStickers[i];
		lastStickers[i] = lastStickers[j];
		lastStickers[j] = tmpProp;
	}

	return array;
}

// this one is condensed cuz we dont need all the weight stuff
function getRandomString(array:Array<String>)
{
	return array[FlxG.random.int(0, array.length - 1)];
}