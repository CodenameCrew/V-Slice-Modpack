import funkin.game.PlayState.ComboRating;
import haxe.ds.ObjectMap;

public var useCNERating = false;

// [0 => hold:Note, 1 => score:Int, 2 => health:Float, 3 => accuracy:Float]
var pressedHoldCaches:ObjectMap<Note, Array<Dynamic>> = new ObjectMap<Note, Array<Dynamic>>();
var cachePool:Array<Array<Dynamic>> = [];
var perfect:Bool = true;

function create() {
	if (!useCNERating) {
		comboRatings = [
			new ComboRating(0, "L", 0xFF7393FF),
			new ComboRating(0.6, "G", 0xFFFAA885),
			new ComboRating(0.8, "G", 0xFFF0FDFF),
			new ComboRating(0.9, "E", 0xFFFFFFCB),
			new ComboRating(1, "P", 0xFFFFFF65/*0xFFFFB6FF*/)
		];
	}
}

function onRatingUpdate(e) {
	if (!useCNERating && e.rating?.percent == 1 && e.rating.color != (e.rating.color = perfect ? 0xFFFFFF65 : 0xFFFFB6FF) && e.oldRating == e.rating) {
		accuracyTxt.text = "";
		if (updateRatingStuff != null) updateRatingStuff();
		// setting _regen doesnt work?
	}
}

function onPlayerHit(e) {
	var note = e.note;

	if (note.isSustainNote) {
		if (note.sustainParent.wasGoodHit) {
			e.healthGain = e.score = 0.0;

			var cache = pressedHoldCaches.get(note.sustainParent);
			if (cache == null) {
				if ((cache = cachePool.pop()) == null) (cache = []).resize(4);
				pressedHoldCaches.set(note.sustainParent, cache);
			}

			cache[3] = CoolUtil.bound(position - note.sustainParent.strumTime, 0.0, note.sustainLength + note.strumTime - note.sustainParent.strumTime);
			cache[0] = note;
			cache[1] = scoreHold(cache[3]);
			cache[2] = bonusHoldHealth(cache[3]);
		}
		else {
			e.cancel();
			e.enableCamZooming = e.autoHitLastSustain = e.unmuteVocals = false;
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
		e.score = scoreNote(diff);
		if (useCNERating) e.accuracy = e.score / scoreNote(0.0);
		else {
			if (perfect) perfect = e.rating == "sick";
			if (e.rating != "shit" && e.rating != "bad") e.accuracy = 1;
		}
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

	e.score = scoreMiss(note == null);
	e.accuracy = -1;
}

var hold:Note;
var position:Float;
var previous:Float;
var duration:Float;
var temp:Float;
function checkNoteUpdate(note:Note) if (!note.avoid && note.isSustainNote && position > (temp = note.strumTime) && previous < (temp += note.sustainLength)) {
	accuracyPressedNotes += (CoolUtil.bound(position, note.strumTime, temp) - CoolUtil.bound(previous, note.strumTime, temp)) / note.sustainLength;
}

function update(elapsed:Float) {
	position = songPos;

	for (note => cache in pressedHoldCaches) {
		while (position > (hold = cache[0]).strumTime && hold.nextSustain != null) cache[0] = hold.nextSustain;

		temp = hold.sustainLength + hold.strumTime;
		if (position > temp || !note.strumLine.__pressed[note.strumID]) {
			pressedHoldCaches.remove(note);
			cachePool.push(cache);
		}
		if (!note.wasGoodHit) continue;

		duration = CoolUtil.bound(position - note.strumTime, 0.0, temp - note.strumTime);

		temp = cache[1];
		songScore += (cache[1] = scoreHold(duration)) - temp;

		temp = cache[2];
		note.strumLine.addHealth((cache[2] = bonusHoldHealth(duration)) - temp);

		if (useCNERating) {
			totalAccuracyAmount += (duration - cache[3]) / hold.sustainLength;
			cache[3] = duration;
		}
	}

	if (useCNERating) {
		if (songPos > previous && player != null) player.notes.forEach(checkNoteUpdate);
		previous = position;
	}

	if (hold != null) {
		updateRating();
		hold = null;
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