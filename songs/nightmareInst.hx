var game = PlayState.instance;

function onSongStart() {
    game.inst = FlxG.sound.load(Assets.getMusic(Paths.inst(game.SONG.meta.name, game.difficulty == 'nightmare' ? 'erect' : game.difficulty)));
    FlxG.sound.music = game.inst;
}