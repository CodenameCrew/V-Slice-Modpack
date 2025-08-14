function onPostNoteHit(e) {
	if (combo == 50) {
		if (gf.hasAnim('combo50')) gf.playAnim('combo50', true);
		else if (gf.hasAnim('cheer')) gf.playAnim('cheer', true);
	}
	else if (combo == 200) {
		if (gf.hasAnim('combo200')) gf.playAnim('combo200', true);
		else if (gf.hasAnim('cheer')) gf.playAnim('cheer', true);
	}
}

function onPlayerMiss(e) {
	if (combo >= 70) {
		if (gf.hasAnim('drop70')) gf.playAnim('drop70', true);
		else if (gf.hasAnim('sad')) gf.playAnim('sad', true);
	}
}