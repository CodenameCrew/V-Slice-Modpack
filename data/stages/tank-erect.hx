function beatHit()
{
    // sippy sippy :3
    if(FlxG.random.bool(2))
    {
        sniper.beatInterval = 9999;

        sniper.playAnim('sip', true);
        sniper.animation.finishCallback = function()
        {
            sniper.beatInterval = 1;
            sniper.animation.finishCallback = null;
        }
    }
}