if (PlayState.variation != 'erect') {
	function create() {
		game.camHUD.fade(0xFF000000, 0);

		var sound = FlxG.sound.load(Paths.sound('Lights_Shut_off'));
		sound.onComplete = function() {
			close();
		};
		sound.play();
	}

	return;
}

import funkin.savedata.FunkinSave;

var timers:Array<FlxTimer> = [];
var santaDies, dadShoots:FunkinSprite;

function create() {
	game.persistentUpdate = true;
    var camera = FlxG.camera;

    camera.followEnabled = false;

    var santa_shot_n_falls = FlxG.sound.load(Paths.sound('cutscenes/bf/eggnog/santa_shot_n_falls'));
    var santa_emotion = FlxG.sound.load(Paths.sound('cutscenes/bf/eggnog/santa_emotion'));

	var dad = game.dad;
    var originalSanta = game.stage.getSprite('santa');
    originalSanta.visible = false;
    dad.visible = false;

    santaDies = new FunkinSprite(-450, 500);
    santaDies.shader = originalSanta.shader;
	santaDies.antialiasing = true;
	santaDies.loadSprite(Paths.image('stages/mall/erect/santa_speaks_assets'));
	santaDies.animateAtlas.anim.addBySymbol("santa whole scene", "santa whole scene", 24, false);
    santaDies.playAnim("santa whole scene");
    game.insert(game.members.indexOf(originalSanta), santaDies);

    dadShoots = new FunkinSprite(dad.x - 619, dad.y + 403);
    dadShoots.shader = dad.shader;
	dadShoots.antialiasing = true;
	dadShoots.loadSprite(Paths.image('stages/mall/erect/parents_shoot_assets'));
	dadShoots.animateAtlas.anim.addBySymbol("parents whole scene", "parents whole scene", 24, false);
    dadShoots.playAnim("parents whole scene");
    game.insert(game.members.indexOf(dad), dadShoots);

    santa_emotion.play();

    FlxTween.globalManager.clear();
    FlxTween.tween(camera, {"scroll.x": originalSanta.x + 100, "scroll.y": originalSanta.y}, 2.8, {ease: FlxEase.expoOut});
    FlxTween.tween(camera, {zoom: 0.73}, 2, {ease: FlxEase.quadInOut});

    timer(2.8, function(){
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x - 150, zoom: 0.79}, 9, {ease: FlxEase.quartInOut});
    });

    timer(11.375, function() {
        santa_shot_n_falls.play();
    });

    timer(12.83, function() {
        game.camGame.shake(0.005, 0.2);
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x + 10, "scroll.y": camera.scroll.y + 80}, 5, {ease: FlxEase.expoOut});
    });

    timer(15, function() {
        game.camHUD.fade(0xFF000000, 1, false, null, true);
    });

    timer(16, function() {
        game.camHUD.fade(0xFF000000, 0.5, true, null, true);
        close();
    });
}

function timer(duration:Float, callBack:Void->Void) {
	timers.push(new FlxTimer().start(duration, function(timer) {
		timers.remove(timer);
		callBack();
	}));
}