function onPlayAnim(event)
{
	if(getAnimName() == 'deathLoop' && event.animName == 'deathLoop')
		event.cancel(); // let the loop play

	if(event.animName == 'idle')
		event.cancel(); // fixes stuff for some reason???
}

function create()
{
	FlxTween.tween(FlxG.camera, {zoom: 0.7}, 1, {ease: FlxEase.elasticOut, startDelay: 0.4});
	new FlxTimer().start(0.6, (_) -> {
		GameOverSubstate.instance.camFollow.y += 400;
	});
}