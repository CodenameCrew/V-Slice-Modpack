import game.NoteCoverHandler;

class NoteHoldCover extends funkin.backend.FunkinSprite
{
    /*
     * X Position of the hold cover.
    */
    public var posX:Float = -107.5;

    /*
     * Array of the Y Position for the hold cover.
    */
    public var posY:Float = 0;

    public function new(direction:Int):Void
    {
        var suffix = NoteCoverHandler.getDirectionName(direction);
        frames = Paths.getSparrowAtlas("game/splashes/hold/holdCover" + suffix);
        animation.addByPrefix("start", "holdCoverStart" + suffix, 24, false);
        animation.addByPrefix("hold", "holdCover" + suffix, 24, true);

        antialiasing = true;
        visible = false;

        animation.finishCallback = this.onAnimationFinished;
    }

    public function updatePosition(object:FlxObject) {
        x = object.x + posX;
        y = object.y + posY;
        angle = object.angle;
        alpha = object.alpha;
    }

    public function onAnimationFinished(animName:String):Void
        if (animName == 'start') playHold();

    public function start() {
        if (!visible && animation.name == "hold") playStart();
        else playHold();
    }

    public function playStart() {
        visible = true;
        playAnim('start');
    }

    public function playHold()
        playAnim('hold');
}