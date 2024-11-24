public var lightningStrike:Bool = true;
public var lightningStrikeBeat:Int = 0;
public var lightningOffset:Int = 8;
public var thunderSFXamount:Int = 2;

var rainShader:CustomShader;
var rainShaderTarget:FlxSprite;

function onPostStageCreation(_) for (strum in PlayState.SONG.strumLines) {
	var copy = strum?.characters.copy();
	for (char in copy) {
		var dark = char + "-dark";
		if (Assets.exists(Paths.xml("characters/" + dark)))
			strum.characters.insert(strum.characters.indexOf(char) + 1, dark);
	}
}

function getColorVec(color:Int):Array<Float> {
	return [
		(color >> 16 & 0xFF) / 255,
		(color >> 8 & 0xFF) / 255,
		(color & 0xFF) / 255
	];
}

function create() {
	for(i in 1...thunderSFXamount+1)
		FlxG.sound.load(Paths.sound('thunder_' + Std.string(i)));

	for (strum in PlayState.SONG.strumLines) {
		var copy = strum?.characters.copy();
		for (char in copy) if (StringTools.endsWith(char, "-dark"))
			strum.characters.remove(char);
	}
}

function postCreate() {
	rainShader = new CustomShader('rainShaderSimple');
	rainShader.uCameraBounds = [0, 0, FlxG.width, FlxG.height];
	rainShader.uScale = FlxG.height / 200 * 2;
	rainShader.uIntensity = 0.4;
	rainShader.uSpriteMode = true;
	rainShader.uRainColor = getColorVec(0xff6680cc);

	rainShaderTarget = stage.getSprite('trees');
	rainShaderTarget.shader = rainShader;
	rainShaderTarget.animation.callback = onBranchFrame;
	onBranchFrame(null, 0, 0); // codename fix: addition to update the shader so 1 frame isnt weird
}

var time:Float = 0;
function update(elapsed) {
	time += elapsed;
	rainShader.uTime = time;
}

function onBranchFrame(name, frameNum, frameIndex) {
	var frame = rainShaderTarget.frame;
	rainShader.data.uFrameBounds.value = [frame.uv.x, frame.uv.y, frame.uv.width, frame.uv.height];
}

function onPlayerMiss(event)
	event.gfSadAnim = false;

function lightningStrikeShit():Void
{
	FlxG.sound.play(Paths.soundRandom('thunder_', 1, thunderSFXamount));

	for (bg in [bgLight, stairsLight])
	{
		bg.alpha = 1;

		new FlxTimer().start(0.06, function(_) {
			bg.alpha = 0;
		});

		new FlxTimer().start(0.12, function(_) {
			bg.alpha = 1;
			FlxTween.tween(bg, {alpha: 0}, 1.5);
		});
	}

	strumLines.forEachAlive(function(strum) for (char in strum.characters) {
		char.playAnim('scared', true, "SING"); // SING so that they dont get indefinitely looped
		if (StringTools.endsWith(char.curCharacter, "-dark")) {
			char.alpha = 0;

			new FlxTimer().start(0.06, function(_) {
				char.alpha = 1;
			});

			new FlxTimer().start(0.12, function(_) {
				char.alpha = 0;
				FlxTween.tween(char, {alpha: 1}, 1.5);
			});
		}
	});

	lightningStrikeBeat = curBeat;
	lightningOffset = FlxG.random.int(8, 24);
}

function beatHit(curBeat)
	if (lightningStrike && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		lightningStrikeShit();