public var ratingScaleDiff:Float = 0.1;

var lerpHealth:Float = 1;

function postCreate() {
	comboGroup.setPosition(560, 290);
	healthBar.numDivisions = 1000;
	comboGroup.cameras = [camHUD];
}

function onPostCountdown(e) {
	var spr = e.sprite;
	if (spr != null) {
		spr.camera = camHUD;
		spr.scale.set(1, 1);
	}

	// prevents tweening the y  - Nex
	var props = e.spriteTween?._propertyInfos;
	if (props != null) for (info in props)
		if (info.field == "y") e.spriteTween._propertyInfos.remove(info);
}

function onNoteHit(e) {
	e.numScale *= 0.9;
	e.ratingScale *= 0.9;
}
function onPostNoteHit(e) comboGroup.cameras = [camHUD];

function postUpdate(elapsed:Float) {
	lerpHealth = lerp(lerpHealth, health, 0.15);
	healthBar.value = FlxMath.roundDecimal(lerpHealth, 3);
}