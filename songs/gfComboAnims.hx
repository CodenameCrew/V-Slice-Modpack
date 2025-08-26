function onPostNoteHit(e) {
	for(chars in strumLines.members[2].characters){
		if (combo == 50) {
			if (chars.hasAnim('combo50')) chars.playAnim('combo50', true);
			else if (chars.hasAnim('cheer')) chars.playAnim('cheer', true);
		}
		else if (combo == 200) {
			if (chars.hasAnim('combo200')) chars.playAnim('combo200', true);
			else if (chars.hasAnim('cheer')) chars.playAnim('cheer', true);
		}
	}
}

function onPlayerMiss(e) {
	for(chars in strumLines.members[2].characters){
		if (combo >= 70) {
			if (chars.hasAnim('drop70')) chars.playAnim('drop70', true);
			else if (chars.hasAnim('sad')) chars.playAnim('sad', true);
		}
	}
}