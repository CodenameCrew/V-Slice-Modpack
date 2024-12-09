import haxe.io.Path;
import flxanimate.frames.FlxAnimateFrames;
import funkin.menus.FreeplayState.FreeplaySonglist;

function onSelectItem(e)
{
    if (e.name == "freeplay") {
        e.cancel();

        menuItems.members[curSelected].visible = true;

        openSubState(new ModSubState("FreeplayMenu"));
    }
}

var bfDjAltasThingy:Dynamic;
function postCreate() {
    //load bf here cuz it lags freeplay if i dont
    bfDjAltasThingy = FlxAnimateFrames.fromTextureAtlas(Path.withoutExtension(Paths.image('freeplay/fpboyfriend')));
}