var columnPressedHolds:Array<Note> = [];
var columnHoldScores:Array<Int> = [];
var columnHoldHealths:Array<Float> = [];

function onPlayerHit(e) {
	var note = e.note;

	if (note.isSustainNote) {
		if (note.sustainParent.wasGoodHit) {
			if (columnPressedHolds[e.direction]?.sustainParent != note.sustainParent ?? true) {
				columnHoldScores[e.direction] = 0;
				columnHoldHealths[e.direction] = 0.0;
			}
			columnPressedHolds[e.direction] = note;
			e.healthGain = 0.0;
		}
		else {
			e.cancel();
			e.note.wasGoodHit = e.deleteNote = e.enableCamZooming = e.unmuteVocals = false;
			if (!note.strumLine?.ghostTapping) noteMiss(note.strumLine, null);
		}
	}
	else {
		var diff = songPos - note.strumTime;
		if ((e.rating = judgeNote(diff)) == "miss") {
			e.cancel();
			e.note.wasGoodHit = e.deleteNote = e.enableCamZooming = e.unmuteVocals = false;
			if (!note.strumLine?.ghostTapping) noteMiss(note.strumLine, note);
			return;
		}

		e.healthGain = judgeHealth(e.rating);
		e.accuracy = (e.score = scoreNote(diff)) / scoreNote(0.0);
	}
}

function onPlayerMiss(e) {
	var note = e.note;
	if (note?.isSustainNote) {
		if (note.sustainParent.wasGoodHit) {
			e.animCancelled = note.sustainParent.wasGoodHit = false;
			e.stunned = true;
		}
		else 
			return e.cancel();
	}

	e.accuracy = (e.score = scoreMiss(note == null)) / scoreNote(0.0);
}

var strumLine, duration, strumTime, temp;
function update(elapsed:Float) {
	for (column => note in columnPressedHolds) if (note != null) {
		strumLine = note.strumLine;
		if (note.sustainParent.wasGoodHit) {
			while (songPos > note.strumTime && note.nextSustain != null) columnPressedHolds[column] = note = note.nextSustain;
			strumTime = (note?.sustainParent ?? note).strumTime;
			duration = CoolUtil.bound(songPos - strumTime, 0.0, note.sustainLength + note.strumTime - strumTime);

			temp = columnHoldScores[column];
			songScore += (columnHoldScores[column] = scoreHold(duration)) - temp;

			temp = columnHoldHealths[column];
			strumLine.addHealth((columnHoldHealths[column] = bonusHoldHealth(duration)) - temp);
		}

		if (!strumLine.__pressed[column]) columnPressedHolds[column] = null;
	}
}

// PBOT1 Scoring (V-Slice)
var MAX_SCORE:Int = 500;
var MIN_SCORE:Int = 9;
var HOLD_SCORE:Int = 250;
var SCORING_OFFSET:Float = 54.99;
var SCORING_SLOPE:Float = 0.080;
var HIT_WINDOW:Float = 160.0;
var PERFECT_THRESHOLD:Float = 5.0;
var SICK_THRESHOLD:Float = 45.0;
var GOOD_THRESHOLD:Float = 90.0;
var BAD_THRESHOLD:Float = 135.0;

function judgeNote(timing:Float):String {
	timing = Math.abs(timing);
	return if (timing < SICK_THRESHOLD) "sick";
		else if (timing < GOOD_THRESHOLD) "good";
		else if (timing < BAD_THRESHOLD) "bad";
		else if (timing < HIT_WINDOW) "shit";
		else "miss";
}

function scoreNote(timing:Float):Int {
	timing = Math.abs(timing);

	if (timing > HIT_WINDOW) return scoreMiss(false);
	else if (timing <= PERFECT_THRESHOLD) return MAX_SCORE;

	var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-SCORING_SLOPE * (timing - SCORING_OFFSET))));
	return Math.floor(MAX_SCORE * factor + MIN_SCORE);
}

function scoreHold(duration:Float):Int return Math.floor(HOLD_SCORE * duration * 0.001);

function scoreMiss(tap:Bool):Int return tap ? -80 : -100;

function judgeHealth(judge:String):Float {
	return switch (judge) {
		//case PERFECT: 2.0 / 100 * 2;
		case "sick": 1.5 / 100 * 2;
		case "good": 0.75 / 100 * 2;
		case "bad": 0.0;
		case "shit": -1.0 / 100 * 2;
		default: -4.0 / 100 * 2;
	}
}

function bonusHoldHealth(duration:Float):Float return duration * 0.00015;//7.5 / 100 * 2 * duration / 1000;