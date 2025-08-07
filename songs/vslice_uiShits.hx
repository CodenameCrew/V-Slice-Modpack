public var ratingScaleDiff:Float = 0.1;

var lerpHealth:Float = 1;

function create()
    comboGroup.setPosition(560, 290);

function postCreate() 
    healthBar.numDivisions = 1000;

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

function postUpdate() 
    comboGroup.forEachAlive(function(spr) if (spr.camera != camHUD) spr.camera = camHUD);

function postUpdate(elapsed:Float) {
    lerpHealth = lerp(lerpHealth, health, 0.15);
    healthBar.value = FlxMath.roundDecimal(lerpHealth, 3);
}
