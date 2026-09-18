import funkin.game.StageCharPos;
importScript('data/scripts/rimlight.hx');

var cacheShit = [
    '' => 'this makes it a map ok'
];
function onStageNodeParsed(e) {
    //trace(e.sprite);
    //trace(e.node);
    if (e.sprite is StageCharPos)
    {
        if (cacheShit[e.name] == null) {
            cacheShit[e.name] = e.node;
        }
    }
}

function postCreate() {
    for (i in strumLines.members) {
        var charPosName:String = (i?.data?.position) ?? (switch(i.data.type) {
            case 0: "dad";
            case 1: "boyfriend";
            case 2: "girlfriend";
        });
        var n = cacheShit[charPosName];
        if ((n.get('ds_applyShader') ?? 'true').toLowerCase() != 'true') continue;

        for (char in i.characters) {
            var rim = rimlight(char);
            if (n.get('ds_threshold') != null) rim.threshold = Std.parseFloat(n.get('ds_threshold'));
            if (n.get('ds_distance') != null) rim.distance_offset = Std.parseFloat(n.get('ds_distance'));
            if (n.get('ds_angle') != null) rim.distance_angle = Std.parseFloat(n.get('ds_angle'));

            if ((n.get('ds_pixelPerfect') ?? 'true').toLowerCase() != 'true' ||
                (n.get('ds_antialiasAmt') != null && Std.parseFloat(n.get('ds_antialiasAmt')) <= 0))
                rim.smoothing = false;

            for (matrix in [rim.matrixA, rim.matrixB]) {
                hsbc(
                    Std.parseFloat(n.get('ds_hue')),
                    Std.parseFloat(n.get('ds_saturation')),
                    Std.parseFloat(n.get('ds_brightness')),
                    Std.parseFloat(n.get('ds_contrast')),
                    matrix
                );
            }
            
            if (n.get('ds_color') != null) setAddColorMatrix(FlxColor.fromString(n.get('ds_color')), rim.matrixB, true);
        }
    }
}