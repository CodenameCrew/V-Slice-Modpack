import flixel.addons.display.FlxTiledSprite;
import funkin.backend.scripting.Script;
import openfl.display.ShaderParameter;

var scrollingSky:FlxTiledSprite;
var rainShader:ScriptableShader;

public var rainColor = 0xFF6680cc;

function getColorVec(color:Int):Array<Float> {
	return [
		(color >> 16 & 0xFF) / 255,
		(color >> 8 & 0xFF) / 255,
		(color & 0xFF) / 255
	];
}

function postCreate()
{
	skyAdditive.blend = 0;
	skyAdditive.visible = false;

	lightning.visible = false;

	foregroundMultiply.blend = 9;
	foregroundMultiply.visible = false;

	additionalLighten.blend = 0;
	additionalLighten.visible = false;

	scrollingSky = new FlxTiledSprite(Paths.image(stage.spritesParentFolder + 'skyBlur'), 4000, 495, true, false);
	scrollingSky.setPosition(-700, -120);
	scrollingSky.scrollFactor.set(0, 0);
	insert(0, scrollingSky);

	if(Options.gameplayShaders)
	{
		rainShader = new CustomShader('rainShaderSimple');
		rainShader.uRainColor = getColorVec(rainColor);
		camGame.addShader(rainShader);
		rainShader.uScale = FlxG.height / 200;
		rainShader.uIntensity = 0.5;
		rainShader.uTime = 0;
	}

	for(char in strumLines.members[0].characters)
		char.color = 0xFFDEDEDE;
	for(char in strumLines.members[1].characters)
		char.color = 0xFFDEDEDE;

	for(char in strumLines.members[2].characters)
	{
		gf.color = 0xFF888888;
		if(gf.scripts.get('abot') != null)
			gf.scripts.get('abot').color = 0xFF888888;
	}
}

var time:Float = 0;
var rainTimeScale:Float = 1.0;

var lightningTimer:Float = 3.0;
var lightningActive:Bool = true;

function update(elapsed:Float)
{
	camGame.snapToTarget();

	time += elapsed * rainTimeScale;
	if(rainShader != null)
	{
		rainShader.uCameraBounds = [camGame.viewLeft, camGame.viewTop, camGame.viewRight, camGame.viewBottom];
		rainShader.uTime = time;
	}
	rainTimeScale = smoothLerpPrecision(rainTimeScale, 0.02, elapsed, 1.535);

	if (scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 35;

	if (lightningActive)
	{
		lightningTimer -= FlxG.elapsed;
	}
	else
	{
		lightningTimer = 1;
	}

	if (lightningTimer <= 0)
	{
		applyLightning();
		lightningTimer = FlxG.random.float(7, 15);
	}
}

function applyLightning():Void
{
	var LIGHTNING_FULL_DURATION = 1.5;
	var LIGHTNING_FADE_DURATION = 0.3;

	skyAdditive.visible = true;
	skyAdditive.alpha = 0.7;
	FlxTween.tween(skyAdditive, {alpha: 0.0}, LIGHTNING_FULL_DURATION,
		{
			onComplete: cleanupLightning, // Make sure to call this only once!
		});

	foregroundMultiply.visible = true;
	foregroundMultiply.alpha = 0.64;
	FlxTween.tween(foregroundMultiply, {alpha: 0.0}, LIGHTNING_FULL_DURATION);

	additionalLighten.visible = true;
	additionalLighten.alpha = 0.3;
	FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

	lightning.visible = true;
	lightning.animation.play('idle');

	if (FlxG.random.bool(65))
	{
		lightning.x = FlxG.random.int(-250, 280);
	}
	else
	{
		lightning.x = FlxG.random.int(780, 900);
	}

	// Darken characters
	for(char in strumLines.members[0].characters)
		FlxTween.color(char, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);

	for(char in strumLines.members[1].characters)
		FlxTween.color(char, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);

	for(char in strumLines.members[2].characters)
		FlxTween.color(char, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);

	// Sound
	FlxG.sound.play(Paths.soundRandom('pico/Lightning', 1, 3), 1.0);
}

function onNoteHit(event)
{
	rainTimeScale += 0.7;
}

function smoothLerpPrecision(base:Float, target:Float, deltaTime:Float, duration:Float):Float
{
	if (deltaTime == 0) return base;
	if (base == target) return target;
	return lerp(target, base, Math.pow(1 / 100, deltaTime / duration));
}

function lerp(base:Float, target:Float, alpha:Float):Float
{
	if (alpha == 0) return base;
	if (alpha == 1) return target;
	return base + alpha * (target - base);
}

function onGameOver(event)
{
	if (rainShader != null) camGame.removeShader(rainShader);
}

function cleanupLightning(tween:FlxTween):Void
{
	skyAdditive.visible = false;
	foregroundMultiply.visible = false;
	additionalLighten.visible = false;
	lightning.visible = false;
}