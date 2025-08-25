function update(elapsed) {

	this.alpha = PlayState.instance.strumLines.members[1].characters[1].alpha;
	this.playAnim(PlayState.instance.gf.animation.curAnim.name);
	this.animation.curAnim.curFrame = PlayState.instance.gf.animation.curAnim.curFrame;
	
}