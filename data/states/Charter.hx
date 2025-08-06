import funkin.editors.charter.Charter;

function postCreate() {
    var newInst:FlxSound = FlxG.sound.load(Paths.inst(Charter.instance.__song, Charter.instance.__diff == 'nightmare' ? 'erect' : Charter.instance.__diff));
    FlxG.sound.music = newInst;

    buildNoteTypesUI();
	updateBookmarks();
	refreshBPMSensitive();
}