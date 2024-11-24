import openfl.display.ShaderParameter;

// Took the one inside the BaseGame source as a base  - Nex
public var rainShader:ScriptableShader = null;

public var rainShaderStartIntensity:Float = 0.1;
public var rainShaderEndIntensity:Float = 0.2;

public var rainColor = 0xFF6680cc;

function getColorVec(color:Int):Array<Float> {
	return [
		(color >> 16 & 0xFF) / 255,
		(color >> 8 & 0xFF) / 255,
		(color & 0xFF) / 255
	];
}


function create()
{
	if(!Options.gameplayShaders)
	{
		disableScript();
		return;
	}

	//rainShader = new ScriptableShader(new CustomShader('rainShader'), 'rainShader');
	//add(rainShader);
	rainShader = new CustomShader('rainShaderSimple');
	rainShader.uRainColor = getColorVec(rainColor);

	// rainSndAmbience = FunkinSound.load(Paths.sound("rainAmbience", "weekend1"), true, false, true);
	// rainSndAmbience.volume = 0;
	// rainSndAmbience.play(false, FlxG.random.float(0, rainSndAmbience.length));

	camGame.addShader(rainShader);
	// puddleMap = Assets.getBitmapData(Paths.image("phillyStreets/puddle"));
	rainShader.uScale = FlxG.height / 200; // adjust this value so that the rain looks nice
	rainShader.uIntensity = rainShaderStartIntensity;
	rainShader.uTime = 0;
	//FlxG.console.registerObject("rainShader", rainShader);

	// camGame.addShader(new openfl.filters.BlurFilter(16,16));

	// set the shader input
	//rainShader.mask = frameBufferMan.getFrameBuffer("mask");
	//rainShader.lightMap = frameBufferMan.getFrameBuffer("lightmap");
}

/*function setupFrameBuffers()
{
	//frameBufferMan.createFrameBuffer("mask", 0xFF000000);
	//frameBufferMan.createFrameBuffer("lightmap", 0xFF000000);
}

var screen:FixedBitmapData;
function draw(_)
{
	//screen = grabScreen(false);
	//BitmapDataUtil.applyFilter(screen, blurFilter);
	//blurredScreen = screen;
}*/

var time:Float = 0;

function update(elapsed:Float)
{
	time += elapsed;

	var length = inst != null ? inst.length : 0.0;
	var songPos = FlxMath.bound(Conductor.songPosition, 0, length);
	rainShader.uIntensity = FlxMath.remapToRange(songPos, 0, length, rainShaderStartIntensity, rainShaderEndIntensity);
	rainShader.uTime = time;

	var camera = FlxG.camera;
	rainShader.uCameraBounds = [camera.viewLeft, camera.viewTop, camera.viewRight, camera.viewBottom];

	// if (rainSndAmbience != null) {
	// 	rainSndAmbience.volume = Math.min(0.3, remappedIntensityValue * 2);
	// }
}

function onGameOver(_)
{
	// Make it so the rain shader doesn't show over the game over screen
	if (rainShader != null) FlxG.camera.removeShader(rainShader);
}

/*function onStageNodeParsed(event)
{
	if (event.sprite is FunkinSprite && event.sprite.name == "puddle" && rainShader != null)
	{
		rainShader.puddleY = event.sprite.y + 80;
		rainShader.puddleScaleY = 0.3;
		//frameBufferMan.copySpriteTo("mask", event.sprite, 0xFFFFFF);
	}
	else
	{
		//frameBufferMan.copySpriteTo("mask", event.sprite, 0x000000);
	}
}

function addCharacter(character:BaseCharacter, charType:CharacterType)
{
	// add to the mask so that characters hide puddles
	// frameBufferMan.copySpriteTo("mask", character, 0x000000);
}

function destroy()
{
	// Fully stop ambiance.
	// if (rainSndAmbience != null) rainSndAmbience.stop();
}*/