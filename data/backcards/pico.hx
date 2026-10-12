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
    var scrollBack:FlxBackdrop;
    var scrollLower:FlxBackdrop;
    var scrollTop:FlxBackdrop;
    var scrollMiddle:FlxBackdrop;
    var glow:FlxSprite;
    var glowDark:FlxSprite;
    var blueBar:FlxSprite;
    var confirmAtlas:FunkinSprite;
    var backdrops;
    public function new() {
        super();

        bgColor = new FunkinSprite();
        bgColor.makeSolid(FlxG.width, FlxG.height, -1);
        bgColor.color = 0x98A2F3;
        bgColor.updateHitbox();
        bgColor.screenCenter();
        add(bgColor);
        
        scrollBack = new FlxBackdrop(Paths.image('menus/freeplay/backcards/pico/lower-loop'), 0x01, 20);
        scrollBack.setPosition(0, 200);
        scrollBack.flipX = true;
        scrollBack.alpha = 0.39;
        scrollBack.velocity.x = 110;
        add(scrollBack);

        scrollLower = new FlxBackdrop(Paths.image('menus/freeplay/backcards/pico/lower-loop'), 0x01, 20);
        scrollLower.setPosition(0, 406);
        scrollLower.velocity.x = -110;
        add(scrollLower);

        blueBar = new FlxSprite(0, 239).loadGraphic(Paths.image('menus/freeplay/backcards/pico/blue-bar'));
        blueBar.blend = BlendMode.MULTIPLY;
        blueBar.alpha = 0.4;
        blueBar.setGraphicSize(FlxG.width * 0.5, blueBar.height);
        blueBar.updateHitbox();
        blueBar.x = blueBar.width * -0.5;
        blueBar.x += FlxG.width * 0.16;
        add(blueBar);

        scrollTop = new FlxBackdrop(null, 0x01, 20);
        scrollTop.setPosition(0, 80);
        scrollTop.velocity.x = -220;
        scrollTop.frames = Paths.getFrames('menus/freeplay/backcards/pico/top-loop');
        for (i in ['uzi', 'sniper', 'rocket launcher', 'rifle']) {
            scrollTop.animation.addByPrefix(i, i + ' info', 24, false);
        }
        scrollTop.animation.addByPrefix('base', 'base', 24, false);
        scrollTop.animation.play('base');
        add(scrollTop);

        scrollMiddle = new FlxBackdrop(Paths.image('menus/freeplay/backcards/pico/middle-loop'), 0x01, 15);
        scrollMiddle.setPosition(0, 346);
        add(scrollMiddle);
        scrollMiddle.velocity.x = 220;

        backdrops = [scrollBack, scrollLower, scrollMiddle, scrollTop];

        confirmAtlas = new FunkinSprite(0, 55, Paths.image('menus/freeplay/backcards/pico/pico-confirm'));
        confirmAtlas.addAnim('wholeTimeline', confirmAtlas.library.timeline.name, 12, false, null,
        // my eyes dude
        !Options.flashingMenu ? [for (i in 0...10) i] : null
        );
        confirmAtlas.playAnim('wholeTimeline', true);
        confirmAtlas.antialiasing = true;
        confirmAtlas.setGraphicSize(FlxG.width * 0.61, null);
        confirmAtlas.updateHitbox();
        confirmAtlas.scrollFactor.set();
        // add(confirmAtlas);

        for (i in members) {
            i.scrollFactor.set();
        }
    }

    public function select() {
        for (i in backdrops) {
            i.visible = false;
        }
        add(confirmAtlas);
        confirmAtlas.playAnim('wholeTimeline', true);

        FlxTween.color(bg, 10 / 24, 0xFFFFFFFF, 0xFF8A8A8A);

        if (Options.flashingMenu) {
            for (i in [
                [0xFF343036, 0xFF696366, 10],
                [0xFF27292D, 0xFF686A6F, 14],
                [0xFF2D282D, 0xFF676164, 18],
                [0xFF29292F, 0xFF62626B, 21],
                [0xFF29232C, 0xFF808080, 24]
            ]) {
                // shoot
                new FlxTimer().start((i[2] / 24), (_) -> {
                    FlxTween.color(bg, 3 / 24, i[0], i[1], {
                        ease: FlxEase.expoOut,
                    });
                });
            }
        }
    }

    // to character select
    public function switch() {
        for (i in backdrops) {
            FlxTween.tween(i.velocity, {x: 0}, 0.8, {ease: FlxEase.sineIn});
        }
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        confirmAtlas.update(elapsed);
        var scrollProgress:Float = Math.abs(scrollTop.x % (scrollTop.frameWidth + 20));

        if (scrollTop.animation.curAnim.finished)
        {
            if (FlxMath.inBounds(scrollProgress, 500, 700) && scrollTop.animation.curAnim.name != 'sniper')
            {
                scrollTop.animation.play('sniper', true, false);
            }

            if (FlxMath.inBounds(scrollProgress, 700, 1300) && scrollTop.animation.curAnim.name != 'rifle')
            {
                scrollTop.animation.play('rifle', true, false);
            }

            if (FlxMath.inBounds(scrollProgress, 1450, 2000) && scrollTop.animation.curAnim.name != 'rocket launcher')
            {
                scrollTop.animation.play('rocket launcher', true, false);
            }

            if (FlxMath.inBounds(scrollProgress, 0, 300) && scrollTop.animation.curAnim.name != 'uzi')
            {
                scrollTop.animation.play('uzi', true, false);
            }
        }
    }
}

public function getBackground() {
    return new BackingCard();
}