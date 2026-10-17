var characters = ['bf', 'pico'];
var curSelected = 0;
var text = new FunkinText(500, 500, 500);
var icon = new HealthIcon();
function create() {
    CoolUtil.playMusic(Paths.music('pickaguy'));

    var alp = new Alphabet(20, 20, 'temporary for\ndebug purposes :)', 'bold');
    alp.moves = true;
    alp.angularAcceleration = 3;
    add(alp);

    add(text);

    icon.setPosition(200, 450);
    add(icon);

    changeSelection(characters.indexOf(freeplayCurCharacter));
}
function update(elapsed) {
    if (controls.BACK) {
        CoolUtil.playMenuSFX(2).persist = true;
        FlxG.switchState(new FreeplayState());
        return;
    }
    if (controls.LEFT_P) changeSelection(-1);
    if (controls.RIGHT_P) changeSelection(1);

    if (controls.ACCEPT) {
        CoolUtil.playMenuSFX(1).persist = true;
        freeplayCurCharacter = characters[curSelected];
        FlxG.switchState(new FreeplayState());
    }
}

function changeSelection(ch) {
    curSelected = FlxMath.wrap(curSelected + ch, 0, characters.length - 1);
    text.text = '< ${characters[curSelected]} >';
    icon.setIcon(characters[curSelected]);
}