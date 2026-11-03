import CustomGroup;

class LetterSort extends CustomGroup {
    var leftArrow:FunkinSprite;
    var rightArrow:FunkinSprite;
    var separator:FunkinSprite;
    var sortSprite:FunkinSprite;
    public var sortReference = {
        array: null,
        curSelected: 0
    };
    public var __animTimer:Float = 0;
    public var __animMult:Float = 0;
    public var __uglyXOffset:Float = 0;
    public function new(array:Array) {
		super();
        sortReference.array = array;

        leftArrow = new FunkinSprite(0, 0, Paths.image('menus/freeplay/mini-arrow'));
        leftArrow.flipX = true;
        rightArrow = new FunkinSprite(400, 0, Paths.image('menus/freeplay/mini-arrow'));
        separator = new FunkinSprite(240, 5, Paths.image('menus/freeplay/separator'));
        sortSprite = new FunkinSprite(210, -20, Paths.image('menus/freeplay/sorts'));
        for (i in sortReference.array) {
            sortSprite.addAnim(i, i, 24, true);
        }
        sortSprite.playAnim('ALL', true);
        sortSprite.updateHitbox();
        sortSprite.onDraw = (s) -> {
            s.scale.set(1, 1);
            s.playAnim('AB', true);
            s.updateHitbox();
            for (i in 0...5) {
                final diff = i - 2;
                final sort = sortReference.array[
                    FlxMath.wrap(sortReference.curSelected + diff, 0, sortReference.array.length - 1)
                ];
                if (sort == null) continue;
                s.frame = s.frames.getByName(sort.anim + '0000'); // idc
                s.offset.x = diff * -80 + Std.int(s.frame.frame.width * 0.5) - __uglyXOffset;
                if (diff == 0) {
                    s.offset.y = -4 + Math.sin((Std.int(__animTimer * 12) / 12) * 2.4) * 7;
                    s.scale.set(1.1, 1.1); // ???
                } else {
                    s.offset.y = -4;
                    s.scale.set(0.88, 0.88);
                }
                s.color = FlxColor.fromHSB(0, 0, 1 - Math.abs(diff * 0.16));
                s.draw();
            }
        }

        separator.onDraw = (s) -> {
            for (i in 0...4) {
                final diff = i - 2;
                s.offset.x = diff * -80 - __uglyXOffset;
                s.color = FlxColor.fromHSB(0, 0, 1 - Math.abs(diff * 0.285));
                s.draw();
            }
        }

        leftArrow.antialiasing = rightArrow.antialiasing = separator.antialiasing = sortSprite.antialiasing = true;

        add(leftArrow);
        add(rightArrow);
        add(separator);
        add(sortSprite);
	}
    override public function update(elapsed:Float) {
        __animTimer += elapsed;
        super.update(elapsed);

        __uglyXOffset = FlxMath.lerp(80 * __animMult, 0, FlxEase.backOut(Math.min(1, Std.int(__animTimer * 20) * 0.25)));

        leftArrow.frameOffset.x = (__animMult < 0 && __animTimer < 0.16) ? -5 : 0;
        rightArrow.frameOffset.x = (__animMult > 0 && __animTimer < 0.16) ? 5 : 0;
    }
}