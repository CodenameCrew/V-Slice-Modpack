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

import Capsule;
import ScoreCounter;

// turbo controls, used in options menu, useful for repeating keys
var upTurboControl = new TurboControls([Control.UP]);
var downTurboControl = new TurboControls([Control.DOWN]);
var turboBasics = [upTurboControl, downTurboControl];
var capsuleGroup = new FlxSpriteGroup();
var fpList = FreeplaySonglist.get();
var swList = StoryWeeklist.get(null, false);
var fpMap = ['' => 'hi im a map'];
var character = 'bf';
var validCharVariations = ['bf', 'pico'];

// maybe make these more flexible in the future
var allDifficulties = ['easy', 'normal', 'hard', 'erect', 'nightmare'];
var allVariations = ['erect', null, character]; // sorted like this to help with looking up difficulties

// visuals
importScript('data/backcards/bf');
var stupidDadBG = new FunkinSprite();
stupidDadBG.loadGraphic(Paths.image('menus/freeplay/freeplayBGweek1-' + character));
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
var ostName = new FunkinText(8, 8, FlxG.width - 16, 'OFFICIAL OST', 48);
var highscoreTxt = new FunkinSprite(0, 70, Paths.image('menus/freeplay/highscore'));
var highscoreAnimTimerForNoReason:Float = 0;
var clearBox = new FunkinSprite(0, 65, Paths.image('menus/freeplay/clearBox'));
var clearPercent = new Alphabet(0, 86, '100', 'freeplay-clear');
var scoreCounter = new ScoreCounter();
var diffSprite = new FunkinSprite(0, 67);

function makeArrow() {
    var arrow = new FunkinSprite(0, 0, Paths.image('menus/freeplay/freeplaySelector'));
    arrow.addAnim('idle', 'arrow pointer loop', 24, true);
    arrow.playAnim('idle', true);
    arrow.updateHitbox();
    return arrow;
}
var leftArrow = makeArrow();
var rightArrow = makeArrow();
rightArrow.flipX = true;
var diffAnchorX = FlxG.width * 0.154;

function create() {
    CoolUtil.playMusic(Paths.music('freeplayRandom'));
    FlxG.mouse.visible = true;
    add(bg);
    
    add(diffSprite);
    for (i in [leftArrow, rightArrow]) {
        i.setPosition(diffAnchorX - i.width * 0.5, 70);
    }
    leftArrow.x  -= 152.5;
    rightArrow.x += 152.5;
    add(leftArrow);
    add(rightArrow);

    add(stupidDadBG);

    add(capsuleGroup);
    
    fgBar.scrollFactor.set();
    fgBar.makeGraphic(FlxG.width, 64, -1);
    fgBar.color = FlxColor.BLACK;
    add(fgBar);

    var freeplayName = new FunkinText(8, 8, FlxG.width - 16, 'FREEPLAY', 48); // ik its static but this is nicer ok
    freeplayName.scrollFactor.set();
    add(freeplayName);

    ostName.scrollFactor.set();
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
    fpList.songs.insert(0, null); // random
    var stupid = 0;
    while (stupid < fpList.songs.length) {
        var i = fpList.songs[stupid++];
        if (i == null) continue;
        /*
            this is to avoid scanning every single chart
            to get player 1 character
        */

        var foundAlt = false;
        if ((i?.player ?? 'bf') != character) {
            // scan all variations (for example darnell bf mix)
            for (vn => vm in i.metas) {
                if ((vm?.player ?? (validCharVariations.contains(vn) ? vn : 'bf')) == character) {
                    fpMap.set(i.name.toLowerCase(), vm);
                    foundAlt = true;
                    break;
                }
            }
            if (!foundAlt) {
                fpList.songs.remove(i);
                stupid--;
                continue;
            }
        }
        if (fpMap[i.name.toLowerCase()] == null) {
            fpMap.set(i.name.toLowerCase(), i);
        }

        /*
        var newStuff = fpMap[i.name.toLowerCase()];
        for (d in newStuff.difficulties) {
            if (!allDifficulties.contains(d))
                allDifficulties.push(d.toLowerCase());
        }

        for (v in newStuff.variants) {
            if (!allVariations.contains(v))
                allVariations.push(v.toLowerCase());
        }
        */
    }
    //trace(fpMap);
    for (i in swList.weeks) {
        for (k in i.songs) {
            if (!Reflect.hasField(fpMap[k.name.toLowerCase()], 'week'))
                Reflect.setField(fpMap[k.name.toLowerCase()], 'week', i.id);
        }
    }

    for (x => i in fpList.songs) {
        var c = new Capsule();
        c.x = FlxG.width;
        c.y = x * 140;
        c.ID = x;
        capsuleGroup.add(c);

        c.loadData(i == null ? null : fpMap.get(i.name));
        c.deselect();
    }

    capsuleGroup.setPosition(FlxG.width * 0.5 - 245, FlxG.height * 0.5 - 111);

    curSelected = lerpSelected = Math.min(capsuleGroup.length, 1);
    curSelectedDiff = allDifficulties.indexOf(Options.freeplayLastDifficulty.toLowerCase());
    if (curSelectedDiff < 0) {
        curSelectedDiff = allDifficulties.indexOf(Options.freeplayLastDifficulty = 'normal');
    }
    changeDifficulty(0); // it also calls changeSelection

    Framerate.offset.y = 65;
}
var curSelected = 0;
var curSelectedDiff = -1;
var lerpSelected = 0;
var intendedScore = 0;
var lerpScore = 0;
var intendedAccuracy = 0;
var lerpAccuracy = 0;
var enableControls = true;
function update(elapsed) {
    if (enableControls) {
        for (basic in turboBasics) {
            basic.update(elapsed);
        }

        if (upTurboControl.activated || FlxG.mouse.wheel == 1) changeSelection(-1);
        if (downTurboControl.activated || FlxG.mouse.wheel == -1) changeSelection(1);

        if (controls.LEFT_P) changeDifficulty(-1);
        if (controls.RIGHT_P) changeDifficulty(1);

        if (FlxG.keys.justPressed.HOME) {
            changeSelection(-curSelected);
        }
        if (FlxG.keys.justPressed.END) {
            changeSelection(capsuleGroup.members.length - 1 - curSelected);
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
        if (enableControls && CoolUtil.mouseOverlaps(c) && FlxG.mouse.justPressed) {
            if (curSelected == c.ID) {
                selectSong(c.ID);
            } else changeSelection(c.ID - curSelected);
        }
        var diff = c.ID - lerpSelected;
        c.x = capsuleGroup.x + Math.sin(diff + 0.98) * 60 - 60;
        c.y = capsuleGroup.y + (diff + Math.min((diff - 1) * 0.9 + 1, -1) + 1) * 115.5;
                                                // so u can click on the bar to
                                                // select the song behind it
    });
}
function destroy() {
	for (basic in turboBasics) basic.destroy();
    Framerate.offset.y = 0;
}
function changeSelection(ch) {
    var pastSelected = curSelected;
    curSelected = FlxMath.wrap(curSelected + ch, 0, capsuleGroup.members.length - 1);

    if (capsuleGroup.members[pastSelected] != null)
        capsuleGroup.members[pastSelected].deselect();

    if (capsuleGroup.members[curSelected] != null)
        capsuleGroup.members[curSelected].select();

    if (ch != 0) CoolUtil.playMenuSFX(0);

    final name = capsuleGroup.members[curSelected].name;
    final save = name != null ? (FunkinSave.getSongHighscore(
        name,
        allDifficulties[curSelectedDiff],
        fpMap[name].variant
    )) : null;

    intendedScore = save?.score ?? 0;
    intendedAccuracy = save?.accuracy ?? 0;
}
function changeDifficulty(ch) {
    var pastSelectedDiff = curSelectedDiff;
    curSelectedDiff = FlxMath.wrap(curSelectedDiff + ch, 0, allDifficulties.length - 1);
    if (ch != 0) CoolUtil.playMenuSFX(0);

    final diff = allDifficulties[curSelectedDiff];
    diffSprite.loadSprite(Paths.image('menus/freeplay/difficulties/' + diff));
    if (diffSprite.frames is FlxAtlasFrames) {
        diffSprite.addAnim('idle', 'idle0', 24, true);
        diffSprite.playAnim('idle', true);
    }
    diffSprite.updateHitbox();
    diffSprite.setPosition(diffAnchorX, 116);
    diffSprite.x -= diffSprite.width * 0.5;
    diffSprite.y -= diffSprite.height * 0.5;

    final displacement = FlxMath.signOf(ch) * 400;
    if (displacement != 0) {
        diffSprite.x += displacement;
        FlxTween.cancelTweensOf(diffSprite, ['x']);
        FlxTween.tween(diffSprite, {x: diffSprite.x - displacement}, 0.2, {ease: FlxEase.circInOut});
    }


    changeSelection(0);
}
function selectSong(id) {
    enableControls = false;
    if (id == 0) {
        // no songs
        if (capsuleGroup.members.length > 1) {
            changeSelection(id = FlxG.random.int(1, capsuleGroup.members.length - 1));
            new FlxTimer().start(0.4, (_) -> { selectSong(curSelected); });
        }
        else CoolUtil.playMenuSFX(2);
        return;
    }
    if (capsuleGroup.members[id] != null) {
        CoolUtil.playMenuSFX(1);
        var c = capsuleGroup.members[id];
        if (c.icon.visible) c.icon.playAnim('confirm', true);

        bg.select();
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