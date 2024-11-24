//
public var ratingScaleDiff:Float = 0.1;

function create() {
    comboGroup.x = 560;
    comboGroup.y = 290;
}

function onPostCountdown(event) {
    var spr = event.sprite;
    if (spr != null) {
        spr.camera = camHUD;
        spr.scale.set(1, 1);
    }

    // prevents tweening the y  - Nex
    var props = event.spriteTween?._propertyInfos;
    if (props != null) for (info in props)
        if (info.field == "y") event.spriteTween._propertyInfos.remove(info);
}

function onNoteHit(event) {
    event.numScale -= ratingScaleDiff;
    event.ratingScale -= ratingScaleDiff;
}

function update()
    comboGroup.forEachAlive(function(spr) if (spr.camera != camHUD) spr.camera = camHUD);