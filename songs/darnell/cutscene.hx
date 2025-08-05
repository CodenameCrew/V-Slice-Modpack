import funkin.game.cutscenes.VideoCutscene;
import funkin.backend.system.Flags;

var timers:Array<FlxTimer> = [];

var canSprite, blackThing:FunkinSprite;

var camera = FlxG.camera;

var music:FlxSound;

function create() {
    game.persistentDraw = false;
	openSubState(new VideoCutscene(Paths.file('songs/' + game.SONG.meta.name + '/cutscene.' + Flags.VIDEO_EXT), function(){
        game.persistentDraw = true;
        game.persistentUpdate = true;
        startInGameCut();
    }));  
}

function startInGameCut(){
    
    var darnellCamPos = game.dad.getCameraPosition();
    var picoCamPos = game.boyfriend.getCameraPosition();
    var neneCamPos = game.gf.getCameraPosition();

    var cutsceneDelay:Float = 2;

    game.camHUD.visible = false;
    this.exists = true;
    canSprite = new FunkinSprite(game.dad.x + 830, game.dad.y + 300);
	canSprite.loadSprite(Paths.image("characters/spraycanAtlas"));
	canSprite.animateAtlas.anim.addBySymbolIndices('Can Start', 'Can with Labels', [0,1,2,3,4,5,6,7], 24, false);
    canSprite.animateAtlas.anim.addBySymbolIndices('Can Knee', 'Can with Labels', [8,9,10,11,12,13,14,15,16,17,18], 24, false);
	canSprite.animateAtlas.anim.addBySymbolIndices('Can Shot', 'Can with Labels', [26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42], 24, false);
	canSprite.visible = false;
	FlxG.state.insert(game.members.indexOf(game.dad), canSprite);

    blackThing = new FunkinSprite(0,0).makeGraphic(4000,4000, FlxColor.BLACK);
    blackThing.alpha = 0.7;
    blackThing.visible = false;
    FlxG.state.insert(game.members.indexOf(game.gf), blackThing);

    //loading sounds there probably a better way to do this
    FlxG.sound.load(Paths.sound('pico/Darnell_Lighter'));
    FlxG.sound.load(Paths.sound('pico/Kick_Can_UP'));
    FlxG.sound.load(Paths.sound('pico/Kick_Can_FORWARD'));
    FlxG.sound.load(Paths.sound('pico/Gun_Prep'));
    FlxG.sound.load(Paths.sound('pico/Darnell_Lighter'));
    FlxG.sound.load(Paths.sound('pico/cutscene/darnell_laugh'));
    FlxG.sound.load(Paths.sound('pico/cutscene/nene_laugh'));
    for (i in 1...4) FlxG.sound.load(Paths.sound('pico/shot' + i));

    music = FlxG.sound.load(Paths.music('pico/darnellCanCutscene'));
	music.volume = 1;
	music.play();

    camera.flash(FlxColor.BLACK, 2.3);
    camera.followEnabled = false;
    camera.scroll.set(picoCamPos.x - 385, picoCamPos.y - 350);
    camera.zoom = 1.3;
    game.boyfriend.playAnim('intro1', true, "LOCK");

    // the timers :DDDDDD

    timer(cutsceneDelay, function(){
        FlxTween.tween(camera, {"scroll.x": darnellCamPos.x - 565, "scroll.y": darnellCamPos.y - 350, zoom: 0.66}, 2.5, {ease: FlxEase.quadInOut});
    });

    timer(cutsceneDelay + 3, function(){
        game.dad.playAnim('lightCan', true, "LOCK");
        FlxG.sound.play(Paths.sound('pico/Darnell_Lighter'));
    });

    timer(cutsceneDelay + 4, function(){
        game.boyfriend.playAnim('cock', true, "LOCK");
        FlxG.sound.play(Paths.sound('pico/Gun_Prep'));
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x + 80}, 0.4, {ease: FlxEase.backOut});
    });

    timer(cutsceneDelay + 4.4, function(){
        game.dad.playAnim('kickCan', true, "LOCK");
        FlxG.sound.play(Paths.sound('pico/Kick_Can_UP'));
        canSprite.visible = true;
        canSprite.playAnim('Can Start', true);
    });

    timer(cutsceneDelay + 4.8, function(){
        game.dad.playAnim('kneeCan', true);
        FlxG.sound.play(Paths.sound('pico/Kick_Can_FORWARD'));
        canSprite.playAnim('Can Knee', true);
    });

    timer(cutsceneDelay + 5.1, function(){
        game.boyfriend.playAnim('intro2', true);
        canSprite.playAnim('Can Shot', true);
	    FlxG.sound.play(Paths.soundRandom('pico/shot', 1, 4));
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x - 80}, 1, {ease: FlxEase.quadInOut});
        blackThing.visible = true;
        FlxTween.tween(blackThing, {alpha: 0}, 1.4);
    });

    timer(cutsceneDelay + 5.9, function(){
        game.dad.playAnim('laughCutscene', true);
        FlxG.sound.play(Paths.sound('pico/cutscene/darnell_laugh'), 0.6);
    });

    timer(cutsceneDelay + 6.2, function(){
        game.gf.playAnim('laughCutscene', true);
        FlxG.sound.play(Paths.sound('pico/cutscene/nene_laugh'), 0.6);
    });

    timer(cutsceneDelay + 8, function(){
        FlxTween.tween(camera, {"scroll.x": camera.scroll.x + 80, zoom: game.defaultCamZoom}, 2, {ease: FlxEase.sineInOut});
        game.camHUD.visible = true;
        camera.followEnabled = true;
        close();
    });
}

function timer(duration:Float, callBack:Void->Void) {
	timers.push(new FlxTimer().start(duration, function(timer) {
		timers.remove(timer);
		callBack();
	}));
}

function destroy() {
	game.camHUD.visible = true;
    camera.followEnabled = true;
    canSprite.destroy();
    blackThing.destroy();
    game.dad.playAnim('idle', true);
    if(game.boyfriend.animation.name != 'intro2') game.boyfriend.playAnim('idle', true);
    music.stop();
	for(timer in timers) timer.cancel();
}