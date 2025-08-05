import flixel.tweens.FlxTween.FlxTweenType;

function create() {
    CoolUtil.playMenuSong(true);
}

function postCreate() {
    titleText.shader = new CustomShader("colorSwap");
    titleText.shader.uTime = 0;

    titleScreenSprites.forEach(function(spr) {
        spr.shader = new CustomShader("colorSwap");
        spr.shader.uTime = 0;
    });

    if (FlxG.sound.music != null) FlxG.sound.music.onComplete = move2attract;
}

function move2attract() {
    FlxG.switchState(new ModState("AttractState"));
}

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.Y) {
        FlxTween.cancelTweensOf(window, ["x", "y"]);
        FlxTween.tween(window, {x: window.x + 300}, 1.4, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG, startDelay: 0.35});
        FlxTween.tween(window, {y: window.y + 100}, 0.7, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
    }

    if (controls.LEFT) updateColorSwapShader(-elapsed * 0.1);
    if (controls.RIGHT) updateColorSwapShader(elapsed * 0.1);
    if (!jingleActive && skippedIntro) jingleInput();
}

function updateColorSwapShader(elapsed:Float) {
    titleText.shader.uTime += elapsed;

    titleScreenSprites.forEach(function(spr) {
        spr.shader.uTime += elapsed;
    });
}

var jingleArray:Array<Int> = [0x0001, 0x0010, 0x0001, 0x0010, 0x0100, 0x1000, 0x0100, 0x1000];
var curJinglePos:Int = 0;
var jingleActive:Bool = false;

function jingleInput() {
    if (FlxG.keys.justPressed.Y) {
        FlxTween.cancelTweensOf(window, ["x", "y"]);
        FlxTween.tween(window, {x: window.x + 300}, 1.4, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG, startDelay: 0.35});
        FlxTween.tween(window, {y: window.y + 100}, 0.7, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
    }

    if (controls.NOTE_LEFT_P || controls.LEFT_P) jingleCode(0x0001);
    if (controls.NOTE_DOWN_P || controls.DOWN_P) jingleCode(0x1000);
    if (controls.NOTE_UP_P || controls.UP_P) jingleCode(0x0100);
    if (controls.NOTE_RIGHT_P || controls.RIGHT_P) jingleCode(0x0010);
}

function jingleCode(input:Int) {
    if (input == jingleArray[curJinglePos]) {
        curJinglePos += 1;
        if (curJinglePos >= jingleArray.length) startJingle();
    }
    else
        curJinglePos = 0;
}

function startJingle() {
    jingleActive = true;

    FlxG.sound.music.stop();
    CoolUtil.playMusic(Paths.music("girlfriendsRingtone"), false, 1, true, 160);
    FlxG.sound.music.fadeIn(4, 0, 1);

    FlxG.camera.flash(FlxColor.WHITE, 1);
    CoolUtil.playMenuSFX(1);
}

function beatHit(curBeat:Int) {
    if (skippedIntro && jingleActive && curBeat % 2 == 0) {
        updateColorSwapShader(0.125);
    }
}

function destroy() {
    if (jingleActive) {
        CoolUtil.playMenuSong();
    }
}