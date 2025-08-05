import funkin.game.PlayState;

function playSingAnimUnsafe(event)
{
	event.cancel();
}

var cantUppercut:Bool = false;

function onNoteHit(event)
{
	var shouldDoUppercutPrep:Bool = wasNoteHitPoorly(event) && isPlayerLowHealth() && isDarnellPreppingUppercut();

	if (shouldDoUppercutPrep)
	{
		playPunchHighAnim();
		return;
	}

	if (cantUppercut)
	{
		playBlockAnim();
		cantUppercut = false;
		return;
	}

	switch(event.noteType)
	{
		case "Punch Low":
			playPunchLowAnim();
		case "Punch Low Blocked":
			playPunchLowAnim();
		case "Punch Low Dodged":
			playPunchLowAnim();
		case "Punch Low Spin":
			playPunchLowAnim();

		case "Punch High":
			playPunchHighAnim();
		case "Punch High Blocked":
			playPunchHighAnim();
		case "Punch High Dodged":
			playPunchHighAnim();
		case "Punch High Spin":
			playPunchHighAnim();

		case "Block High":
			playBlockAnim(event.judgement);
		case "Block Low":
			playBlockAnim(event.judgement);
		case "Block Spin":
			playBlockAnim(event.judgement);

		case "Dodge High":
			playDodgeAnim();
		case "Dodge Low":
			playDodgeAnim();
		case "Dodge Spin":
			playDodgeAnim();

		// Pico ALWAYS gets punched.
		case "Hit High":
			playHitHighAnim();
		case "Hit Low":
			playHitLowAnim();
		case "Hit Spin":
			playHitSpinAnim();

		case "Pico Uppercut Prep":
			playUppercutPrepAnim();
		case "Pico Uppercut":
			playUppercutAnim(true);

		case "Darnell Uppercut Prep":
			playIdleAnim();
		case "Darnell Uppercut":
			playUppercutHitAnim();

		case "Idle":
			playIdleAnim();
		case "Fake Out":
			playFakeoutAnim();
		case "Taunt":
			playTauntConditionalAnim();
		case "Taunt Force":
			playTauntAnim();
		case "Reverse Fakeout":
			playIdleAnim(); // TODO: Which anim?
	}
}

function onPlayerMiss(event)
{
	// SPECIAL CASE: Darnell prepared to uppercut last time and Pico missed! FINISH HIM!
	if (isDarnellInUppercut())
	{
		playUppercutHitAnim();
		return;
	}

	if (willMissBeLethal(event))
	{
		playHitLowAnim();
		return;
	}

	if (cantUppercut)
	{
		playHitHighAnim();
		return;
	}

	switch (event.noteType)
	{
		// Pico fails to punch, and instead gets hit!
		case "Punch Low":
			playHitLowAnim();
		case "Punch Low Blocked":
			playHitLowAnim();
		case "Punch Low Dodged":
			playHitLowAnim();
		case "Punch Low Spin":
			playHitSpinAnim();

		// Pico fails to punch, and instead gets hit!
		case "Punch High":
			playHitHighAnim();
		case "Punch High Blocked":
			playHitHighAnim();
		case "Punch High Dodged":
			playHitHighAnim();
		case "Punch High Spin":
			playHitSpinAnim();

		// Pico fails to block, and instead gets hit!
		case "Block High":
			playHitHighAnim();
		case "Block Low":
			playHitLowAnim();
		case "Block Spin":
			playHitSpinAnim();

		// Pico fails to dodge, and instead gets hit!
		case "Dodge High":
			playHitHighAnim();
		case "Dodge Low":
			playHitLowAnim();
		case "Dodge Spin":
			playHitSpinAnim();

		// Pico ALWAYS gets punched.
		case "Hit High":
			playHitHighAnim();
		case "Hit Low":
			playHitLowAnim();
		case "Hit Spin":
			playHitSpinAnim();

		// Fail to dodge the uppercut.
		case "Pico Uppercut Prep":
			playPunchHighAnim();
			cantUppercut = true;
		case "Pico Uppercut":
			playUppercutAnim(false);

		// Darnell's attempt to uppercut, Pico dodges or gets hit.
		case "Darnell Uppercut Prep":
			playIdleAnim();
		case "Darnell Uppercut":
			playUppercutHitAnim();

		case "Idle":
			playIdleAnim();
		case "Fake Out":
			playHitHighAnim();
		case "Taunt":
			playTauntConditionalAnim();
		case "Taunt Force":
			playTauntAnim();
		case "Reverse Fakeout":
			playIdleAnim();
	}
}

function willMissBeLethal(event):Bool
{
	return (PlayState.instance.health + event.healthGain) <= 0.0;
}

function getDarnell()
{
	return PlayState.instance.dad;
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

function isDarnellPreppingUppercut():Void
{
	return getDarnell().getAnimName() == 'uppercutPrep';
}

function isDarnellInUppercut():Void
{
	return getDarnell().getAnimName() == 'uppercut' || getDarnell().getAnimName() == 'uppercut-loop';
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

function playBlockAnim(?judgement:String)
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

function playUppercutPrepAnim()
{
	playAnim('uppercutPrep', true, "SING");
	moveToFront();
}

function playUppercutAnim(hit:Bool)
{
	playAnim('uppercut', true, "SING");
	if (hit)
	{
		PlayState.instance.camGame.shake(0.005, 0.25);
	}
	moveToFront();
}

function playUppercutHitAnim()
{
	playAnim('uppercutHit', true, "SING");
	PlayState.instance.camGame.shake(0.005, 0.25);
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

function playHitSpinAnim()
{
	playAnim('hitSpin', true, "SING", true);
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

function playTauntConditionalAnim()
{
	if (getAnimName() == "fakeout")
	{
		playTauntAnim();
	}
	else
	{
		playIdleAnim();
	}
}

function playTauntAnim()
{
	playAnim('taunt', true, "SING");
	moveToBack();
}

function onGameOver(event)
{
	event.gameOverSong = "pico/gameOver";
	event.lossSFX = "pico/fnf_loss_sfx-pico-gutpunch";
	event.retrySFX = "pico/gameOverEnd";
}