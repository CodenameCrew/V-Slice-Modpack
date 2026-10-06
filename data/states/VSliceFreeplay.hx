import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;
import funkin.backend.chart.Chart;
import funkin.menus.FreeplaySonglist;
import funkin.menus.StoryWeeklist;
import funkin.backend.system.Control;
import funkin.backend.TurboControls;
import funkin.backend.TurboBasic;
import flixel.math.FlxRect;
import funkin.backend.system.framerate.Framerate;
import funkin.savedata.FunkinSave;

// no support for inner glow filter so this will do
var HANG_FUNKIN_CREW_BY_JUMPER_CABLES = new FunkinShader('
#pragma header

void main() {
    vec2 uv = openfl_TextureCoordv;
    gl_FragColor = flixel_texture2D(bitmap, uv);
    float blur = 0.0;
    vec2 size = vec2(0.02);
    blur += texture2D(bitmap, uv + size * vec2(0.0,  1.0)).a;
    blur += texture2D(bitmap, uv + size * vec2(0.0, -1.0)).a;
    blur += texture2D(bitmap, uv + size * vec2( 1.0, 0.0)).a;
    blur += texture2D(bitmap, uv + size * vec2(-1.0, 0.0)).a;
    blur += texture2D(bitmap, uv + size * vec2(0.0,  2.0)).a * 2.0;
    blur += texture2D(bitmap, uv + size * vec2(0.0, -2.0)).a * 2.0;
    blur += texture2D(bitmap, uv + size * vec2( 2.0, 0.0)).a * 2.0;
    blur += texture2D(bitmap, uv + size * vec2(-2.0, 0.0)).a * 2.0;
    blur /= 18.0;
	gl_FragColor *= smoothstep(0.0, 0.6, 1.0 - blur);
}
');

class Capsule extends FunkinSprite {
    public var text:FunkinText;
    public var weekText:FunkinText;
    public var bpmText:FunkinText;
    public var diffStaticText:FunkinText;
    public var diffText:FunkinText; // numbers
    public var icon:FunkinSprite;
    public var glowColor:Int = 0x00ccff;
    public var clipWidth:Int = 255;
    public var selected:Int = false;
    public var coolFilters = [
        new GlowFilter(0xffffff, 1, 2, 1, 150),
        new GlowFilter(glowColor, 1, 10, 10, 0, 0),
    ];
    public var notCoolFilters = [
        new GlowFilter(0xffffff, 0.6, 2, 2, 210),
        new GlowFilter(glowColor, 1, 6, 6, 0, 0),
    ];
    public function new() {
        super();

        final realScaled = 0.8;

        antialiasing = true;
        loadSprite(Paths.image('menus/freeplay/freeplayCapsule'));
        addAnim('idle', 'mp3 capsule w backing NOT SELECTED', 24, true);
        addAnim('select', 'mp3 capsule w backing0', 24, true);
        playAnim('idle', true);
        scale.set(realScaled, realScaled);
        updateHitbox();

        text = new FunkinText(0, 0, -1, 'Bro', Math.floor(40 * realScaled));
        text.font = Paths.font('5by7.ttf');
        text.borderSize = text.borderColor = 0;
        text.textField.filters = coolFilters;
        text.clipRect = new FlxRect(0, 0, text.width, text.height);

        weekText = new FunkinText(0, 0, 300, 'Week 8');
        bpmText = new FunkinText(0, 0, 300, 'BPM 190');
        diffStaticText = new FunkinText(0, 0, -1, 'Difficulty');
        diffText = new FunkinText(0, 0, -1, '21');
        /*
        var capsuleOuterFilter = [
            new GlowFilter(0x21242E, 2, 4, 4, 210, true, true),
        ];;
        */

        for (i in [weekText, bpmText, diffStaticText, diffText]) {
            i.font = Paths.font("YoureGone-Regular.otf");
            i.size = 18;
            i.antialiasing = true;
            i.borderSize = i.borderColor = 0;
            /*
            // use this when GlowFilter.inner works
            weekText.color = 0x413d4b;
            weekText.textField.filters = capsuleOuterFilter
            */
            // for now use this
            i.shader = HANG_FUNKIN_CREW_BY_JUMPER_CABLES;
            i.color = 0x21242E;
        }

        diffText.size = 46;
        diffText.letterSpacing = -1;

        icon = new FunkinSprite();
        icon.visible = false;
    }
    override public function destroy() {
        for (i in [text, weekText, bpmText, diffStaticText, diffText]) {
            i.destroy();
        }
        super.destroy();
    }
    override public function draw() {
        super.draw();

        function drawThing(s:FlxSprite, _x:Float, _y:Float) {
            if (s.visible && s.exists) {
                s.setPosition(x + _x, y + _y);
                s.draw();
            }
        }

        var clipTransTimer:Float = FlxEase.sineInOut(FlxMath.bound((0.5 - Math.abs(FlxMath.mod(clipTimer * 0.4, 2) - 1)) * 1.3 + 0.5, 0, 1));
        text.clipRect = text.clipRect.set(
            clipTransTimer * -Math.min(0, clipWidth - text.width),
            0, Math.min(text.width, clipWidth), text.height);

        drawThing(text, 92 + clipTransTimer * Math.min(0, clipWidth - text.width), 32);
        drawThing(weekText, 228, 76);
        drawThing(bpmText, 76, 76);
        drawThing(diffStaticText, 455 - diffStaticText.width, 76);
        drawThing(diffText, 433 - (diffText.width * 0.5), 18);
        drawThing(icon, -2, icon.height * -0.5 + 48);
    }
    public var clipTimer:Float = 0;
    override public function update(elapsed) {
        super.update(elapsed);
        icon.update(elapsed);
        if (icon.getAnimName('confirm') && icon.isAnimAtEnd()) {
            icon.playAnim('confirm-hold');
        }

        if (selected) clipTimer += elapsed;
    }

    public function loadData(meta:Dynamic) {
        // random capsule
        name = null;
        if (meta == null) {
            icon.visible = bpmText.visible = weekText.visible = diffStaticText.visible = diffText.visible = false;
            text.text = 'Random';
            return;
        }
        name = meta.name;
        var imagePath = Paths.image('menus/freeplay/icons/${meta.icon ?? 'face'}pixel'); // DIEEEEE FNF NAMING CONVENTIONSSSS
        if (Assets.exists(imagePath)) {
            icon.visible = true;
            icon.loadSprite(imagePath);
            icon.addAnim('idle', 'idle', 12, true);
            icon.addAnim('confirm', 'confirm0', 12, false);
            icon.addAnim('confirm-hold', 'confirm-hold', 12, true);
            icon.playAnim('idle', true);
            icon.scale.set(2, 2);
            icon.updateHitbox();
        } else {
            icon.visible = false;
        }

        text.text = meta.displayName ?? meta.name;
        bpmText.text = 'BPM ' + CoolUtil.addZeros(meta.bpm ?? 0, 3);
        weekText.text = getLevelIDClean(meta?.week ?? '');
        diffText.text = '00';
    }
    public function getLevelIDClean(id:String) {
        if (id.length < 1) return id;

        // no support for 'a'.code
        function code(a:String) return a.charCodeAt(0);
        var res = id.split('');
        var i = 0;
        var isNumber = FlxMath.inBounds(code(res[0]), 48, 57);
        // strings are immutable :( (whatever that means)
        while (i < res.length) {
            var a = res[i++];
            var thisIsNumber = FlxMath.inBounds(code(a), 48, 57);
            if (isNumber != thisIsNumber) {
                isNumber = thisIsNumber;
                res.insert(i - 1, ' ');
            }
        }
        return res.join('');
    }
    public function select() {
        playAnim('select', true);
        centerOffsets(false);
        text.alpha = 1;
        selected = true;
        clipTimer = 0;
        text.textField.filters = coolFilters;
        text._regen = true; // this sucks
    }
    public function deselect() {
        playAnim('idle', true);
        centerOffsets(false);
        text.alpha = 0.5;
        selected = false;
        clipTimer = 0;
        text.textField.filters = notCoolFilters;
        text._regen = true; // i need to find smth better (maybe shader????)
    }
}

class ScoreCounter extends FunkinSprite {
    var numbers = [];
    var numberString = ['ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE'];
    public function new() {
        super();
        for (i in 0...7) {
            var num = new FunkinSprite(i * 60, 0, Paths.image('menus/freeplay/digital_numbers'));
            for (x => j in numberString) {
                num.addAnim(Std.string(x), j + ' DIGITAL', 24, false, null, null, 
                    x == 1 ? -62 : 0 // ?????????????
                );
            }
            num.playAnim('0', true);
            num.scale.set(0.398, 0.398);
            num.antialiasing = true;
            num.updateHitbox();
            numbers.push(num);
        }
    }
    override public function update(elapsed) {
        if (!active || !exists) return;
        for (i in numbers) {
            if (i.active && i.exists) {
                i.update(elapsed);
            }
        }
    }
    override public function draw() {
        if (!visible || !exists) return;
        for (x => i in numbers) {
            if (i.visible && i.exists) {
                i.setPosition(this.x + 45 * x, this.y);
                i.draw();
            }
        }
    }

    public var value(default, set):Int = 0;
    public function set_value(v:Int) {
        value = v;
        for (x => i in numbers) {
            final targetAnim = Std.string(Std.int(value / Math.pow(10, numbers.length - x - 1)) % 10);
            if (i.getAnimName() != targetAnim) i.playAnim(targetAnim, true);
        }
        return value;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

// visuals
importScript('data/backcards/bf');
var bg = getBackground();
var fgBar = new FunkinSprite();
var ostName = new FunkinText(8, 8, FlxG.width - 16, 'OFFICIAL OST', 48);
var highscoreTxt = new FunkinSprite(0, 70, Paths.image('menus/freeplay/highscore'));
var highscoreAnimTimerForNoReason:Float = 0;
var clearBox = new FunkinSprite(0, 65, Paths.image('menus/freeplay/clearBox'));
var clearPercent = new Alphabet(0, 86, '100', 'freeplay-clear');
var scoreCounter = new ScoreCounter();

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

function create() {
    CoolUtil.playMusic(Paths.music('freeplayRandom'));
    FlxG.mouse.visible = true;
    add(bg);
    
    for (i in [leftArrow, rightArrow]) {
        i.setPosition(FlxG.width * 0.154 - i.width * 0.5, 70);
    }
    leftArrow.x  -= 152.5;
    rightArrow.x += 152.5;
    add(leftArrow);
    add(rightArrow);

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
    changeSelection(0);

    Framerate.offset.y = 65;
}
var curSelected = 0;
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
        CoolUtil.last(fpMap[name].difficulties), // add difficulties later
        fpMap[name].variant
    )) : null;

    intendedScore = save?.score ?? 0;
    intendedAccuracy = save?.accuracy ?? 0;
}
function selectSong(id) {
    enableControls = false;
    if (id == 0) {
        changeSelection(id = FlxG.random.int(1, capsuleGroup.members.length - 1));
        new FlxTimer().start(0.4, (_) -> { selectSong(curSelected); });
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
        highscoreAnimTimerForNoReason = 5;
        highscoreTxt.playAnim('idle', true);
    }

    lerpScore = lerp(lerpScore, intendedScore, 0.3);
    scoreCounter.value = Math.round(lerpScore);

    lerpAccuracy = lerp(lerpAccuracy, intendedAccuracy, 0.3);
    clearPercent.text = Math.round(lerpAccuracy * 100);
    clearPercent.x = clearBox.x + clearBox.width - 34 - clearPercent.textWidth;
}