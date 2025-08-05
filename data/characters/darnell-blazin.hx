import funkin.game.PlayState;

function playSingAnimUnsafe(event)
{
	event.cancel();
}

var cantUppercut:Bool = false;

function onNoteHit(event)
{
	var shouldDoUppercutPrep = wasNoteHitPoorly(event) && isPlayerLowHealth() && FlxG.random.bool(30);

	if (shouldDoUppercutPrep)
	{
		playUppercutPrepAnim();
		return;
	}

	if (cantUppercut)
	{
		playPunchHighAnim();
		return;
	}

	switch(event.noteType)
	{
		case "Punch Low":
			playHitLowAnim();
		case "Punch Low Blocked":
			playBlockAnim();
		case "Punch Low Dodged":
			playDodgeAnim();
		case "Punch Low Spin":
			playSpinAnim();

		case "Punch High":
			playHitHighAnim();
		case "Punch High Blocked":
			playBlockAnim();
		case "Punch High Dodged":
			playDodgeAnim();
		case "Punch High Spin":
			playSpinAnim();

		case "Block High":
			playPunchHighAnim();
		case "Block Low":
			playPunchLowAnim();
		case "Block Spin":
			playPunchHighAnim();

		case "Dodge High":
			playPunchHighAnim();
		case "Dodge Low":
			playPunchLowAnim();
		case "Dodge Spin":
			playPunchHighAnim();

		case "Hit High":
			playPunchHighAnim();
		case "Hit Low":
			playPunchLowAnim();
		case "Hit Spin":
			playPunchHighAnim();

		case "Pico Uppercut Prep":
			// playIdleAnim();
		case "Pico Uppercut":
			playUppercutHitAnim();

		case "Darnell Uppercut Prep":
			playUppercutPrepAnim();
		case "Darnell Uppercut":
			playUppercutAnim();

		case "Idle":
			playIdleAnim();
		case "Fake Out":
			playCringeAnim();
		case "Taunt":
			playPissedConditionalAnim();
		case "Taunt Force":
			playPissedAnim();
		case "Reverse Fakeout":
			playFakeoutAnim();
	}

	cantUppercut = false;
}

function onPlayerMiss(event)
{
	// SPECIAL CASE: Darnell prepared to uppercut last time and Pico missed! FINISH HIM!
	if (getAnimName() == 'uppercutPrep')
	{
		playUppercutAnim();
		return;
	}

	if (willMissBeLethal(event))
	{
		playPunchLowAnim();
		return;
	}

	if (cantUppercut)
	{
		playPunchHighAnim();
		return;
	}

	switch (event.noteType)
	{
		// Pico tried and failed to punch, punch back!
		case "Punch Low":
			playPunchLowAnim();
		case "Punch Low Blocked":
			playPunchLowAnim();
		case "Punch Low Dodged":
			playPunchLowAnim();
		case "Punch Low Spin":
			playPunchLowAnim();

		// Pico tried and failed to punch, punch back!
		case "Punch High":
			playPunchHighAnim();
		case "Punch High Blocked":
			playPunchHighAnim();
		case "Punch High Dodged":
			playPunchHighAnim();
		case "Punch High Spin":
			playPunchHighAnim();

		// Attempt to punch, Pico dodges or gets hit.
		case "Block High":
			playPunchHighAnim();
		case "Block Low":
			playPunchLowAnim();
		case "Block Spin":
			playPunchHighAnim();

		// Attempt to punch, Pico dodges or gets hit.
		case "Dodge High":
			playPunchHighAnim();
		case "Dodge Low":
			playPunchLowAnim();
		case "Dodge Spin":
			playPunchHighAnim();

		// Attempt to punch, Pico ALWAYS gets hit.
		case "Hit High":
			playPunchHighAnim();
		case "Hit Low":
			playPunchLowAnim();
		case "Hit Spin":
			playPunchHighAnim();

		// Successfully dodge the uppercut.
		case "Pico Uppercut Prep":
			playHitHighAnim();
			cantUppercut = true;
		case "Pico Uppercut":
			playDodgeAnim();

		// Attempt to punch, Pico dodges or gets hit.
		case "Darnell Uppercut Prep":
			playUppercutPrepAnim();
		case "Darnell Uppercut":
			playUppercutAnim();

		case "Idle":
			playIdleAnim();
		case "Fake Out":
			playCringeAnim(); // TODO: Which anim?
		case "Taunt":
			playPissedConditionalAnim();
		case "Taunt Force":
			playPissed();
		case "Reverse Fakeout":
			playFakeoutAnim(); // TODO: Which anim?
	}
}

function willMissBeLethal(event):Bool
{
	return (PlayState.instance.health + event.healthGain) <= 0.0;
}

function moveToHelper(front:Bool)
{
	var stagePosObjects:Array = [];
	for(strumLine in PlayState.instance.strumLines.members)
	{
		var charPosName:String = strumLine.data.position == null ? (switch(strumLine.data.type) {
			case 0: "dad";
			case 1: "boyfriend";
			case 2: "girlfriend";
		}) : strumLine.data.position;
		stagePosObjects.push(PlayState.instance.stage.characterPoses.get(charPosName));
	}
	var dadStagePos:Int = PlayState.instance.members.indexOf(stagePosObjects[0]);
	var bfStagePos:Int = PlayState.instance.members.indexOf(stagePosObjects[1]);

	if(front ? (bfStagePos > dadStagePos) : (bfStagePos < dadStagePos))
		return;

	PlayState.instance.members[bfStagePos] = stagePosObjects[0];
	PlayState.instance.members[dadStagePos] = stagePosObjects[1];

	for(i => strumLine in PlayState.instance.strumLines.members)
	{
		var charPosName:String = strumLine.data.position == null ? (switch(strumLine.data.type) {
			case 0: "dad";
			case 1: "boyfriend";
			case 2: "girlfriend";
		}) : strumLine.data.position;

		for(char in strumLine.characters)
		{
			PlayState.instance.remove(char);
			var charPos = PlayState.instance.stage.characterPoses.exists(char.curCharacter) ? PlayState.instance.stage.characterPoses.get(char.curCharacter) : PlayState.instance.stage.characterPoses.get(charPosName);
			if (charPos != null) PlayState.instance.insert(state.members.indexOf(charPos), char);
		}
	}
}

function moveToBack()
{
	moveToHelper(false);
}

function moveToFront()
{
	moveToHelper(true);
}

function wasNoteHitPoorly(event):Bool
{
	return (event.rating == "bad" || event.rating == "shit");
}

function isPlayerLowHealth():Bool
{
	return PlayState.instance.health <= 0.30 * 2.0;
}

// ANIMATIONS
var alternate:Bool = false;

function doAlternate():String
{
	alternate = !alternate;
	return alternate ? '1' : '2';
}

function playBlockAnim()
{
	playAnim('block', true, "SING");
	PlayState.instance.camGame.shake(0.002, 0.1);
	moveToBack();
}

function playCringeAnim()
{
	playAnim('cringe', true, "SING");
	moveToBack();
}

function playDodgeAnim()
{
	playAnim('dodge', true, "SING");
	moveToBack();
}

function playIdleAnim()
{
	playAnim('idle', false, "DANCE");
	moveToBack();
}

function playFakeoutAnim()
{
	playAnim('fakeout', true, "SING");
	moveToBack();
}

function playPissedConditionalAnim()
{
	if (getAnimName() == "cringe")
	{
		playPissedAnim();
	}
	else
	{
		playIdleAnim();
	}
}

function playPissedAnim()
{
	playAnim('pissed', true, "SING");
	moveToBack();
}

function playUppercutPrepAnim()
{
	playAnim('uppercutPrep', true, "SING");
	moveToFront();
}

function playUppercutAnim()
{
	playAnim('uppercut', true, "SING");
	moveToFront();
}

function playUppercutHitAnim()
{
	playAnim('uppercutHit', true, "SING");
	moveToBack();
}

function playHitHighAnim()
{
	playAnim('hitHigh', true, "SING");
	PlayState.instance.camGame.shake(0.0025, 0.15);
	moveToBack();
}

function playHitLowAnim()
{
	playAnim('hitLow', true, "SING");
	PlayState.instance.camGame.shake(0.0025, 0.15);
	moveToBack();
}

function playPunchHighAnim()
{
	playAnim('punchHigh' + doAlternate(), true, "SING");
	moveToFront();
}

function playPunchLowAnim()
{
	playAnim('punchLow' + doAlternate(), true, "SING");
	moveToFront();
}

function playSpinAnim()
{
	playAnim('hitSpin', true, "SING");
	PlayState.instance.camGame.shake(0.0025, 0.15);
	moveToBack();
}