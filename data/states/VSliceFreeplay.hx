import funkin.backend.chart.Chart;
import funkin.menus.FreeplaySonglist;
import funkin.menus.StoryWeeklist;
import funkin.backend.system.Control;
import funkin.backend.TurboControls;
import funkin.backend.TurboBasic;
import flixel.math.FlxRect;
import funkin.backend.system.framerate.Framerate;
import funkin.savedata.FunkinSave;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.ds.StringMap;

import Capsule;
import ScoreCounter;

// turbo controls, used in options menu, useful for repeating keys
var upTurboControl = new TurboControls([Control.UP]);
var downTurboControl = new TurboControls([Control.DOWN]);
var turboBasics = [upTurboControl, downTurboControl];
var capsuleGroup = new FlxSpriteGroup();
var fpList = FreeplaySonglist.get();

function coolTextFile(content:String) {
    var trim:String;
	return [for(line in content.split("\n")) if ((trim = StringTools.trim(line)) != "" && !StringTools.startsWith(line, "#")) trim];
}

fpList.songs.resize(0);
var songsFound = [];
var contents = getAddonFileContents(Paths.txt('config/freeplaySonglist'));
for (i in contents) {
    var __songsFound = coolTextFile(i);
    for (i in __songsFound) {
        if (!songsFound.contains(i)) songsFound.push(i);
        else continue;
    }
}
for (s in songsFound) {
    fpList.songs.push(Chart.loadChartMeta(s));
}

var swList = StoryWeeklist.get(null, false);
var character = freeplayCurCharacter;
var finalSongList = [];

var albumDatas = [
    '__placeholder__' => {
        image: 'menus/freeplay/album-placeholder',
        text: 'menus/freeplay/albums/volume1-text',
        data: {
            albumTitleOffsets: [8, 0]
        }
    }
];
for (i in Paths.getFolderContent('images/menus/freeplay/albums/')) {
    if (!StringTools.endsWith(i, '.json')) continue;
    var json = CoolUtil.parseJson('assets/images/menus/freeplay/albums/' + i);
    final key = i.substr(0, i.length - 5);

    // albumArtAsset and albumTitleAsset currently go unused
    albumDatas.set(key, {
        image: 'menus/freeplay/albums/' + key,
        text: 'menus/freeplay/albums/' + key + '-text',
        data: json
    });
}
var curAlbum = null;


// visuals
if (Assets.exists('data/backcards/' + character + '.hx')) {
    importScript('data/backcards/' + character + '.hx');
} else{ 
    importScript('data/backcards/default.hx');
}
var stupidDadBG = new FunkinSprite();
var imagePath = Paths.image('menus/freeplay/week1BG/' + character);
if (!Assets.exists(imagePath)) {
    imagePath = Paths.image('menus/freeplay/week1BG/bf');
}
stupidDadBG.loadGraphic(imagePath);
stupidDadBG.setGraphicSize(null, FlxG.height);
stupidDadBG.antialiasing = true;
stupidDadBG.updateHitbox();
stupidDadBG.screenCenter();
stupidDadBG.x += FlxG.width * 0.25;
stupidDadBG.x = Std.int(stupidDadBG.x);
stupidDadBG.shader = new FunkinShader('
#pragma header
void main() {
    vec2 uv = openfl_TextureCoordv;
    float slice = 0.109;
    gl_FragColor = flixel_texture2D(bitmap, uv) * smoothstep(slice, slice + 0.0016, uv.x + ((1.0 - uv.y) * slice));
}
');
var bg = getBackground();
bg.bg = stupidDadBG;
var fgBar = new FunkinSprite();
var album = new FunkinSprite(0, 0, Paths.image('menus/freeplay/album-placeholder'));
var albumName = new FunkinSprite(0, 0, Paths.image('menus/freeplay/albums/volume1-text'));
var albumStars = new FlxSpriteGroup();
var albumFlames = new FlxSpriteGroup();
var ostName = new FunkinText(8, 8, FlxG.width - 16, 'OFFICIAL OST', 48);
var highscoreTxt = new FunkinSprite(0, 70, Paths.image('menus/freeplay/highscore'));
var highscoreAnimTimerForNoReason:Float = 0;
var clearBox = new FunkinSprite(0, 65, Paths.image('menus/freeplay/clearBox'));
var clearPercent = new Alphabet(0, 86, '100', 'freeplay-clear');
var scoreCounter = new ScoreCounter();
var diffSprite = new FunkinSprite(0, 67);
var diffDots = new FunkinSprite(Std.int(FlxG.width * 0.156), 170, Paths.image('menus/freeplay/separator'));

function makeArrow() {
    var arrow = new FunkinSprite(0, 0, Paths.image('menus/freeplay/freeplaySelector'));
    arrow.antialiasing = true;
    arrow.addAnim('idle', 'arrow pointer loop', 24, true);
    arrow.addAnim('select', 'arrow pointer loop', 6, false, null, [0]); // i dont want to use manual timers
    arrow.playAnim('idle', true);
    arrow.updateHitbox();
    arrow.animation.onFinish.add((a) -> {
        if (a == 'select') {
            arrow.playAnim('idle', true);
        }
    });
    arrow.animation.onPlay.add((a) -> {
        if (a == 'select') {
            arrow.scale.set(0.6, 0.6);
            arrow.colorTransform.color = 0xffffff;
        } else {
            arrow.scale.set(1, 1);
            arrow.setColorTransform();
        }
    });
    return arrow;
}
var leftArrow = makeArrow();
var rightArrow = makeArrow();
rightArrow.flipX = true;
var diffAnchorX = FlxG.width * 0.154;

function create() {
    regenSongRegistry();

    stupidDadBG.scrollFactor.set();
    add(bg);
    
    add(diffSprite);
    for (i in [leftArrow, rightArrow]) {
        i.setPosition(diffAnchorX - i.width * 0.5, 70);
    }
    leftArrow.x  -= 152.5;
    rightArrow.x += 152.5;
    leftArrow.x  = Std.int(leftArrow.x);
    rightArrow.x = Std.int(rightArrow.x);
    add(leftArrow);
    add(rightArrow);

    var normalColors = [0xFF484848, 0xFFFAFAFA, 0xFF919191, 0xFFC9C9C9];
    var nightColors = [0xFF34296A, 0xFFC28AFF, 0xFF8A58D0, 0xFFFFB1DC];
    diffDots.antialiasing = true;
    add(diffDots);
    diffDots.onDraw = (dot) -> {
        if (allGlobalDiffs.length < 1) return;
        var ogX = dot.x;
        var distance = (13 * allGlobalDiffs.length) * 0.5;
        dot.x -= Std.int(distance * allGlobalDiffs.length * 0.5);
        dot.x += Std.int(dot.width * 0.5);
        for (z => i in allGlobalDiffs) {
            var colArray = (i.variation == 'erect') ? nightColors : normalColors;
            dot.color = colArray[(curSelectedDiffData.name == i.name) ? 1 : 0];
            dot.alpha = existsInCurDiffs(i.name) ? 1 : 0.4;
            dot.draw();
            dot.x += distance;
        }
        dot.x = ogX;
        dot.color = -1;
    };

    add(stupidDadBG);

    album.antialiasing = true;
    album.setPosition(
        Std.int(FlxG.width * 0.75) - 18,
        Std.int(FlxG.height * 0.5) - 86
    );
    album.angle = 10.26;

    // look funkin crew !!!!!!!!! no texture atlas !!!!!!!!
    var startX = album.x;
    var startAngle = album.angle;
    album.x += 400;
    album.angle += 200;
    FlxTween.tween(album, {x: startX - 20, angle: startAngle - 10}, 0.3, {framerate: 12}).then(
        FlxTween.tween(album, {x: startX, angle: startAngle}, 0.6, {framerate: 12, ease: FlxEase.expoOut})
    );
    add(album);
    albumName.antialiasing = true;
    albumName.setPosition(
        Std.int(FlxG.width * 0.75) - 35,
        Std.int(FlxG.height * 0.5) + 140
    );
    add(albumName);

    // this should be the corner position of the album
    albumFlames.setPosition(
        Std.int(FlxG.width * 0.75) + 8,
        Std.int(FlxG.height * 0.5) - 107
    );
    albumStars.setPosition(
        Std.int(FlxG.width * 0.75) + 8,
        Std.int(FlxG.height * 0.5) - 107
    );

    add(albumFlames);
    add(albumStars);

    final TO_RAD = 0.017453292519943295; // FlxAngle.TO_RAD is null in hscript (pls fix ???)
    for (i in 0...10) {
        final xx = i * Math.cos(startAngle * TO_RAD) * 28.2;
        final yy = i * Math.sin(startAngle * TO_RAD) * 25.6; // off on purpose (thanks dave)

        var star = new FunkinSprite(xx, yy, Paths.image('menus/freeplay/freeplay-stars'));
        star.addAnim('star', 'difficulty stars', 24, true, null, null, 20, 36);
        star.addAnim('star-lit', 'difficulty stars', 6, true, null, [65], 20, 36);
        star.addAnim('dot', 'diffuculty dot' /* David Brown. */, 24, true, null, null, 5, 5);
        star.playAnim('dot', true);
        star.updateHitbox();
        star.antialiasing = true;
        albumStars.add(star);

        var flame = new FunkinSprite(xx, yy, Paths.image('menus/freeplay/freeplay-flame'));
        flame.addAnim('idle', 'fire loop full instance 1', 24, false, null,                   [0, 1], 55, 150);
        flame.addAnim('idle-loop', 'fire loop full instance 1', 24, true, null, [for (i in 2...9) i], 55, 150);
        flame.playAnim('idle', true);
        flame.updateHitbox();
        flame.antialiasing = true;
        // im lazy
        flame.extra['animTimer'] = new FlxTimer();
        flame.extra['animTimer'].onComplete = (_) -> {
            flame.exists = true;
        };
        albumFlames.add(flame);
    }

    albumStars.exists = albumFlames.exists = albumName.exists = false;
    new FlxTimer().start(1, (_) -> {
        albumStars.exists = albumFlames.exists = albumName.exists = true;
    });

    add(capsuleGroup);
    
    fgBar.scrollFactor.set(0, 1.2);
    fgBar.makeGraphic(FlxG.width, 256, -1);
    fgBar.color = FlxColor.BLACK;
    fgBar.y = -fgBar.height + 64;
    add(fgBar);

    var freeplayName = new FunkinText(8, 8, FlxG.width - 16, 'FREEPLAY', 48); // ik its static but this is nicer ok
    freeplayName.scrollFactor.set(0, 1.2);
    add(freeplayName);

    ostName.scrollFactor.set(0, 1.2);
    ostName.alignment = 'right';
    add(ostName);

    highscoreTxt.addAnim('idle', '', 24, false);
    highscoreTxt.playAnim('idle', true);
    highscoreTxt.updateHitbox();
    add(highscoreTxt);

    clearBox.x = FlxG.width - 12 - clearBox.width;
    highscoreTxt.x = clearBox.x - 16 - highscoreTxt.width;
    add(clearBox);

    // positioning is done in postUpdate
    add(clearPercent);

    scoreCounter.x = FlxG.width - 353;
    scoreCounter.y = 120;
    add(scoreCounter);
}

function postCreate() {
    capsuleGroup.setPosition(Std.int(FlxG.width * 0.5 - 243), Std.int(FlxG.height * 0.5 - 111));

    regenSongList();

    // KILL FUNKIN CREW
    var stupidDiffIndex = -1;
    for (x => i in curDiffList) {
        if (i.name == Options.freeplayLastDifficulty.toLowerCase()) {
            stupidDiffIndex = x;
            break;
        }
    }

    changeDifficulty(Math.abs(stupidDiffIndex), true, null, true);
    lerpSelected = curSelected;

    Framerate.offset.y = 65;

    CoolUtil.playMusic(Paths.music('freeplayRandom'));
    FlxG.mouse.visible = true;

    var doOpeningRank = false;

    // watch what happens when i enable a bool i dont know !!!!
    // doOpeningRank = true;

    if (doOpeningRank) {
        var cap = capsuleGroup.members[curSelected];

        if (cap.rank == null) {
            FlxG.log.warn('lets not actually do anything..............new rank is null so');
            return;
        }
        FlxG.camera.zoom = 1.15;
        FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.6, {ease: FlxEase.sineIn});

        FlxG.sound.music.volume = 0;

        enableControls = false;
        cap.visible = cap.active = false;

        // dummy, pls replace when adding results screen
        var oldHighscore = {
            score: 0,
            accuracy: 0,
            hits: []
        };

        var rankColor = switch (cap.rank) {
            case 'good':
                0xFFEF8764;
            case 'great':
                0xFFEAF6FF;
            case 'excellent':
                0xFFFDCB42;
            case 'perfect':
                0xFFFF58B4;
            case 'perfect-gold':
                0xFFFFB619;
            default:
                0xFF6044FF;
        }
    
        var overlay = new FunkinSprite();
        add(overlay);
        overlay.makeSolid(FlxG.width, FlxG.height, -1);
        overlay.screenCenter();
        overlay.scrollFactor.set();
        overlay.color = 0x000000;
        overlay.alpha = 0.75;

        var displayCap = new Capsule();
        displayCap.meta = cap.meta;
        displayCap.loadData(cap.curMeta);
        displayCap.setDifficultyText(Std.parseInt(cap.diffText.text));
        displayCap.setRankFromHighscore(oldHighscore);
        displayCap.zoomFactor = 0;
        displayCap.scale.set(2.07, 2.07);
        FlxTween.tween(displayCap.scale, {x: 2, y: 2}, 0.6, {ease: FlxEase.sineIn});
        displayCap.select();
        displayCap.selected = false; // no text scrolling
        add(displayCap);

        var vignette = new FunkinSprite(0, 0, Paths.image('menus/freeplay/rank-vignette'));
        add(vignette);
        vignette.setGraphicSize(FlxG.width, FlxG.height);
        vignette.updateHitbox();
        vignette.screenCenter();
        vignette.antialiasing = true;
        vignette.blend = BlendMode.ADD;
        vignette.alpha = 0;
        vignette.color = rankColor;

        var sparks = new FunkinSprite();
        sparks.loadSprite(Paths.image('menus/freeplay/sparks'));
        sparks.addAnim('sparks', 'sparks', 24, false);
        sparks.playAnim('sparks', true);
        sparks.updateHitbox();
        sparks.antialiasing = true;

        var sparksAdd = new FunkinSprite();
        sparksAdd.loadSprite(Paths.image('menus/freeplay/sparks-add'));
        sparksAdd.addAnim('sparks', 'sparks', 24, false, null, null, 17, 17);
        sparksAdd.playAnim('sparks', true);
        sparksAdd.updateHitbox();
        sparksAdd.antialiasing = true;

        // no proper way of getting width and height for now
        displayCap.setPosition(
            (FlxG.width  * 0.5) - 230,
            (FlxG.height * 0.5) - 60
        );
        displayCap.origin.set(230, 60);

        new FlxTimer().start(0.6, (_) -> {
            displayCap.setRankFromHighscore(curSelectedDiffData.highscore);
            displayCap.rankBadge.scale.set(20, 20);
            FlxTween.tween(displayCap.rankBadge.scale, {x: 0.9, y: 0.9}, 0.1);

            displayCap.rankBadgeBlur.scale.set(20, 20);
            FlxTween.tween(displayCap.rankBadgeBlur.scale, {x: 0.9, y: 0.9}, 0.1);

            var rankSound = switch (displayCap.rank) {
                case 'loss': 'bad';
                case 'perfect' | 'perfect-gold': 'perfect';
                default: 'normal';
            };
            new FlxTimer().start(0.1, (_) -> {
                FlxG.sound.play(Paths.sound('ranks/in/' + rankSound));
                displayCap.scale.set(1.95, 1.95);
                FlxTween.tween(displayCap.scale, {x: 2, y: 2}, 0.5, {ease: FlxEase.backOut});
                new FlxTimer().start(1 / 30, (_) ->{
                    displayCap.frameOffset.set(FlxG.random.float(-3, 3), FlxG.random.float(-3, 3));
                    if (_.loopsLeft == 0) {
                        displayCap.frameOffset.set();
                    }
                }, 8);

                FlxTween.tween(FlxG.camera, {zoom: 1.05}, 0.3, {ease: FlxEase.elasticOut});

                add(sparksAdd);
                add(sparks);

                // destroyingin these crashes the game
                sparks.animation.onFinish.add((a) -> { remove(sparks, true); });
                sparksAdd.animation.onFinish.add((a) -> { remove(sparksAdd, true); });

                for (i in [sparks, sparksAdd]) {
                    i.x += displayCap.rankBadge.x * 2 - 50;
                    i.y += displayCap.rankBadge.y * 2 + 120;
                }
                sparksAdd.color = rankColor;
            });

            // pre slam
            new FlxTimer().start(0.4, (_) -> {
                FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.sineIn});
            });

            // slam
            new FlxTimer().start(0.6, (_) -> {
                FlxG.sound.play(Paths.sound('ranks/slam/' + ((displayCap.rank == 'perfect-gold') ? 'perfect' : displayCap.rank)));
                FlxTween.tween(displayCap, {x: capsuleGroup.x, y: capsuleGroup.y, zoomFactor: 1}, 0.5, {ease: FlxEase.linear});
                FlxTween.tween(displayCap.scale, {x: 1, y: 1}, 0.5, {ease: FlxEase.quartIn});
                FlxTween.tween(overlay, {alpha: 0}, 0.45, {ease: FlxEase.quartIn});
                new FlxTimer().start(0.5, (_) -> {
                    remove(overlay, true);
                    overlay.destroy();

                    remove(displayCap, true);
                    displayCap.destroy();

                    sparksAdd.destroy();
                    sparks.destroy();

                    cap.visible = cap.active = true;
                    FlxG.camera.zoom = 0.96;
                    FlxTween.cancelTweensOf(FlxG.camera, ['zoom']);
                    FlxTween.tween(FlxG.camera, {zoom: 1}, 0.8, {ease: FlxEase.elasticOut});
                    FlxG.camera.shake(0.0045, 0.35);

                    import flixel.addons.effects.FlxTrail;
                    var impactThing = new FunkinSprite(capsuleGroup.x, capsuleGroup.y);
                    impactThing.frames = cap.capsule.frames;
                    impactThing.frame = cap.capsule.frame;
                    impactThing.updateHitbox(); // funkin crew is dumb and gay
                    impactThing.origin.copyFrom(cap.capsule.origin);
                    impactThing.offset.copyFrom(cap.capsule.offset);
                    impactThing.alpha = 0;
                    add(impactThing);
                    FlxTween.tween(impactThing.scale, {x: 2.5, y: 2.5}, 0.5);
                    // FlxTween.tween(impactThing, {alpha: 0}, 0.5);

                    evilTrail = new FlxTrail(impactThing, null, 15, 0.03, 0.01, 0.069);
                    evilTrail.blend = BlendMode.ADD;
                    evilTrail.color = rankColor;
                    FlxTween.tween(evilTrail, {alpha: 0}, 0.6, {
                        ease: FlxEase.quadOut,
                        onComplete: function(_)
                        {
                            _.cancel();
                            remove(evilTrail, true);
                            evilTrail.destroy();
                        }
                    });
                    add(evilTrail);

                    vignette.alpha = 1;
                    FlxTween.tween(vignette, {alpha: 0}, 0.6, {ease: FlxEase.expoOut,
                        onComplete: (_) ->{
                            _.cancel();
                            remove(vignette, true);
                            vignette.destroy();
                        }
                    });

                    var distance = 5;
                    for (i in -distance...(distance + 1)) {
                        var target = capsuleGroup.members[cap.ID + i];
                        if (target == null) continue;
                        new FlxTimer().start(Math.abs(i) * 0.05, (_) -> {
                            if (i != 0) {
                                target.angle = 10 * FlxG.random.float(-1, 1) / Math.abs(i);
                                FlxTween.tween(target, {angle: 0}, 0.5, {ease: FlxEase.backOut});
                            }
                            new FlxTimer().start(1 / 30, (_) ->{
                                // this is not an int
                                var int = 15 * (1 - FlxEase.quadOut((_.loops - _.loopsLeft) / _.loops));
                                target.frameOffset.set(FlxG.random.float(-int, int), FlxG.random.float(-int, int));
                                if (_.loopsLeft == 0) {
                                    target.frameOffset.set();
                                }
                            }, 18);
                        });
                    }

                    new FlxTimer().start(0.6, (_) -> {
                        enableControls = true;
                        new FlxTimer().start(1.4, (_) -> {
                            FlxG.sound.music.time = 0;
                            FlxG.sound.music.fadeIn(2);
                        });
                    });
                });
            });
        });
    }
}
var curSelected = 0;
var lerpSelected = 0;
var intendedScore = 0;
var lerpScore = 0;
var intendedAccuracy = 0;
var lerpAccuracy = 0;
var enableControls = true;
function update(elapsed) {
    var pressedDiff = false;
    if (enableControls) {
        for (basic in turboBasics) basic.update(elapsed);

        if (controls.CHANGE_MODE || (FlxG.mouse.justPressed && (FlxG.mouse.x < FlxG.width * 0.25) && (FlxG.mouse.y > 260))) {
            enableControls = false;
            CoolUtil.playMenuSFX(1).persist = true;
            FlxG.sound.music.fadeOut(1);

            // this looks so awful
            bg.switch();

            final scrollStartDelay = 0.45;

            FlxTween.tween(FlxG.camera.scroll, {y: 250}, 0.9, {startDelay: scrollStartDelay, ease: FlxEase.backIn});
            FlxTween.tween(Framerate.offset, {y: 0}, 0.8, {startDelay: scrollStartDelay, ease: FlxEase.backIn});

            Options.freeplayLastSong = lastSong;
            Options.freeplayLastDifficulty = curSelectedDiffData.name;
            Options.freeplayLastVariation = curSelectedDiffData.variation; // this isnt used in this state but on the base one instead

            var overlay = new FunkinSprite();
            add(overlay);
            overlay.makeSolid(FlxG.width, FlxG.height, -1);
            overlay.screenCenter();
            overlay.scrollFactor.set();
            overlay.blend = BlendMode.SUBTRACT;
            overlay.color = 0x666600;
            overlay.alpha = 0;
            FlxTween.tween(overlay, {alpha: 1}, 0.15, {startDelay: scrollStartDelay + 0.4}).then(
                FlxTween.tween(overlay.colorTransform, {
                    redMultiplier: 1,
                    greenMultiplier: 1,
                    blueMultiplier: 1
                }, 0.3, {
                    onComplete: (_) -> {
                        // not done yet
                        FlxG.switchState(new ModState('CharacterSelectState'));
                    }
                })
            );
        }

        if (upTurboControl.activated || FlxG.mouse.wheel == 1) changeSelection(-1);
        if (downTurboControl.activated || FlxG.mouse.wheel == -1) changeSelection(1);

        if (controls.LEFT_P || (CoolUtil.mouseOverlaps(leftArrow) && FlxG.mouse.justPressed)) {
            changeDifficulty(-1);
            leftArrow.playAnim('select', true);
            pressedDiff = true;
        }
        if (controls.RIGHT_P || (CoolUtil.mouseOverlaps(rightArrow) && FlxG.mouse.justPressed)) {
            changeDifficulty(1);
            rightArrow.playAnim('select', true);
            pressedDiff = true;
        }

        if (FlxG.keys.justPressed.HOME) {
            changeSelection(-curSelected);
        }
        if (FlxG.keys.justPressed.END) {
            changeSelection(finalSongList.length - 1 - curSelected);
        }

        if (controls.ACCEPT) {
            selectSong(curSelected);
        }

        if (controls.BACK || FlxG.mouse.justPressedRight) {
            enableControls = false;
            FlxG.sound.music.stop();
            CoolUtil.playMenuSFX(2).persist = true;
            FlxG.switchState(new MainMenuState());
        }
    }

    lerpSelected = lerp(lerpSelected, curSelected, 0.25);

    capsuleGroup.forEach((c) -> {
        // cant use forEachAlive cus im setting exists
        if (!c.alive) return;
        if (enableControls && !pressedDiff && CoolUtil.mouseOverlaps(c) && FlxG.mouse.justPressed) {
            if (curSelected == c.ID) {
                selectSong(c.ID);
            } else changeSelection(c.ID - curSelected);
        }
        var diff = c.ID - lerpSelected;
        c.x = capsuleGroup.x + Math.sin(diff + 1) * 60.5 - 60.5;
        c.y = capsuleGroup.y + (diff + Math.min(diff, -1) + 1) * 115.5;
        c.scrollFactor.set(0, 0.4);
        c.exists = (diff > -2) && (diff < 4); // this holds everything together
    });
}
function destroy() {
	for (basic in turboBasics) basic.destroy();
    Framerate.offset.y = 0;
}
function changeSelection(ch, ?silent) {
    silent ??= false;

    var pastDiff = curSelectedDiffData?.name ?? null;

    var pastSelected = curSelected;
    curSelected = FlxMath.wrap(curSelected + ch, 0, finalSongList.length - 1);
    if (capsuleGroup.members[pastSelected] != null) {
        capsuleGroup.members[pastSelected].deselect();
        if (!silent) capsuleGroup.members[pastSelected].clipTimer = 0;
    }

    if (capsuleGroup.members[curSelected] != null) {
        capsuleGroup.members[curSelected].select();
        if (!silent) capsuleGroup.members[curSelected].clipTimer = 0;
    }

    if (!silent) CoolUtil.playMenuSFX(0);

    refreshCSDD();
    var diffID = getCurDiffID(pastDiff, curDiffList);
    curSelectedDiff = diffID;
    changeDifficulty(0, true, false);

    final cap = capsuleGroup.members[curSelected];
    final save = (cap.name != null && curSelectedDiffData != null) ? (curSelectedDiffData.highscore) : null;

    intendedScore = save?.score ?? 0;
    intendedAccuracy = save?.accuracy ?? 0;

    lastSong = cap.name;

    albumStars.visible = albumFlames.visible = albumName.visible = album.visible = (cap.name != null);
    if (cap.name == null) {
        changeAlbum(curAlbum = albumDatas['__placeholder__']);
        updateStars(0);
        return;
    }
    final meta = cap?.curMeta ?? cap?.curMeta?.parent;
    var newAlbum = (meta?.customValues?.album) ?? '__placeholder__';
    if (curAlbum != newAlbum) {
        curAlbum = newAlbum;
        changeAlbum(albumDatas[newAlbum]);
    }
    updateStars(Reflect.field(meta?.customValues?.ratings, curSelectedDiffData.name) ?? 0);
}
function updateStars(count:Int) {
    for (x => i in albumStars.members) {
        var isStar = Math.min(albumStars.members.length, count - 1) >= x;
        i.playAnim(isStar ? 'star' : 'dot', true);
        if (isStar) {
            i.globalCurFrame = (albumStars.members.length - x) * 2;
            if ((count - albumStars.members.length) > x) {
                i.playAnim('star-lit', true);
            }
        }
    }
    var lastFlamesVisible = albumFlames.visible;
    albumFlames.visible = count > albumFlames.members.length;
    if (!albumFlames.visible) return;
    for (x => i in albumFlames.members) {
        var isStar = Math.min(albumFlames.members.length, count - albumStars.members.length - 1) >= x;
        i.exists = false;
        i.playAnim('idle', true);
        if (!isStar) continue;
        i.extra['animTimer'].start((x + 1) * 0.1 + FlxG.random.float(-0.05, 0.05), i.extra['animTimer'].onComplete);
    }
}
var stupidAssTimer = new FlxTimer();
function changeAlbum(al) {
    album.loadGraphic(Paths.image(al?.image ?? 'menus/freeplay/albums/volume1'));
    album.setGraphicSize(262, 262);
    album.updateHitbox();

    final bump = 10;
    album.offset.y -= bump;
    if (stupidAssTimer != null) stupidAssTimer.cancel();
    stupidAssTimer.start(2 / 24, (_) -> {
        album.offset.y += bump;
    });

    // cheating here for a bit cus i dont like the anim names
    albumName.loadSprite(Paths.image(al?.text ?? 'menus/freeplay/albums/volume1-text'));
    albumName.addAnim('idle', 'switch',   24, false, null, null, (al?.data?.albumTitleOffsets[0] ?? 0) * -1, (al?.data?.albumTitleOffsets[1] ?? 0) * -1);
    albumName.addAnim('idle-loop', 'idle', 24, true, null, null, (al?.data?.albumTitleOffsets[0] ?? 0) * -1, (al?.data?.albumTitleOffsets[1] ?? 0) * -1);
    albumName.playAnim('idle', true);
    albumName.updateHitbox();
}
var allGlobalDiffs = [];
var curSelectedDiff = 0;
var curSelectedDiffData = null;
var curDiffList = null;
var __nullCoalescingHatesMe = [];
function refreshCSDD() {
    curSelectedDiffData = null;
    curDiffList = null;
    var cap = capsuleGroup.members[curSelected];

    if (cap.name != null) {
        // KILL FUNKIN CREW
        __nullCoalescingHatesMe.resize(3);
        if (cap.curMeta != null) 
            __nullCoalescingHatesMe[0] = cap.curMeta.allDifficulties;
        if (Reflect.hasField(cap.curMeta, 'parent')) 
            __nullCoalescingHatesMe[1] = cap.curMeta.parent.allDifficulties;
        __nullCoalescingHatesMe[2] = allGlobalDiffs;

        while (curDiffList == null && __nullCoalescingHatesMe.length > 0) {
            curDiffList = __nullCoalescingHatesMe.shift();
        }
    } else {
        // force all diffs for random capsule
        curDiffList = allGlobalDiffs;
    }
    curSelectedDiff = FlxMath.wrap(curSelectedDiff, 0, curDiffList.length - 1);
    curSelectedDiffData = curDiffList[curSelectedDiff];
}
function changeDifficulty(ch, ?silent, ?sel, ?forceAnim) {
    silent ??= false;
    sel ??= true;
    forceAnim ??= false;

    var pastSelectedDiff = curSelectedDiff;
    curSelectedDiff += ch;

    // KILL FUNKIN CREW
    refreshCSDD();

    if (!silent) CoolUtil.playMenuSFX(0);

    final diff = curSelectedDiffData.name;
    diffSprite.loadSprite(Paths.image('menus/freeplay/difficulties/' + diff));
    diffSprite.antialiasing = true;
    if (diffSprite.frames is FlxAtlasFrames) {
        diffSprite.addAnim('idle', 'idle0', 24, true);
        if (Options.flashingMenu) diffSprite.playAnim('idle', true);
    }

    if (forceAnim || ch != 0) {
        diffSprite.updateHitbox();
        diffSprite.setPosition(diffAnchorX, 116);
        diffSprite.x = Std.int(diffSprite.x - diffSprite.width * 0.5);
        diffSprite.y = Std.int(diffSprite.y - diffSprite.height * 0.5);

        final displacement = FlxMath.signOf(ch) * 400;
        if (displacement != 0) {
            diffSprite.x += displacement;
            FlxTween.cancelTweensOf(diffSprite, ['x']);
            FlxTween.tween(diffSprite, {x: diffSprite.x - displacement}, 0.2, {ease: FlxEase.circInOut});
        }
    }

    if (sel) {
        updateAllDiffs();
        changeSelection(0, true);
    }
}
var curTrackedVariation = (character == 'bf') ? null : character;
var curTrackedDiff = null;
function updateAllDiffs() {
    var diff = curSelectedDiffData;
    if (diff == null) return;
    var targetVariation = diff.variation;
    var targetDiff = diff.name;
    // KILL FUNKIN CREW
    if (diff.variation == character) {
        targetVariation = null;
    }
    if (curTrackedVariation != targetVariation) {
        curTrackedVariation = targetVariation;
        // implement letter sorting later?
        regenSongRegistry(null, diff.variation);
        regenSongList();
    }
    if (curTrackedDiff != targetDiff) {
        curTrackedDiff = targetDiff;
        
        // KILL FUNKIN CREW
        var dipshit = false;
        for (i in capsuleGroup.members) {
            if (i.curMeta == null) continue;
            if (!existsInCurDiffs(diff.name, i.curMeta.allDifficulties)) {
                dipshit = true;
                // implement letter sorting later?
                regenSongRegistry(null, curTrackedVariation, diff.name);
                regenSongList(true);
                break;
            }
        }
        if (!dipshit) {
            regenSongRegistry(null, curTrackedVariation, diff.name);
            regenSongList();
        }
    }
    capsuleGroup.forEach((cap) -> {
        if (cap.name == null) return;
        cap.setDifficultyText(Reflect.field(cap.curMeta?.customValues?.ratings, diff.name) ?? 0);

        var allDiffs = cap.curMeta?.parent?.allDifficulties ?? cap?.curMeta?.allDifficulties;
        if (allDiffs == null) return;
        var poop = allDiffs[getCurDiffID(diff.name, allDiffs)];
        cap.setRankFromHighscore(poop?.highscore);
    });
}
function selectSong(id) {
    enableControls = false;
    if (id == 0) {
        // no songs
        if (finalSongList.length > 1) {
            while (id == 0) {
                id = FlxG.random.int(1, finalSongList.length - 1);
            }
            changeSelection(id);
            new FlxTimer().start(0.4, (_) -> { selectSong(curSelected); });
        }
        else {
            var c = capsuleGroup.members[id];
            FlxTween.cancelTweensOf(c.frameOffset);
            c.frameOffset.y = -6;
            FlxTween.tween(c.frameOffset, {y: 0}, 0.7, {ease: FlxEase.elasticOut, framerate: 15});
            CoolUtil.playMenuSFX(2);
            enableControls = true;
        }
        return;
    }
    if (capsuleGroup.members[id] != null) {
        CoolUtil.playMenuSFX(1);
        var c = capsuleGroup.members[id];
        if (c.icon.visible) c.icon.playAnim('confirm', true);
        Options.freeplayLastSong = c.name;
        Options.freeplayLastDifficulty = curSelectedDiffData.name;
        Options.freeplayLastVariation = curSelectedDiffData.variation;

        bg.select();

        new FlxTimer().start(1.3, (_) -> {
            var overlay = new FunkinSprite();
            add(overlay);
            overlay.makeSolid(FlxG.width, FlxG.height, -1);
            overlay.screenCenter();
            overlay.scrollFactor.set();
            overlay.blend = BlendMode.SUBTRACT;
            overlay.alpha = 0;
            FlxG.sound.music.stop();
            FlxTween.tween(Framerate.offset, {y: 0}, 0.2, {ease: FlxEase.sineOut});
            FlxTween.tween(overlay, {alpha: 1}, 0.2, {
                ease: FlxEase.sineIn,
                onComplete: (_) -> {
                    PlayState.loadSong(
                        Options.freeplayLastSong,
                        Options.freeplayLastDifficulty,
                        Options.freeplayLastVariation
                    );
                    FlxG.switchState(new PlayState());
                }
            });
        });
    }
}
// cosmetic related, regular update is selection code
function postUpdate(elapsed) {
    highscoreAnimTimerForNoReason -= elapsed;
    if (highscoreAnimTimerForNoReason <= 0) {
        highscoreAnimTimerForNoReason = FlxG.random.float(20, 60);
        highscoreTxt.playAnim('idle', true);
    }

    lerpScore = lerp(lerpScore, intendedScore, 0.3);
    scoreCounter.value = Math.round(lerpScore);

    lerpAccuracy = lerp(lerpAccuracy, intendedAccuracy, 0.3);
    clearPercent.text = Math.round(lerpAccuracy * 100);
    clearPercent.x = clearBox.x + clearBox.width - 34 - clearPercent.textWidth;
}

/////////////////////////////////////////////////////////////////
//region super backend
/////////////////////////////////////////////////////////////////

function regenSongRegistry(?extraSort, ?forcedVari, ?forcedDiff) {
    finalSongList.resize(0);
    var stupid = 0;
    while (stupid < fpList.songs.length) {
        var i = fpList.songs[stupid++];
        if (i == null) continue;

        if (!Reflect.hasField(i, 'week')) {
            for (j in swList.weeks) {
                var found = false;
                for (k in j.songs) {
                    if (k.name.toLowerCase() == i.name.toLowerCase()) {
                        Reflect.setField(i, 'week', j.id);
                        found = true;
                        break;
                    }
                }
                if (found) break;
            }
        }

        if (!Reflect.hasField(i, 'player'))
            Reflect.setField(i, 'player', 'bf');

        if (!Reflect.hasField(i, 'allDifficulties')) {
            Reflect.setField(i, 'allDifficulties', i.difficulties.copy().map((a) -> {
                name: a.toLowerCase(),
                variation: null,
                highscore: FunkinSave.getSongHighscore(
                    i.name,
                    a,
                    null
                )
            }));
            for (fuck in i.difficulties) {
                var foid = fuck.toLowerCase();
                var moid = 0;
                var noid = false;
                while (moid < allGlobalDiffs.length) {
                    var yeah = allGlobalDiffs[moid++];
                    if (yeah.name == foid) {
                        noid = true;
                        break;
                    }
                }
                if (noid) continue;
                allGlobalDiffs.push({
                    name: foid,
                    variation: null,
                    highscore: {
                        score: 0,
                        accuracy: 0,
                        hits: []
                    }
                });
            }

            // KILL FUNKIN CREW
            if (i.metas.keys().array.length > 0) {
                for (n => m in i.metas) {
                    if ((m.player ?? 'bf') != character) continue;
                    for (o in m.difficulties) {
                        var foid = o.toLowerCase();
                        var moid = 0;
                        var noid = false;
                        while (moid < i.allDifficulties.length) {
                            var yeah = i.allDifficulties[moid++];
                            if (yeah.name == foid) {
                                noid = true;
                                break;
                            }
                        }
                        if (noid) continue;
                        i.allDifficulties.push({
                            name: foid,
                            variation: n,
                            highscore: FunkinSave.getSongHighscore(
                                i.name,
                                foid,
                                n
                            )
                        });

                        moid = 0;
                        noid = false;
                        while (moid < allGlobalDiffs.length) {
                            var yeah = allGlobalDiffs[moid++];
                            if (yeah.name == foid) {
                                noid = true;
                                break;
                            }
                        }
                        if (noid) continue;
                        allGlobalDiffs.push({
                            name: foid,
                            variation: n,
                            highscore: {
                                score: 0,
                                accuracy: 0,
                                hits: []
                            }
                        });
                    }
                }
            }
        }

        var foundAlt = false;
        if (i.player != character) {
            var metasKeys = i.metas.keys().array;
            if (metasKeys.length < 1) continue;
            for (n => m in i.metas) {
                if ((m?.player ?? n) == character) {
                    // KILL FUNKIN CREW
                    var r = [i.allDifficulties];
                    if (character != 'bf') r.push(allGlobalDiffs);
                    for (q in r) {
                        for (p in q) {
                            if (p.variation == null) {
                                p.variation = n;
                                p.highscore = FunkinSave.getSongHighscore(
                                    m.name,
                                    p.name,
                                    n
                                );
                            }
                        }
                    }
                    if (!Reflect.hasField(m, 'parent'))
                        Reflect.setField(m, 'parent', i);
                    i = m;
                    foundAlt = true;
                    break;
                }
            }
            if (!foundAlt) continue;
        }

        if ((forcedVari != null) && (i.variant != forcedVari)) {
            var og = i;
            if (Reflect.hasField(i, 'parent')) {
                og = i.parent;
            }
            i = i.metas[forcedVari];
            if (i == null) continue;
            Reflect.setField(i, 'parent', og);
        }

        if ((i != null) && (forcedDiff != null)) {
            if (!existsInCurDiffs(forcedDiff.toLowerCase(), i.allDifficulties)) continue;
        }

        finalSongList.push(i);
    }

    if (extraSort != null)
        extraSort(finalSongList);

    finalSongList.insert(0, null); // random
}
var lastSong = Options.freeplayLastSong;
function regenSongList(?noUpdate) {
    noUpdate ??= false;
    var lastSongID = -1;
    if (lastSong == null) {
        lastSongID = 0;
    } else {
        lastSongID = 0;
        for (x => i in finalSongList) {
            if ((i != null) && (lastSong != null) && (lastSong.toLowerCase() == i.name.toLowerCase())) {
                lastSongID = x;
                break;
            }
        }
    }
    // -1 bounces back to Tutorial (or anything after random)
    lastSongID = Math.abs(lastSongID);

    var maxLength = Math.max(finalSongList.length, capsuleGroup.members.length);
    var i = 0;
    while (i < maxLength) {
        var cap = capsuleGroup.members[i];
        if (cap == null) {
            var c = new Capsule();
            c.x = FlxG.width;
            c.y = i * 140;
            c.ID = i;
            capsuleGroup.add(c);
            cap = c;
        }

        // remove excess songs
        if (i >= finalSongList.length) {
            cap.kill();
        } else {
            if (!cap.alive) cap.revive();
            cap.meta = finalSongList[i];
            cap.loadData(finalSongList[i]);
            cap.deselect();
        }

        i++;
    }

    curSelected = lastSongID;
    changeDifficulty(0, true, !noUpdate);
    if (noUpdate) changeSelection(0, true);
}
function existsInCurDiffs(a:String, ?array) {
    array ??= curDiffList;
    var i = 0;
    while (i < array.length) {
        if ((array[i++].name.toLowerCase()) == (a.toLowerCase())) {
            return true;
        }
    }
    return false;
}

function getCurDiffID(a:String, ?array) {
    array ??= curDiffList;
    var i = 0;
    while (i < array.length) {
        if ((array[i++].name.toLowerCase()) == (a.toLowerCase())) {
            return i - 1;
        }
    }
    return -1;
}