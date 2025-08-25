function update(elapsed:Float) {
	this.playAnim(PlayState.instance.strumLines.members[1].characters[0].animation.curAnim.name);
	this.animation.curAnim.curFrame = PlayState.instance.strumLines.members[1].characters[0].animation.curAnim.curFrame;
}