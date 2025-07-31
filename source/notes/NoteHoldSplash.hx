import game.NoteCoverHandler;

class NoteHoldSplash extends funkin.backend.FunkinSprite
{
    public function new(direction:Int) {
        var suffix = NoteCoverHandler.getDirectionName(direction);
        frames = Paths.getSparrowAtlas("game/splashes/hold/holdCover" + suffix);
        animation.addByPrefix("holdEnd", "holdCoverEnd" + suffix, 24, false);
    }

    public function start() {
        playAnim('holdEnd', true);
        animation.finishCallback = () -> visible = false;
    }
}