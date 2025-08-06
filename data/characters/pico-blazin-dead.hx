function onPlayAnim(event)
{
	if(getAnimName() == 'deathLoop' && event.animName == 'deathLoop')
		event.cancel(); // let the loop play

	if(event.animName == 'idle')
		event.cancel(); // fixes stuff for some reason???
}

function create()
{
	FlxG.camera.zoom = 1;
}