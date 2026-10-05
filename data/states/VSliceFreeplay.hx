import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;
import funkin.backend.chart.Chart;
import funkin.menus.FreeplaySonglist;
import funkin.menus.StoryWeeklist;
import funkin.backend.system.Control;
import funkin.backend.TurboControls;
import funkin.backend.TurboBasic;
import flixel.math.FlxRect;

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
        new GlowFilter(glowColor, 1, 4, 4, 255),
        new GlowFilter(0xffffff, 1, 2, 2, 210),
    ];
    public var notCoolFilters = [
        new GlowFilter(0xffffff, 1, 2, 2, 210),
    ];
    public function new() {
        super();

        final realScaled = 0.8;

        loadSprite(Paths.image('menus/freeplay/freeplayCapsule'));
        addAnim('idle', 'mp3 capsule w backing NOT SELECTED', 24, true);
        addAnim('select', 'mp3 capsule w backing0', 24, true);
        playAnim('idle', true);
        scale.set(realScaled, realScaled);
        updateHitbox();

        text = new FunkinText(0, 0, -1, 'Bro', Std.int(40 * realScaled));
        text.font = Paths.font('5by7.ttf');
        text.borderSize = text.borderColor = 0;
        text.textField.filters = coolFilters;
        text.clipRect = new FlxRect(0, 0, text.width, text.height);

        weekText = new FunkinText(0, 0, 200, 'Week 8');
        bpmText = new FunkinText(0, 0, 200, 'BPM 190');
        diffStaticText = new FunkinText(0, 0, -1, 'Difficulty');
        diffText = new FunkinText(0, 0, -1, '21');
        /*
        var capsuleOuterFilter = [
            new GlowFilter(0x21242E, 2, 4, 4, 210, true, true),
        ];;
        */

        for (i in [weekText, bpmText, diffStaticText, diffText]) {
            i.font = Paths.font("YoureGone-Regular.otf");
            i.size = 20;
            i.borderSize = i.borderColor = 0;
            /*
            // use this when GlowFilter.inner works
            weekText.color = 0x413d4b;
            weekText.textField.filters = capsuleOuterFilter
            */
            i.color = 0x21242E;
        }

        diffText.size = 48;

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

        drawThing(text, 95 + clipTransTimer * Math.min(0, clipWidth - text.width), 34);
        drawThing(weekText, 220, 74);
        drawThing(bpmText, 82, 74);
        drawThing(diffStaticText, 465 - diffStaticText.width, 74);
        drawThing(diffText, 438 - (diffText.width * 0.5), 20);
        drawThing(icon, icon.width * -0.5 + 40, icon.height * -0.5 + 40);
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
        if (meta == null) {
            icon.visible = bpmText.visible = weekText.visible = diffStaticText.visible = diffText.visible = false;
            text.text = 'Random';
            return;
        }
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
        diffText.text = '??';
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
        text.alpha = 1;
        selected = true;
        clipTimer = 0;
        text.textField.filters = coolFilters;
        text._regen = true; // this sucks
    }
    public function deselect() {
        playAnim('idle', true);
        text.alpha = 0.5;
        selected = false;
        clipTimer = 0;
        text.textField.filters = notCoolFilters;
        text._regen = true; // i need to find smth better (maybe shader????)
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// turbo controls, used in options menu, useful for rpeating keys
var upTurboControl = new TurboControls([Control.UP]);
var downTurboControl = new TurboControls([Control.DOWN]);
var turboBasics = [upTurboControl, downTurboControl];
var capsuleGroup = new FlxSpriteGroup();
var fpList = FreeplaySonglist.get();
var swList = StoryWeeklist.get(null, false);
var fpMap = ['' => 'hi im a map'];
var character = 'bf';

function postCreate() {
    add(capsuleGroup);

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
            for (vm in i.metas) {
                if ((vm?.player ?? 'bf') == character) {
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

    capsuleGroup.setPosition(FlxG.width * 0.5 - 250, FlxG.height * 0.5 - 80);

    changeSelection(0);
}
var curSelected = 0;
var lerpSelected = 0;
function update(elapsed) {
    for (basic in turboBasics) {
        basic.update(elapsed);
    }

    if (upTurboControl.activated || FlxG.mouse.wheel == 1) changeSelection(-1);
    if (downTurboControl.activated || FlxG.mouse.wheel == -1) changeSelection(1);

    lerpSelected = lerp(lerpSelected, curSelected, 0.25);

    capsuleGroup.forEach((c) -> {
        var diff = c.ID - lerpSelected;
        c.x = capsuleGroup.x + Math.pow(diff, 2) * -12 + diff * 20;
        c.y = capsuleGroup.y + (diff + Math.min(diff, -1) + 1) * 130;
    });
}
function destroy() {
	for (basic in turboBasics) basic.destroy();
}
function changeSelection(ch) {
    var pastSelected = curSelected;
    curSelected = FlxMath.wrap(curSelected + ch, 0, fpList.songs.length - 1);

    if (capsuleGroup.members[pastSelected] != null)
        capsuleGroup.members[pastSelected].deselect();

    if (capsuleGroup.members[curSelected] != null)
        capsuleGroup.members[curSelected].select();
}