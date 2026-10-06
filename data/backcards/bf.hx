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
    function makeTextBackdrop(text) {
        var dumpTxt = new FunkinText();
        dumpTxt.font = Paths.font('5by7.ttf');
        dumpTxt.borderSize = 2;
        dumpTxt.borderColor = 0x0;
        dumpTxt.size = 48;
        dumpTxt.text = text;
        dumpTxt.drawFrame(true);
        var txt = new FlxBackdrop().makeGraphic(dumpTxt.width, dumpTxt.height, FlxColor.TRANSPARENT);
        txt.stamp(dumpTxt);
        dumpTxt.destroy();
        return txt;
    }
    var bg:FunkinSprite;
    var bgColor:FunkinSprite;
    var backdrops = [];
    public function new() {
        super();

        bgColor = new FunkinSprite();
        bgColor.makeSolid(FlxG.width, FlxG.height, -1);
        bgColor.color = 0xffbc6a; // i have no internet as of writing this so its inaccurate
        bgColor.updateHitbox();
        bgColor.screenCenter();
        add(bgColor);

        var backdrop = makeTextBackdrop('MY EARS BURN ');
        backdrop.screenCenter();
        backdrop.velocity.x = -150;
        backdrop.repeatAxes = 0x01;
        add(backdrop);
        backdrops.push(backdrop);

        /*
        no need to have this separate since it changes per character
        and so does the backing card part of it
        and since i dont think were gonna have the "new character unlocked" popup
        theres no reason to separate it then
        */
        bg = new FunkinSprite();
        bg.loadGraphic(Paths.image('menus/freeplay/freeplayBGweek1-bf'));
        CoolUtil.setUnstretchedGraphicSize(bg, FlxG.width, FlxG.height);
        bg.antialiasing = true;
        bg.updateHitbox();
        bg.screenCenter();
        add(bg);
        bg.shader = new FunkinShader('
        #pragma header
        void main() {
            vec2 uv = openfl_TextureCoordv;
            float slice = 0.33;
            gl_FragColor = flixel_texture2D(bitmap, uv) * smoothstep(slice, slice + 0.0016, uv.x + ((1.0 - uv.y) * 0.08));
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