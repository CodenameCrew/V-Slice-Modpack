import funkin.backend.MusicBeatTransition;

function onGamePause(event)
{
	MusicBeatTransition.script = 'data/stickerTransition.hx';
}

function onSubstateClose(event)
{
	if(!Std.isOfType(subState, MusicBeatTransition) && paused)
	{
		MusicBeatTransition.script = '';
	}
}

function onGameOver(event)
{
	MusicBeatTransition.script = 'data/stickerTransition.hx';
}