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
    function makeTextBackdrop(text, ?size) {
        var dumpTxt = new FunkinText();
        dumpTxt.font = Paths.font('5by7.ttf');
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
    var bg:FunkinSprite;
    var bgColor:FunkinSprite;
    var bgGradient:FunkinSprite;
    var backdrops = [];
    public function new() {
        super();

        bgColor = new FunkinSprite();
        bgColor.makeSolid(FlxG.width, FlxG.height, -1);
        bgColor.color = 0xffe26c;
        bgColor.updateHitbox();
        bgColor.screenCenter();
        add(bgColor);

        bgGradient = new FunkinSprite();
        bgGradient.loadGraphic(Paths.image('menus/freeplay/transitionGradient'));
        bgGradient.setGraphicSize(FlxG.width * 0.5, FlxG.height);
        bgGradient.colorTransform.color = 0xffd863;
        bgGradient.flipY = true;
        bgGradient.updateHitbox();
        add(bgGradient);

        var startY = (FlxG.height * 0.5) - 201;
        var text1 = { color: 0xFFff9963 };
        var text2 = { color: 0xFFfff383 };
        var text3 = { color: 0xFFffffff };
        for (x => i in [
            text2,
            text1,
            text3,
            text1,
            text2,
            text1
        ]) {
            var backdrop = makeTextBackdrop('MY EARS BURN ', (x % 2 == 1) ? 58 : 42);
            backdrop.color = i.color;
            backdrop.screenCenter();
            backdrop.y = startY;
            backdrop.velocity.x = 200 * ((x % 2 == 0) ? -1 : 1) * ((x % 4 == 0) ? 2 : 1);
            backdrop.repeatAxes = 0x01;
            add(backdrop);
            backdrops.push(backdrop);

            startY += backdrop.height + 20;
            if (x == 2) startY -= 10; // ???
            else if (x > 2) startY -= 3;
        }

        /*
        no need to have this separate since it changes per character
        and so does the backing card part of it
        and since i dont think were gonna have the "new character unlocked" popup
        theres no reason to separate it then
        */
        bg = new FunkinSprite();
        bg.loadGraphic(Paths.image('menus/freeplay/freeplayBGweek1-bf'));
        bg.setGraphicSize(null, FlxG.height);
        bg.antialiasing = true;
        bg.updateHitbox();
        bg.screenCenter();
        bg.x += FlxG.width * 0.25;
        add(bg);
        bg.shader = new FunkinShader('
        #pragma header
        void main() {
            vec2 uv = openfl_TextureCoordv;
            float slice = 0.11;
            gl_FragColor = flixel_texture2D(bitmap, uv) * smoothstep(slice, slice + 0.0016, uv.x + ((1.0 - uv.y) * 0.11));
        }
        ');
    }

    public function select() {
        for (i in backdrops) {
            FlxTween.tween(i, {alpha: 0}, 0.3);
        }
        FlxTween.tween(bg.colorTransform, {
            redMultiplier: 0.5,
            greenMultiplier: 0.5,
            blueMultiplier: 0.5
        }, 0.5, {ease: FlxEase.sineOut});
    }

    // to character select
    public function switch() {
        for (i in backdrops) {
            FlxTween.tween(i.velocity, {x: 0}, 1);
        }
    }
}

public function getBackground() {
    return new BackingCard();
}