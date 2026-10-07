import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;

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
    blur += texture2D(bitmap, uv + size * vec2(0.0,  3.0)).a * 0.5;
    blur += texture2D(bitmap, uv + size * vec2(0.0, -3.0)).a * 0.5;
    blur += texture2D(bitmap, uv + size * vec2( 3.0, 0.0)).a * 0.5;
    blur += texture2D(bitmap, uv + size * vec2(-3.0, 0.0)).a * 0.5;
    blur /= 18.0;
	gl_FragColor *= smoothstep(0.0, 0.6, 1.0 - blur);
}
');

class Capsule extends FunkinSprite {
    // TODO: make everything revolve around this
    // this is the default meta.json
    public var meta:Dynamic;

    // this can be any meta
    public var curMeta:Dynamic;
    public var displayID:Int = 0;
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
        new GlowFilter(glowColor, 1, 11, 9, 0, 1),
    ];
    public var notCoolFilters = [
        new GlowFilter(0xffffff, 0.6, 2, 2, 210),
        new GlowFilter(glowColor, 1, 8, 8, 0, 0),
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
        text.antialiasing = true;

        weekText = new FunkinText(0, 0, 300, 'Week 8');
        bpmText = new FunkinText(0, 0, 300, 'BPM 190');
        diffStaticText = new FunkinText(0, 0, -1, 'Difficulty');
        diffText = new FunkinText(0, 0, -1, '00');
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
            i.color = 0x161920;
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
            Math.floor(clipTransTimer * -Math.min(0, clipWidth - text.width)),
            0, Math.min(text.width, clipWidth), text.height);

        drawThing(text, 92 + Math.ceil(clipTransTimer * Math.min(0, clipWidth - text.width)), 32);
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
        var hasChanged = (curMeta != meta);
        curMeta = meta;

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

            switch (meta.icon ?? 'face') {
                case 'parents-christmas':
                    icon.offset.x += 45;
                case 'sserafim-kazuha': // not coming but idc
                    icon.offset.x += 100;
            }
        } else {
            icon.visible = false;
        }

        if (hasChanged) clipTimer = 0;
        text.text = meta.displayName ?? meta.name;
        bpmText.text = 'BPM ' + CoolUtil.addZeros(meta.bpm ?? 0, 3);
        weekText.text = getLevelIDClean(this.meta?.week ?? '');
    }
    public function setDifficultyText(?num:Int = 0) {
        diffText.text = CoolUtil.addZeros(num, 2);
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
        text.textField.filters = coolFilters;
        text._regen = true; // this sucks
    }
    public function deselect() {
        playAnim('idle', true);
        centerOffsets(false);
        text.alpha = 0.5;
        selected = false;
        text.textField.filters = notCoolFilters;
        text._regen = true; // i need to find smth better (maybe shader????)
    }
}