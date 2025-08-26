import Date;
import funkin.savedata.FunkinSave;

var timers:Array<FlxTimer> = [];
var santaDies, dadShoots:FunkinSprite;

function onSongEnd(e){
if(PlayState.instance.variation == 'erect'){
    e.cancel();

    var camera = FlxG.camera;

    camera.followEnabled = false;

    FlxG.sound.load(Paths.sound('cutscenes/bf/eggnog/santa_shot_n_falls'));
    FlxG.sound.load(Paths.sound('cutscenes/bf/eggnog/santa_emotion'));

    var originalSanta = stage.getSprite('santa');
    originalSanta.visible = false;
    dad.visible = false;

    santaDies = new FunkinSprite(-450, 500);
    santaDies.shader = originalSanta.shader;
	santaDies.antialiasing = true;
	santaDies.loadSprite(Paths.image('stages/mall/erect/santa_speaks_assets'));
	santaDies.animateAtlas.anim.addBySymbol("santa whole scene", "santa whole scene", 0, false);
    santaDies.playAnim("santa whole scene");
    insert(members.indexOf(originalSanta), santaDies);

    dadShoots = new FunkinSprite(dad.x - 619, dad.y + 403);
    dadShoots.shader = dad.shader;
	dadShoots.antialiasing = true;
	dadShoots.loadSprite(Paths.image('stages/mall/erect/parents_shoot_assets'));
	dadShoots.animateAtlas.anim.addBySymbol("parents whole scene", "parents whole scene", 0, false);
    dadShoots.playAnim("parents whole scene");
    insert(members.indexOf(dad), dadShoots);

    FlxG.sound.play(Paths.sound('cutscenes/bf/eggnog/santa_emotion'));

    endingSong = true;
    canPause = false;

    if (validScore) {
		#if !switch
			FunkinSave.setSongHighscore(SONG.meta.name, PlayState.instance.difficulty, PlayState.instance.variation, {
				score: songScore,
				misses: misses,
				accuracy: accuracy,
				hits: [],
				date: Date.now().toString()
			}, PlayState.instance.getSongChanges());
		#end
	}

    for (strumLine in strumLines.members) strumLine.vocals.stop();
	    inst.stop();
        vocals.stop();

    FlxTween.globalManager.clear();
    FlxTween.tween(camera, {"scroll.x": originalSanta.x + 100, "scroll.y": originalSanta.y}, 2.8, {ease: FlxEase.expoOut});
    FlxTween.tween(camera, {zoom: 0.73}, 2, {ease: FlxEase.quadInOut});

    timer(2.8, function(){
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x - 150, zoom: 0.79}, 9, {ease: FlxEase.quartInOut});
    });

    timer(11.375, function() {
        FlxG.sound.play(Paths.sound('cutscenes/bf/eggnog/santa_shot_n_falls'));
    });

    timer(12.83, function() {
        camGame.shake(0.005, 0.2);
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x + 10, "scroll.y": camera.scroll.y + 80}, 5, {ease: FlxEase.expoOut});
    });

    timer(15, function() {
        camHUD.fade(0xFF000000, 1, false, null, true);
    });

    timer(16, function() {
        camHUD.fade(0xFF000000, 0.5, true, null, true);
        startCutscene("end-", endCutscene, nextSong, false, false);
    });
}
}

function timer(duration:Float, callBack:Void->Void) {
	timers.push(new FlxTimer().start(duration, function(timer) {
		timers.remove(timer);
		callBack();
	}));
}