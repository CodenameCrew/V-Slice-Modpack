import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import funkin.backend.system.FunkinSprite;
import flixel.addons.transition.FlxTransitionableState;

var camFront = new FlxCamera();
var scoreGroup = new FlxSpriteGroup();
var rank = 'shit';
var targetNum = 0;
function getRankTrueName() {
    if (rank == 'shit') return 'LOSS';
    return rank.toUpperCase();
}
function getFromNum(real) {
    var rankID = 'shit'; // loss
    if (real >= 69) rankID = 'good'; // good
    if (real >= 80) rankID = 'great'; // great
    if (real >= 90) rankID = 'excellent'; // excellent
    if (real >= 100) rankID = 'perfect'; // perfect
    return rankID;
}
var data = [
    'total' => 1000,
    'max' => 1000,

    'sick' => 1000,
    'good' => 0,
    'bad' => 0,
    'shit' => 0,
    'miss' => 0,

    'score' => 123456789,
    'accuracy' => 1.00 // 99%
];
function create() {
    if (FlxG.save.data.resultsShit != null) {
        var fuck = FlxG.save.data.resultsShit;

        for (name => value in fuck) {
            data[name] = value;
        }
    }
    trace(data);
    rank = getFromNum(targetNum = Std.int(data['accuracy'] * 100));
}

function getRankMusicName() {
    var na = getRankTrueName();
    return switch(na) {
        case 'GOOD' | 'GREAT': 'NORMAL';
        case 'EXCELLENT': 'EXCELLENT-intro';
        case 'PERFECT': 'PERFECT';
        default: 'SHIT-intro';
    }
}

function postCreate() {
    FlxG.camera.bgColor = 0xffFECC5C;
    FlxG.camera.width *= 1.25;
    FlxG.camera.height *= 1.25;
    FlxG.camera.setPosition((FlxG.width - FlxG.camera.width) * 0.5, 0);
    FlxG.camera.scroll.x = FlxG.camera.x;

    // backdrops and bitmap texts will not rotate with camera angle
    // for some reason so we have to go back to the caveman era
    FlxG.camera.rotateSprite = true;

    FlxG.camera.angle = -3.8;
    FlxG.cameras.add(camFront, false);
    camFront.bgColor = 0x00000000;

    scrollers = [];

    for (idx => i in [-1, 1]) {
        var img = Paths.image('results/rankText/rankScroll' + getRankTrueName());
        var shit = new FlxBackdrop(img);
        var pad = shit.height * 1.5;
        if (i == 1) shit.y = FlxMath.lerp(shit.height, pad, 0.5);
        shit.velocity.x = 0.5 * i;
        shit.spacing.y = pad;
        shit.visible = false;
        add(shit);
        scrollers[idx] = shit;
    }

    var fontLetters:String = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz:1234567890!?,.()-Ññ&\"'+[]/#";
    songDifficulty = new FlxSprite(567, -100);
    songDifficulty.loadGraphic(Paths.image('results/diff_' + (PlayState.difficulty != null ? PlayState.difficulty : 'hard')));
    songDifficulty.visible = true;
    add(songDifficulty);
    songName = new FlxBitmapText(567 + songDifficulty.width * 1.6, -100, 'bleh', FlxBitmapFont.fromMonospace(Paths.image('results/tardlingSpritesheet'), fontLetters, FlxPoint.get(49, 62)));
    songName.text = 'coño e su madre';
    songName.letterSpacing = -15;
    songName.antialiasing = true;
    add(songName);
    FlxTween.tween(songName, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});
    FlxTween.tween(songDifficulty, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});

    songName.text = 'example';

    if (PlayState.SONG != null) {
        songName.text = (PlayState.SONG.meta.displayName ?? 'Unknown') + ' by ' + (PlayState.SONG.meta.customValues?.artist ?? 'Unknown (edit this with custom song property named \'artist\' !!!)');
        if (PlayState.isStoryMode && PlayState.storyWeek != null) {
            songName.text = PlayState.storyWeek.name;
        }
    }

    clearBig = new ClearPercentCounter(800, 300);
    clearBig.cameras = [camFront];
    add(clearBig);
    clearBig.number = 0;
    clearBig.alpha = 0.001;

    var fuckkk = FlxG.sound.load(Paths.sound('menu/scroll'));
    FlxTween.tween(clearBig, {alpha: 1}, 0.4, {startDelay: 0.5, onComplete: () -> {
        FlxTween.num(0, targetNum - 0.5, 3, {ease: FlxEase.quartOut, onComplete: () -> {
            clearBig.number = targetNum - 1;
        }}, function(num) {
            if (clearBig.number != (clearBig.number = Std.int(num))) {
                fuckkk.play(true, 40);
            }
        });
    }});

    clearSmall = new ClearPercentCounter(songDifficulty.x + songDifficulty.width * 1, 125);
    clearSmall.big = false;
    add(clearSmall);
    clearSmall.number = Std.int(targetNum);
    clearSmall.alpha = 0.001;


    makefuckingidiot();

    var blehh = new FunkinSprite(-50).makeSolid(FlxG.width * 1.25, 400);
    blehh.color = 0;
    blehh.y = -490;
    blehh.skew.y = FlxG.camera.angle;
    blehh.antialiasing = true;
    blehh.cameras = [camFront];
    FlxTween.tween(blehh, {y: -300}, 7 / 24, {ease: FlxEase.quartOut, startDelay: 3 / 24});

    resultsAnim = new FlxSprite(-200, -10);
    resultsAnim.frames = Paths.getFrames('results/results');
    resultsAnim.animation.addByPrefix("result", "results instance 1", 24, false);
    resultsAnim.visible = false;
    new FlxTimer().start(6 / 24, _ -> {
        resultsAnim.visible = true;
        resultsAnim.animation.play("result");
    });
    resultsAnim.antialiasing = true;
    resultsAnim.cameras = [camFront];

    soundSystem = new FlxSprite(-15, -180);
    soundSystem.frames = Paths.getFrames('results/soundSystem');
    soundSystem.animation.addByPrefix("idle", "sound system", 24, false);
    soundSystem.visible = false;
    new FlxTimer().start(8 / 24, _ -> {
        soundSystem.animation.play("idle");
        soundSystem.visible = true;
    });
    add(soundSystem);
    soundSystem.antialiasing = true;
    soundSystem.cameras = [camFront];

    ratingsPopin = new FlxSprite(-135, 135);
    ratingsPopin.frames = Paths.getFrames('results/ratingsPopin');
    ratingsPopin.animation.addByPrefix("idle", "Categories", 24, false);
    ratingsPopin.visible = false;
    new FlxTimer().start(21 / 24, _ -> {
        ratingsPopin.animation.play("idle");
        ratingsPopin.visible = true;
    });
    add(ratingsPopin);
    ratingsPopin.antialiasing = true;
    ratingsPopin.cameras = [camFront];

    scorePopin = new FlxSprite(-180, 515);
    scorePopin.frames = Paths.getFrames('results/scorePopin');
    scorePopin.animation.addByPrefix("idle", "tally score", 24, false);
    scorePopin.visible = false;
    new FlxTimer().start(31 / 24, _ -> {
        scorePopin.animation.play("idle");
        scorePopin.visible = true;
    });
    add(scorePopin);
    scorePopin.antialiasing = true;
    scorePopin.cameras = [camFront];

    add(scoreGroup);
    scoreGroup.cameras = [camFront];

    for (i in 0...10) {
        var bleh = new ScoreGuy(i * 61, 0);
        bleh.ID = i;
        bleh.setNumber(-1);
        scoreGroup.add(bleh);
    }

    scoreGroup.setPosition(69, 605);

    for (index => i in [
        [375, 150, -1],
        [375, 200, -1],
        [230, 277, 0x89e59E],
        [210, 331, 0x89c9e5],
        [190, 385, 0xe6cf8a],
        [220, 439, 0xe68c8a],
        [260, 493, 0xc68ae6],
    ]) {
        var intendedNums = [
            data['total'], 
            data['max'],

            data['sick'],
            data['good'],
            data['bad'],
            data['shit'],
            data['miss']
        ];

        var tal = new TallyCounter(i[0], i[1]);
        tal.cameras = [camFront];
        add(tal);
        tal.number = 0;
        tal.color = i[2];
        tal.visible = false;

        new FlxTimer().start((0.3 * index) + 1.20, _ -> {
            tal.visible = true;
            FlxTween.num(0, intendedNums[index], 0.5, {ease: FlxEase.quartOut}, function(num) {
                tal.number = Std.int(num);
            });
        });
    }

    scoreGroup.visible = false;

    new FlxTimer().start(37 / 24, _ -> {
        scoreGroup.visible = true;

        var score = data['score'];
        var splitScore = Std.string(score).split('');
        for (i in 0...splitScore.length) {
            var index = i + (10 - splitScore.length);
            new FlxTimer().start(i / 24, () -> {
                scoreGroup.members[index].shuffle(Std.parseInt(splitScore[i]));
            });
        }
    });

    grahh = new FlxBackdrop(Paths.image('results/rankText/rankText' + getRankTrueName()), 0x10, 0, 30);
    add(grahh);
    grahh.antialiasing = true;
    grahh.cameras = [camFront];
    grahh.x = FlxG.width - grahh.width - 5;
    grahh.visible = false;

    add(blehh);
    add(resultsAnim);

    var trackID = getRankMusicName();

    if (trackID != 'PERFECT') {
        if (StringTools.contains(trackID, '-intro')) {
            FlxG.sound.playMusic(Paths.music('results' + trackID), 1, false);
            FlxG.sound.music.onComplete = () -> {
                FlxG.sound.playMusic(Paths.music('results' + StringTools.replace(trackID, '-intro', '')));
                FlxG.sound.music.onComplete = null;
            };
        } else {
            FlxG.sound.playMusic(Paths.music('results' + trackID), 1, true);
        }
    } else {
        FlxG.sound.playMusic(Paths.music('resultsPERFECT'), 0);
    }
}

function makefuckingidiot() {
    var defaultParams = {
        sheet: 'results/results-bf/resultsSHIT',
        is_atlas: true,
        anim: 'LOSS Animation',
        loop_frame: 149,
        coords: { x: 640, y: 380 },
        delay: (95 / 24)
    };

    var _params = [
        'shit' => defaultParams,
        'good' => {
            sheet: 'results/results-bf/resultsGOOD/resultBoyfriendGOOD',
            is_atlas: false,
            anim: 'Boyfriend Good Anim',
            loop_frame: 14,
            coords: { x: 640, y: -200 },
            delay: (95 / 24),
            extra_spr: {
                sheet: 'results/results-bf/resultsGOOD/resultGirlfriendGOOD',
                is_atlas: false,
                anim: 'Girlfriend Good Anim',
                loop_frame: 9,
                coords: { x: 625, y: 325 },   
                delay: (22 / 24)
            }
        },
        'great' => {
            sheet: 'results/results-bf/resultsGREAT/bf',
            is_atlas: true,
            anim: 'bf jumping ',
            loop_frame: 15,
            coords: { x: 929, y: 363 },
            delay: (95 / 24),
            scale: 0.93,
            extra_spr: {
                sheet: 'results/results-bf/resultsGREAT/gf',
                is_atlas: true,
                anim: 'gf jumping',
                loop_frame: 9,
                coords: { x: 802, y: 331 }, 
                delay: (6 / 24)
            }
        },
        'excellent' => {
            sheet: 'results/results-bf/resultsEXCELLENT',
            is_atlas: true,
            anim: 'bf results excellent',
            loop_frame: 28,
            coords: { x: 1329, y: 429 },
            delay: (97 / 24)
        },
        'perfect' => {
            sheet: 'results/results-bf/resultsPERFECT',
            is_atlas: true,
            anim: 'boyfriend perfect rank',
            loop_frame: 137,
            coords: { x: 1342, y: 370 },
            delay: (95 / 24),
            extra_spr: {
                sheet: 'results/results-bf/resultsPERFECT/hearts',
                is_atlas: true,
                anim: 'hearts full anim',
                loop_frame: 43,
                coords: { x: 1342, y: 370 }, 
                delay: (106 / 24),
                front: true
            }
        }
    ];

    var params = _params.get(rank) ?? defaultParams;

    var bf = new FunkinSprite(params.coords.x, params.coords.y);
    bf.cameras = [camFront];
    bf.antialiasing = true;
    bf.loadSprite(Paths.image(params.sheet));
    if (params.is_atlas) {
        bf.animateAtlas.anim.addBySymbol('anim', params.anim, 24, false);
        bf.animateAtlas.anim.addBySymbolIndices('loop', params.anim, [for (i in params.loop_frame...bf.animateAtlas.anim.length) i], 24, true);
    } else {
        bf.animation.addByPrefix('anim', params.anim, 24, false);
        bf.animation.play('anim', true);
        bf.animation.addByIndices('loop', params.anim, [for (i in params.loop_frame...bf.animation.numFrames) i], '', 24, true);
    }
    bf.visible = false;
    if (params.scale != null) {
        bf.scale.set(params.scale, params.scale);
    }

    var xtra = null;
    if (params?.extra_spr != null) {
        xtra = new FunkinSprite(params.extra_spr.coords.x, params.extra_spr.coords.y);
        xtra.cameras = [camFront];
        xtra.antialiasing = true;
        xtra.loadSprite(Paths.image(params.extra_spr.sheet));

        if (params.extra_spr.is_atlas) {
            xtra.animateAtlas.anim.addBySymbol('anim', params.extra_spr.anim, 24, false);
            xtra.animateAtlas.anim.addBySymbolIndices('loop', params.extra_spr.anim, [for (i in params.extra_spr.loop_frame...xtra.animateAtlas.anim.length) i], 24, true);
        } else {
            xtra.animation.addByPrefix('anim', params.extra_spr.anim, 24, false);
            xtra.animation.play('anim', true);
            xtra.animation.addByIndices('loop', params.extra_spr.anim, [for (i in params.extra_spr.loop_frame...xtra.animation.numFrames) i], '', 24, true);
        }

        xtra.visible = false;
        if (params.scale != null) {
            xtra.scale.set(params.scale, params.scale);
        }    
    }

    new FlxTimer().start(params.delay, (fuck) -> {
        FlxG.camera.flash(0xffffffff, 0.1, null, true);
        for (shit in scrollers) { shit.visible = true; }
        CoolUtil.playMenuSFX(1);
        // flicker
        new FlxTimer().start(3 / 24, (_) -> {
            if (_.loopsLeft == 0) {
                grahh.velocity.y = -80;
            } else {
                grahh.visible = !grahh.visible;
                var fu = _.loopsLeft % 2 == 0 ? 255 : 0;
                clearSmall.setColorTransform(1, 1, 1, 1, fu, fu, fu);
                clearBig.setColorTransform(1, 1, 1, 1, fu, fu, fu);
            }
        }, 10);

        //FlxTween.tween(songName.offset, {x: (clearSmall.graphWidth * -1) - 40}, 2, {ease: FlxEase.expoOut});
        //FlxTween.tween(songDifficulty.offset, {x: (clearSmall.graphWidth * -1) - 40}, 2, {ease: FlxEase.expoOut});
		  //FlxTween.tween(clearSmall.offset, {x: (clearSmall.graphWidth * -1) - 40}, 2, {ease: FlxEase.expoOut});
        clearSmall.alpha = 1;
        clearBig.number = clearSmall.number;

        FlxTween.tween(clearBig, {alpha: 0}, 0.4, {startDelay: 1.7});
    

        bf.visible = true;
        bf.playAnim('anim');
        new FlxTimer().start(params.loop_frame / 24, (_) -> {
            bf.playAnim('loop', true);

            if (xtra != null) {
                new FlxTimer().start(params?.extra_spr.delay, (_) -> {
                    xtra.visible = true;
                    xtra.playAnim('anim');
                    new FlxTimer().start(params?.extra_spr.loop_frame / 24, (_) -> {
                        xtra.playAnim('loop', true);
                    });
                });
            }
        });

        if (getRankMusicName() == 'PERFECT') {
            FlxG.sound.playMusic(Paths.music('resultsPERFECT'), 1, true);
        }
    });

    if (params?.extra_spr?.front) {
        add(bf);
        if (xtra != null) add(xtra);
    } else {
        if (xtra != null) add(xtra);
        add(bf);
    }
}

var _timeUntilScroll = 5;
var _timeUntilNextScroll = 5;
var canPress = true;
function postUpdate(elapsed) {
    if (_timeUntilScroll < 0) {
        _timeUntilScroll = 0;
    } else if (_timeUntilScroll == 0) {
        var max = 125;
        songName.velocity.x = FlxMath.bound(songName.velocity.x + (elapsed * max * -1), max * -1, 0);
        songDifficulty.velocity.x = FlxMath.bound(songName.velocity.x + (elapsed * max * -1), max * -1, 0);
        clearSmall.x = songDifficulty.x + songDifficulty.width * 1;

        if (songName.x - songName.offset.x + songName.width <= 500) {
            if (_timeUntilNextScroll < 0) {
                _timeUntilNextScroll -= elapsed;
            }
            else {
                _timeUntilScroll = 5;
                _timeUntilNextScroll = 5;
					 songName.setPosition(567 + songDifficulty.width * 1.6, -100);
					 songDifficulty.setPosition(567, -100);
					 clearSmall.setPosition(songDifficulty.x + songDifficulty.width * 1, -100);
					 songName.velocity.x = 0;
					 songDifficulty.velocity.x = 0;
					 FlxTween.tween(clearSmall, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});
					 FlxTween.tween(songName, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});
					 FlxTween.tween(songDifficulty, {y: 125}, 0.5, {ease: FlxEase.quartOut, startDelay: 0.9});
            }
        }
    }
    else {
        _timeUntilScroll -= elapsed;
    }

    if (controls.PAUSE && canPress)
    {
        canPress = false;
        if (FlxG.sound.music != null)
        {
            FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.8, {onComplete: _ -> {FlxG.sound.music.stop();}});
            FlxTween.tween(FlxG.sound.music, {pitch: 3}, 0.1,
            {
                onComplete: _ -> {
                  FlxTween.tween(FlxG.sound.music, {pitch: 0.5}, 0.4);
                }
            });
        }
        camFront.fade(0xFF000000, 0.2, false, () -> {
            // clear useless save data
            FlxG.save.data.resultsShit = null;
            FlxTransitionableState.skipNextTransIn = true;
            new FlxTimer().start(1, _ -> {
                FlxG.switchState(PlayState.isStoryMode ? new StoryMenuState() : new FreeplayState());
            });
        }, true);
    }
}

function destroy() {
    FlxG.camera.bgColor = 0;
}

class TallyCounter extends flixel.FlxSprite {
    public var number:Int = 0;

    public function new(x, y, ?sg) {
        setPosition(x, y);
        frames = Paths.getFrames('results/tallieNumber');
        for (bleh in 0...10) {
            var str = Std.string(bleh);
            animation.addByPrefix(str, str + ' small', 0, true);
        }
        animation.play('0', true);
    }

    public override function draw() {
        var ogx = x;
        var width = 40;
        var splitStr = Std.string(number).split('');
        splitStr.remove('-'); // ???
        var index = 0;
        for (i in splitStr) {
            x = ogx + (width * index);
            animation.play(i, true);
            super.draw();
            index += 1;
        }
        x = ogx;
    }
}

class ScoreGuy extends flixel.FlxSprite {
    // -1: disabled, -2: gone
    public var number:Int = -1;

    public function new(x, y, ?sg) {
        setPosition(x, y);
        frames = Paths.getFrames('results/score-digital-numbers');
        for (idx => bleh in [
            'ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE'
        ]) {
            var str = Std.string(bleh);
            animation.addByPrefix(Std.string(idx), str + ' DIGITAL', 24, false);
        }
        animation.addByPrefix('disabled', 'DISABLED', 24, false);
        animation.addByPrefix('gone', 'GONE', 24, false);

        animation.play('gone', true);
    }

    public function shuffle(finalNum:Int = 0) {
        var finall = finalNum;
        setNumber(-1);
        var duration:Float = 41 / 24;
        var interval:Float = 1 / 24;
        var shuffleTimer = new FlxTimer().start(interval, (_) -> {
            var tempDigit:Int = number;
            tempDigit += 1; tempDigit %= 10;
            setNumber(tempDigit, false);
          
            if (_.loops > 0 && _.loopsLeft == 0)
            {
                FlxTween.num(0, finall, 2 + (ID * 0.01), {ease: FlxEase.quartOut, onComplete: () -> {
                    setNumber(finall, true);
                }}, function(num) {
                    setNumber(Std.int(num), false);
                });
            }    
        }, Std.int(duration / interval));
    }

    public function setNumber(num:Int = 0, ?glow:Bool = true) {
        number = num ?? 0;
        if (num >= 0) animation.play(Std.string(num), true, false, glow ? 0 : 4);
        else animation.play(num == -1 ? 'disabled' : 'gone', true);
        centerOffsets(false);
    }
}

class ClearPercentCounter extends flixel.FlxSprite {
    public var number:Int = 0;
    public var big:Bool = true;

    public function new(x, y, ?sg) {
        setPosition(x, y);
        antialiasing = true;
        frames = Paths.getFrames('results/clearPercentText');
        animation.addByPrefix('bg', 'clearPercentText', 0, true);
        animation.addByPrefix('big', 'numbers0', 0, true);
        animation.addByPrefix('small', 'numbers small', 0, true);
        animation.play('bg', true);
    }

    public var graphWidth = 0;
    public override function draw() {
        var ogpos = {x: x, y: y};
        if (big) {
            animation.play('bg', true);
            super.draw();
        }

        var _width = big ? 80 : 30;
        var splitStr = Std.string(number).split('');
        var offsex = splitStr.length * _width;
        var offsex2 = 160;
        if (!big) {
            splitStr.push('10'); // percent
            offsex = offsex2 = 0;
        }
        else {
            y += 69;
        }
        for (index => i in splitStr) {
            scale.set(1, 1);
            x = ogpos.x + (_width * index) - offsex + offsex2;
            animation.play(big ? 'big' : 'small', true, false, Std.parseInt(i));
            if (i == '10') scale.set(1.25, 1.25);
            updateHitbox();
            super.draw();
        }

        graphWidth = x - ogpos.x + frameWidth;
        setPosition(ogpos.x, ogpos.y);
    }
}