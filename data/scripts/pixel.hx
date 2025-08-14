import openfl.display.BlendMode;

var daPixelZoom = PlayState.daPixelZoom;

function onNoteCreation(e) {
	e.cancel();

	var note = e.note, strumID = e.strumID;
	if (note.noteTypeID != 0) return;

	note.splash = "pixel-default";

	if (e.note.isSustainNote) {
		note.loadGraphic(Paths.image('stages/school/ui/arrowEnds'), true, 7, 6);
		var maxCol = Math.floor(note.graphic.width / 7);
		note.animation.add("hold", [strumID%maxCol]);
		note.animation.add("holdend", [maxCol + strumID%maxCol]);
	}
	else {
		note.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
		var maxCol = Math.floor(note.graphic.width / 17);
		note.animation.add("scroll", [maxCol + strumID%maxCol]);
	}
	var strumScale = note.strumLine.strumScale;
	note.scale.set(daPixelZoom * strumScale, daPixelZoom * strumScale);
	note.antialiasing = false;
}

function onStrumCreation(e) {
	e.cancel();

	var strum = e.strum;
	strum.loadGraphic(Paths.image('stages/school/ui/arrows-pixels'), true, 17, 17);
	var maxCol = Math.floor(strum.graphic.width / 17);
	var strumID = e.strumID % maxCol;

	strum.animation.add("static", [strumID]);
	strum.animation.add("pressed", [maxCol + strumID, (maxCol*2) + strumID], 12, false);
	strum.animation.add("confirm", [(maxCol*3) + strumID, (maxCol*4) + strumID], 24, false);

	var strumScale = strumLines.members[e.player].strumScale;
	strum.scale.set(daPixelZoom*strumScale, daPixelZoom*strumScale);
	strum.antialiasing = false;
}

function onCountdown(e) {
	if (e.soundPath != null) e.soundPath = 'pixel/' + e.soundPath;
	e.antialiasing = false;
	e.scale = daPixelZoom;
	e.spritePath = switch(e.swagCounter) {
		case 0: null;
		case 1: 'stages/school/ui/ready';
		case 2: 'stages/school/ui/set';
		case 3: 'stages/school/ui/go';
	};
}

function onNoteHit(e) {
	e.ratingPrefix = "stages/school/ui/";
	e.ratingScale = daPixelZoom * 0.7;
	e.ratingAntialiasing = false;

	e.numScale = daPixelZoom * 0.7;
	e.numAntialiasing = false;
}

function onPostNoteHit(e) for (splash in splashHandler) splash.blend = BlendMode.SCREEN;

var oldStageQuality = FlxG.game.stage.quality;
function postCreate() {
	PauseSubState.script = 'data/scripts/week6-pause';
	FlxG.game.stage.quality = 2;

	if (Options.week6PixelPerfect) {
		pixelizeCamera(camGame);
		//pixelizeCamera(camHUD);
	}

	gameOverSong = "pixel/gameOver";
	lossSFX = "pixel/gameOverSFX";
	retrySFX = "pixel/gameOverEnd";
}

function destroy() {
	FlxG.game.stage.quality = oldStageQuality;
}

var pixelShaders:Array<FunkinShader> = [];
var pixelCameras:Array<FlxCamera> = [];
public function pixelizeCamera(camera:FlxCamera) {
	camera.pixelPerfectRender = true;
	camera.antialiasing = false;

	var shader = new CustomShader('pixelZoomShader');
	camera.addShader(shader);

	pixelShaders.push(shader);
	pixelCameras.push(camera);
}

public function unpixelizeCamera(camera:FlxCamera) {
	camera.pixelPerfectRender = false;
	camera.antialiasing = true;

	var shader = pixelShaders[pixelCameras.indexOf(camera)];
	pixelShaders.remove(shader);
	pixelCameras.remove(camera);
	camera.removeShader(shader);
}

var i, camera, mult;
function postDraw() {
	i = pixelCameras.length;
	mult = 1 / daPixelZoom / Math.min(FlxG.scaleMode.scale.x, FlxG.scaleMode.scale.y);
	while (i-- > 0) {
		if ((camera = pixelCameras[i]) == null || !camera.exists) {
			unpixelizeCamera(camera);
			continue;
		}

		camera.setScale(mult, mult);
		pixelShaders[i].pixelZoom = mult / camera.getActualZoom();

		/*
		camera.setScale(mult * camera.zoomMultiplier, mult * camera.zoomMultiplier);
		pixelShaders[i].pixelZoom = mult / camera.zoom;
		*/
	}
}