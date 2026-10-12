// vslice ahh approach
// but may help extend to more backcards in the future

import CustomGroup;
import flixel.addons.display.FlxBackdrop;

/*
required functions are
- select()
- enter() (soon)
- exit() (soon)
- selectSong(meta) (soon) (well only in case spaghetti exists)
- switch() (for character select)
*/
class BackingCard extends CustomGroup {
    
    var bg:FunkinSprite; // required, this is the dad bg
    var bgColor:FunkinSprite;
    var bgGradient:FunkinSprite;
    var confirmGlow:FunkinSprite;
    var confirmText:FunkinSprite;
    var confirmTextGlow:FunkinSprite;
    var backdrops = [];
    public function new() {
        super();

        bgColor = new FunkinSprite();
        bgColor.makeSolid(FlxG.width, FlxG.height, -1);
        bgColor.color = 0x333366;
        bgColor.updateHitbox();
        bgColor.screenCenter();
        add(bgColor);

        bgGradient = new FunkinSprite();
        bgGradient.loadGraphic(Paths.image('menus/freeplay/transitionGradient'));
        bgGradient.setGraphicSize(FlxG.width * 0.5, FlxG.height);
        bgGradient.colorTransform.color = 0x223f66;
        bgGradient.flipY = true;
        bgGradient.updateHitbox();
        add(bgGradient);

        confirmGlow = new FunkinSprite(FlxG.width * 0.17, FlxG.height * 0.5);
        confirmGlow.loadGraphic(Paths.image('menus/freeplay/confirmGlow'));
        confirmGlow.x -= confirmGlow.width * 0.5;
        confirmGlow.y -= confirmGlow.height * 0.5;
        confirmGlow.visible = false;
        confirmGlow.blend = BlendMode.ADD;
        add(confirmGlow);

        var startY = (FlxG.height * 0.5) - 180;
        var text2 = { color: 0xFFfff383, text: 'NO BACKING CARD DETECTED !' };
        var text3 = { color: 0xFFffffff, text: 'PLACE YOURS IN /data/backcards/ !!!' };
        for (x => i in [
            text2,
            text3,
        ]) {
            var backdrop = makeTextBackdrop(i.text + ' ', false, 43);
            backdrop.color = i.color;
            backdrop.screenCenter();
            backdrop.y = startY;
            backdrop.velocity.x = -200 * ((x % 2 == 0) ? -1 : 1);
            backdrop.repeatAxes = 0x01;
            add(backdrop);
            backdrops.push(backdrop);

            startY += backdrop.height + 15;
        }

        confirmTextGlow = new FunkinSprite(FlxG.width * 0.17, FlxG.height * 0.5 - 57);
        confirmTextGlow.loadGraphic(Paths.image('menus/freeplay/glowingText'));
        confirmTextGlow.x -= confirmTextGlow.width * 0.5;
        confirmTextGlow.y -= confirmTextGlow.height * 0.5;
        confirmTextGlow.visible = false;
        confirmTextGlow.blend = BlendMode.ADD;
        add(confirmTextGlow);

        confirmText = new FunkinSprite(FlxG.width * 0.17, FlxG.height * 0.5 - 57);
        confirmText.loadSprite(Paths.image('menus/freeplay/backing-text-yeah'));
        confirmText.addAnim('hi', 'BF back card confirm raw', 24, false, null, null, -8, -12);
        confirmText.playAnim('hi', true);
        confirmText.updateHitbox();
        confirmText.applyStageMatrix = false;
        confirmText.x -= confirmText.width * 0.5;
        confirmText.y -= confirmText.height * 0.5;
        confirmText.visible = false;
        add(confirmText);
    }

    public function select() {
        for (i in backdrops) {
            i.visible = false;
        }
        bgGradient.visible = false;
        FlxTween.tween(bg.colorTransform, {
            redMultiplier: 0.5,
            greenMultiplier: 0.5,
            blueMultiplier: 0.5
        }, 0.5, {ease: FlxEase.sineOut});
        FlxTween.color(bgColor, 0.33, 0xFFffffff, 0xFF171831, {ease: FlxEase.quadOut});

        confirmText.playAnim('hi', true);
        confirmGlow.visible = confirmText.visible = true;
        confirmGlow.alpha = 0;
        confirmGlow.color = 0x7f7f7f; // i will Not add confirmGlow2
        FlxTween.tween(confirmGlow, {alpha: 0.5}, 0.33, {
            ease: FlxEase.quadOut,
            onComplete: function(_)
            {
                confirmGlow.alpha = 1;
                confirmGlow.color = 0x999999;
                confirmTextGlow.visible = true;
                confirmTextGlow.alpha = 1;
                FlxTween.tween(confirmTextGlow, {alpha: 0.4}, 0.5);
                FlxTween.tween(confirmGlow.colorTransform, {
                    redMultiplier: 0.5,
                    greenMultiplier: 0.5,
                    blueMultiplier: 0.5
                }, 0.5);
            }
        });
    }

    // to character select
    public function switch() {
        for (i in backdrops) {
            FlxTween.tween(i.velocity, {x: 0}, 1);
        }
    }
    
    function makeTextBackdrop(text, ?bold, ?size) {
        bold ??= false;
        var dumpTxt = new FunkinText();
        dumpTxt.font = Paths.font('5by7${bold ? '_bold' : ''}.ttf');
        dumpTxt.borderSize = 2;
        dumpTxt.borderColor = 0x0;
        dumpTxt.size = size;
        dumpTxt.text = text;
        dumpTxt.drawFrame(true);
        var txt = new FlxBackdrop().makeGraphic(dumpTxt.width, dumpTxt.height, FlxColor.TRANSPARENT);
        txt.stamp(dumpTxt);
        dumpTxt.destroy();
        return txt;
    }

    var timer:Float = 0;
    override public function update(elapsed:Float) {
        super.update(elapsed);
        timer += elapsed;
        backdrops[0].color = FlxColor.interpolate(0xff3333, 0xff99cc, (Math.sin(timer * 3) + 1) * 0.5);
    }
}

public function getBackground() {
    return new BackingCard();
}