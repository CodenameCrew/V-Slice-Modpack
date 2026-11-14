if (debugMode) {
	return disableScript();
}

public var normal = new Character(x, y, extra['normal'] ?? StringTools.replace(curCharacter, '-dark', ''), isPlayer);

function draw() {
	if (normal == null) return;
	normal.setPosition(x, y);
	if (extra['offX'] != null) normal.x += Std.parseFloat(extra['offX']);
	if (extra['offY'] != null) normal.y += Std.parseFloat(extra['offY']);

	// fuck ass nene
	if (extra['forceDrawNormal'] || alpha < 1) normal.draw();
}

function postUpdate(elapsed) {
	if (normal == null) return;
	normal.lastHit = lastHit;
	normal.lastAnimContext = lastAnimContext;
	normal.update(elapsed);
	normal.playAnim(getAnimName());
	normal.globalCurFrame = globalCurFrame;
}