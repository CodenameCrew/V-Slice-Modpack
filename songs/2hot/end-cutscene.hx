import hxvlc.flixel.FlxVideoSprite;
import funkin.backend.system.Flags;

var video:FlxVideoSprite;

var timers:Array<FlxTimer> = [];

var cutsceneCam:FlxCamera = new FlxCamera(0, 0, 0, 0);

function create() {
	FlxG.cameras.add(cutsceneCam, false);
    cutsceneCam.bgColor = 0x00000000;

	video = new FlxVideoSprite();
    video.load(Paths.file('songs/' + game.SONG.meta.name + '/end-cutscene.' + Flags.VIDEO_EXT));
	video.antialiasing = true;
	video.autoPause = false;
	video.visible = false;
	video.cameras = [cutsceneCam];
	video.bitmap.onEndReached.add(close);
	video.bitmap.onFormatSetup.add(function() if (video.bitmap != null && video.bitmap.bitmapData != null) {
		final width = video.bitmap.bitmapData.width;
		final height = video.bitmap.bitmapData.height;
		final scale:Float = Math.min(FlxG.width / width, FlxG.height / height);
		video.setGraphicSize(Std.int(width * scale), Std.int(height * scale));
		video.updateHitbox();
		video.screenCenter();
		startCut();
	});
    add(video);

	game.camHUD.visible = false;

    new FlxTimer().start(0.001, video.play);
}

function startCut(){

	timer(1, function(){
		camera.followEnabled = false;
		FlxTween.tween(camera, {"scroll.x": 899, "scroll.y": 483.5, zoom: 0.69}, 2, {ease: FlxEase.quadInOut});
	});

	timer(2, function(){
		game.boyfriend.playAnim('intro1', true, "LOCK");
	});
	
	timer(2.5, function(){
		game.dad.playAnim('pissed', true, "LOCK");
	});

	timer(5.5, function(){
		video.visible = true;
	});
}

function pauseCutscene()
	video.pause();

function onResumeCutscene()
	video.resume();

function timer(duration:Float, callBack:Void->Void) {
	timers.push(new FlxTimer().start(duration, function(timer) {
		timers.remove(timer);
		callBack();
	}));
}

function destroy() {
	video.destroy();
	camera.followEnabled = true;
	camera.zoom = game.defaultCamZoom;
	game.camHUD.visible = true;
}

function beatHit() {
	game.dad.dance();
	game.boyfriend.dance();
    game.gf.dance();
}