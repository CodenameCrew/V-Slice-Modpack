// Took the one inside the BaseGame source as a base  - Nex

// TO FINISH the can stuff once FlxAnimate gets updated (pls neeoooooo)  - Nex
var canSprite:FunkinSprite;

var game = PlayState.instance;

function onNoteHit(event)
{
	if (event.character == this) {
		// Override the hit note animation.
		switch(event.noteType) {
			case "Light Can":
				event.animCancelled = true;
				playLightCanAnim();
			case "Kick Can":
				event.animCancelled = true;
				playKickCanAnim();
			case "Knee Can":
				event.animCancelled = true;
				playKneeCanAnim();
		}
	}
	if (event.character.curCharacter == 'pico'){
		switch(event.noteType) {
			case "Fire Gun":
				playCanAnim('Can Shot');
		}
	}
}

function onPlayerMiss(event)
{
	// Override the miss note animation.
	if(!event.cancelled && event.character.curCharacter == 'pico') switch(event.noteType) {
		case "Fire Gun":
			playCanAnim('Hit Pico');
	}
}

function loadCanSprite() {
	canSprite?.destroy();
	canSprite = new FunkinSprite(this.x + 830, this.y + 300);
	canSprite.loadSprite(Paths.image("characters/spraycanAtlas"));
	canSprite.animateAtlas.anim.addBySymbolIndices('Can Start', 'Can with Labels', [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18], 0, false);
	canSprite.animateAtlas.anim.addBySymbolIndices('Hit Pico', 'Can with Labels', [19,20,21,22,23,24,25], 0, false);
	canSprite.animateAtlas.anim.addBySymbolIndices('Can Shot', 'Can with Labels', [26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42], 0, false);
	canSprite.visible = false;
	FlxG.state.insert(game.members.indexOf(this), canSprite);
}

function gamePostCreate() {
	// Precaching  - Nex
	var arr = PlayState.instance.SONG.noteTypes;
	if(arr.contains("Light Can")) FlxG.sound.load(Paths.sound('pico/Darnell_Lighter'));
	if(arr.contains("Kick Can")) FlxG.sound.load(Paths.sound('pico/Kick_Can_UP'));
	if(arr.contains("Knee Can")) {
		loadCanSprite();
		FlxG.sound.load(Paths.sound('pico/Kick_Can_FORWARD'));
	}
}

function playLightCanAnim() {
	this.playAnim("lightCan", true, "LOCK");
	FlxG.sound.play(Paths.sound('pico/Darnell_Lighter'));
}

function playKickCanAnim() {
	this.playAnim("kickCan", true, "LOCK");
	FlxG.sound.play(Paths.sound('pico/Kick_Can_UP'));
	playCanAnim('Can Start');
}

function playKneeCanAnim(){
	this.playAnim("kneeCan", true, "LOCK");
	FlxG.sound.play(Paths.sound('pico/Kick_Can_FORWARD'));
}

function playCanAnim(pluh:String){
	canSprite.visible = true;
	canSprite.playAnim(pluh, true);
}

