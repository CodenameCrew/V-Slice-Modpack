var abot, abotDark, abotViz, eyeWhites, stereoBG, pupil;
function onStartSong() {
    normal.script.call('onStartSong');
}
function onEvent(e) {
    normal.script.callOne('onEvent', e);
}
function beatHit() {
    normal.script.call('beatHit');
}
var vizAdjustColor = FunkinShader.fromFile('adjustColor');
vizAdjustColor.brightness = -12;
vizAdjustColor.hue = -26;
vizAdjustColor.contrast = 0;
vizAdjustColor.saturation = -45;

function update(elapsed) {
    if (abotDark == null) {
        // ez
        for (i in ['abot', 'abotDark', 'abotViz', 'eyeWhites', 'stereoBG', 'pupil']) {
            __script__.set(i, normal.script.get(i));
        }

        abotViz.forEach((a) -> { a.shader = vizAdjustColor; });
    } else {
        abotDark.alpha = alpha;
        eyeWhites.color = FlxColor.interpolate(0xFFFFFFFF, 0xFF6F96CE, alpha);
        stereoBG.color = FlxColor.interpolate(0xFFFFFFFF, 0xFF616785, alpha);

        vizAdjustColor.brightness = -12 * alpha;
        vizAdjustColor.hue =        -26 * alpha;
        vizAdjustColor.saturation = -45 * alpha;
    }
}