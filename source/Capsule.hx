import FunkinGroup;
import CustomGroup;
import openfl.filters.BlurFilter;
import openfl.filters.GlowFilter;

class Capsule extends FunkinGroup {
    // TODO: make everything revolve around this
    // this is the default meta.json
    // future betty here: ok so i kinda lied
    public var meta:Dynamic;

    // this can be any meta
    public var curMeta:Dynamic;

    public var capsule:FunkinSprite;
    public var text:FunkinText;
    public var textBlur:FunkinText;
    public var weekText:FunkinText;
    public var bpmText:FunkinText;
    public var bpmStaticText:FunkinText;
    public var diffStaticText:FunkinText;
    public var diffText:FunkinText; // numbers
    public var icon:FunkinSprite;
    public var rankBadge:FunkinSprite;
    public var rankBadgeBlur:FunkinSprite; // KILL FUNKIN CREW
    public var goldSparkle:FunkinSprite;
    public var glowColor:Int = 0x00ccff;
    public var glowColor2:Int = 0x00ccff; // for when styles are implemented
    public var clipWidth:Int = 290; // 245 with rank
    public var selected:Int = false;
    public function new() {
        super();

        final realScaled = 0.8;

        antialiasing = true;
        capsule = new FunkinSprite(0, 0, Paths.image('menus/freeplay/freeplayCapsule'));
        capsule.addAnim('idle', 'mp3 capsule w backing NOT SELECTED', 24, Options.flashingMenu);
        capsule.addAnim('select', 'mp3 capsule w backing0', 24, Options.flashingMenu);
        capsule.playAnim('idle', true);
        capsule.scale.set(realScaled, realScaled);
        capsule.updateHitbox();
        capsule.antialiasing = true;

        rankBadge = new FunkinSprite(0, 0, Paths.image('menus/freeplay/rankbadges'));
        rankBadgeBlur = new FunkinSprite(0, 0, Paths.image('menus/freeplay/rankbadges'));
        //rankBadgeBlur.shader = whySoManyDetailOMFG;
        for (j in [rankBadge, rankBadgeBlur]) {
            for (i in ['perfect', 'excellent', 'great', 'good', 'loss']) {
                j.addAnim(i, i.toUpperCase() + ' rank0', 24, false);
            }
            j.addAnim('perfect-gold', 'PERFECT rank GOLD', 24, false);
            j.playAnim('perfect-gold', true);
            j.scale.set(0.9, 0.9);
            j.updateHitbox();
            j.blend = BlendMode.ADD;
            j.antialiasing = true;
            j.visible = false;
        }

        goldSparkle = new FunkinSprite(0, 0, Paths.image('menus/freeplay/sparkle'));
        goldSparkle.addAnim('idle', 'sparkle Export', 24, false);
        goldSparkle.playAnim('idle', true);
        goldSparkle.scale.set(0.8, 0.8);
        goldSparkle.updateHitbox();
        goldSparkle.blend = BlendMode.ADD;
        goldSparkle.antialiasing = true;
        goldSparkle.alpha = 0.7;

        text = new FunkinText(0, 0, -1, 'Bro', Math.floor(40 * realScaled));
        text.font = Paths.font('5by7.ttf');
        text.borderSize = text.borderColor = 0;
        text.rawClipRect = new FlxRect(0, 0, text.width, text.height);
        text.antialiasing = true;
        text.blend = BlendMode.ADD;

        textBlur = new FunkinText(0, 0, -1, 'Bro', Math.floor(40 * realScaled));
        textBlur.font = Paths.font('5by7.ttf');
        textBlur.borderSize = textBlur.borderColor = 0;
        textBlur.rawClipRect = new FlxRect(0, 0, textBlur.width, textBlur.height);
        textBlur.antialiasing = true;

        weekText = new FunkinText(0, 0, 300, 'week 8');
        bpmStaticText = new FunkinText(0, 0, 100, 'bpm'); // the M is fucky and is only accurate is theres nothing after it (im guessing ligatures)
        bpmText = new FunkinText(0, 0, 300, '190');
        diffStaticText = new FunkinText(0, 0, -1, 'difficulty');
        diffText = new FunkinText(0, 0, -1, '00');
        
        /*var capsuleOuterFilter = [
            // 0x1A1C24
            new GlowFilter(0xffffff, 1, 5, 5, 3.13, 1),
        ];*/

        for (i in [weekText, bpmText, bpmStaticText, diffStaticText, diffText]) {
            i.font = Paths.font("YoureGone-Regular.otf");
            i.size = 20;
            i.antialiasing = true;
            i.borderSize = i.borderColor = 0;
            i.scale.set(0.9, 0.9);
            i.updateHitbox();
            
            // use this when GlowFilter.inner works
            /*capsuleOuterFilter[0].inner = true;

            i.color = 0x413d4b;
            i.textField.filters = capsuleOuterFilter;*/
            // for now use this
            //i.shader = HANG_FUNKIN_CREW_BY_JUMPER_CABLES;
            i.color = 0x1A1C24;
        }

        diffText.size = 46;
        diffText.scale.set(1, 1);
        diffText.updateHitbox();
        diffText.letterSpacing = -1;

        icon = new FunkinSprite();
        icon.visible = false;
        icon.pixelPerfectRender = true;

        // KILL FUNKIN CREW
        for (i in [
            capsule, weekText,
            bpmStaticText, bpmText,
            diffStaticText, diffText, 
            textBlur, text, rankBadgeBlur,
            rankBadge, icon
        ]) {
            add(i);
        }
    }
    override public function draw() {
        var clipTransTimer:Float = FlxEase.sineInOut(FlxMath.bound((0.5 - Math.abs(FlxMath.mod(clipTimer * 0.4, 2) - 1)) * 1.3 + 0.5, 0, 1));
        text.rawClipRect = text.rawClipRect.set(
            clipTransTimer * -Math.min(0, clipWidth - text.width),
            0, Math.min(text.width, clipWidth), text.height
        );
        textBlur.rawClipRect = textBlur.rawClipRect.set(text.rawClipRect.x, text.rawClipRect.y, text.rawClipRect.width, text.rawClipRect.height);
        
        text.setPosition(92 - text.rawClipRect.x, 32);
        textBlur.setPosition(text.x, text.y);
        weekText.setPosition(228, 76);
        bpmStaticText.setPosition(79, 76);
        bpmText.setPosition(123, 76);
        diffStaticText.setPosition(354, 76);
        diffText.setPosition(400, 18);
        // looks stupid i know but ehhh
        if (diffText.text.substr(0, 1) == '1') {
            diffText.x += 3;
            diffText.letterSpacing = 6;
        } else {
            diffText.letterSpacing = -1;
        }
        rankBadge.setPosition(354, 28);
        rankBadgeBlur.setPosition(rankBadge.x, rankBadge.y);
        rankBadgeBlur.visible = rankBadge.visible;
        icon.setPosition(94, 22);

        setSize(capsule.width, capsule.height);

        super.draw();
    }
    public var clipTimer:Float = 0;
    override public function update(elapsed) {
        super.update(elapsed);

        if (icon.getAnimName('confirm') && icon.isAnimAtEnd()) {
            icon.playAnim('confirm-hold');
        }

        if (selected) clipTimer += elapsed;

        if (rank == 'perfect-gold') {
            goldRankTimer -= elapsed;
            if (goldRankTimer <= 0) {
                goldRankTimer = FlxG.random.float(1.2, 4.5);

                goldSparkle.x = rankBadge.x + FlxG.random.float(-20, 3);
                goldSparkle.y = rankBadge.y + FlxG.random.float(-29, 4);
                goldSparkle.playAnim('idle', true);
            }
        }
    }

    public function loadData(meta:Dynamic) {
        var hasChanged = (curMeta != meta);
        curMeta = meta;

        // random capsule
        name = null;
        if (meta == null) {
            for (i in [icon, bpmText, bpmStaticText, weekText, diffStaticText, diffText]) {
                i.visible = false;
            }
            textBlur.text = text.text = 'Random';
            return;
        }
        name = meta.name;
        var imagePath = Paths.image('menus/freeplay/icons/${meta.icon ?? 'face'}');
        if (Assets.exists(imagePath)) {
            icon.visible = true;
            icon.loadSprite(imagePath);
            icon.addAnim('idle', 'idle', 12, true);
            icon.addAnim('confirm', 'confirm0', 12, false);
            icon.addAnim('confirm-hold', 'confirm-hold', 12, true);
            icon.playAnim('idle', true);
            icon.scale.set(2, 2);
            //icon.updateHitbox();

            switch (meta.icon ?? 'face') {
                case 'parents-christmas':
                    icon.origin.x = 140;
                case 'sserafim-kazuha': // not coming but idc
                    icon.origin.x = 195;
                default:
                    icon.origin.x = 100;
            }
        } else {
            icon.visible = false;
        }

        if (hasChanged) clipTimer = 0;
        textBlur.text = text.text = meta.displayName ?? meta.name;
        bpmText.text = CoolUtil.addZeros(meta.bpm ?? 0, 3);

        // KILL FUNKIN CREW
        var finalWeekText = this.meta?.week;
        if (Reflect.hasField(this.meta, 'parent')) {
            finalWeekText = this.meta.parent.week;
        }

        weekText.text = getLevelIDClean(finalWeekText ?? '');
    }
    var __nullCoalescingHatesMe = [];
    public function setDifficultyText(?num:Int = 0) {
        diffText.text = CoolUtil.addZeros(num, 2);
    }
    public var rank:String = null;
    public var goldRankTimer:Float = 0;
    public function setRankFromHighscore(hi:Dynamic) {
        var wasVisible = rankBadge.visible;
        rankBadge.visible = (hi != null) && (hi.accuracy > 0);
        clipWidth = 290;
        rank = null;
        if (!rankBadge.visible) return;

        clipWidth = 245;
        if (hi.accuracy >= 1) {
            rank = 'perfect-gold';
            if (hi.hits['good'] > 0)
                rank = 'perfect';
            else {
                if (members.indexOf(goldSparkle) == -1) add(goldSparkle);
            }
        } else if (hi.accuracy >= 0.9) {
            rank = 'excellent';
        } else if (hi.accuracy >= 0.8) {
            rank = 'great';
        } else if (hi.accuracy >= 0.69) {
            rank = 'good';
        } else {
            rank = 'loss';
        }
        rankBadge.playAnim(rank, true);
        rankBadgeBlur.playAnim(rank, true);
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
        capsule.playAnim('select', true);
        capsule.centerOffsets(false);
        textBlur.alpha = text.alpha = 1;
        selected = true;
        rankBadge.color = rankBadgeBlur.color = -1;
        text.blend = null;
    }
    public function deselect() {
        capsule.playAnim('idle', true);
        capsule.centerOffsets(false);
        text.alpha = 0.6;
        textBlur.alpha = 0;
        selected = false;
        rankBadge.color = 0xaaaaaa;
        rankBadgeBlur.color = 0xdddddd;
        text.blend = BlendMode.ADD;
    }
}