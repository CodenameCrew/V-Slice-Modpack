import funkin.editors.charter.Charter;

var auto:Bool = false, toggleFast:Bool = false;
var attachedStrumlines:Array<Any> = [];
var strumLineCache:Map<Int, Array<Array<Bool>>> = [];
var strumLineDuration:Map<Int, Array<Float>> = [];

var initialPlayback:Float = 1;
var playback:Float = 1;
var wasChartingMode:Bool = PlayState.chartingMode;

function postCreate() {
	if (Charter.playtestInfo != null) initialPlayback = Charter.playtestInfo.playbackSpeed;
	setPlayback(initialPlayback);
}

function onSubstateClose() if (paused) setPlayback(initialPlayback);
function onGamePause() setPlayback(1);
function destroy() setPlayback(1);

function setPlayback(p:Float) {
	FlxG.timeScale = playback = p;
	//inst.pitch = vocals.pitch = p;
	//for (strline in strumLines.members) strline.vocals.pitch = p;
}

function update(elapsed:Float) {
	if (FlxG.keys.justPressed.TWO) {
		if (auto = !auto) {
			for (id => strumLine in strumLines.members) {
				if (strumLine == null || strumLine.cpu || strumLine.opponentSide) continue;

				var cacheID = attachedStrumlines.length;
				var cache = [], request = [], updated = [];
				for (k in 0...4) {
					strumLine.members[k].getPressed = (_) -> cache[k][0];
					strumLine.members[k].getJustPressed = (_) -> cache[k][1];
					strumLine.members[k].getJustReleased = (_) -> cache[k][2];
					request[k] = 0;
					updated[k] = false;
					cache[k] = [];
					for (i in 0...3) cache[k][i] = false;
				}

				strumLine.onNoteUpdate.add((e) -> onNoteUpdate(cache, request, /*updated,*/ e));
				strumLineCache.set(cacheID, cache);
				strumLineDuration.set(cacheID, request);
				//strumLineUpdated.set(cacheID, updated);
				attachedStrumlines.push(strumLine);
			}
		}
		else {
			for (strumLine in attachedStrumlines) {
				for (k in 0...4) {
					strumLine.members[k].getPressed = null;
					strumLine.members[k].getJustPressed = null;
					strumLine.members[k].getJustReleased = null;
				}
				strumLine.onNoteUpdate.remove(onNoteUpdate);
			}
			attachedStrumlines = [];
			strumLineCache.clear();
			strumLineDuration.clear();
			//strumLineUpdated.clear();
		}
	}

	if (FlxG.keys.justPressed.LBRACKET) setPlayback(playback - 0.25);
	else if (FlxG.keys.justPressed.RBRACKET) setPlayback(playback + 0.25);
	else if (FlxG.keys.justPressed.SEVEN) FlxG.switchState(new Charter(PlayState.SONG.meta.name, PlayState.difficulty));

	if (FlxG.keys.pressed.L) {
		if (!toggleFast) {
			toggleFast = true;
			setPlayback(10);
		}
	}
	else if (toggleFast) {
		toggleFast = false;
		setPlayback(1);
	}

	if (!auto) return;
	if (FlxG.keys.justPressed.ONE) endSong();

	var cacheKey;
	for (id => cache in strumLineCache) for (key in 0...4) {
		if ((cacheKey = cache[key])[0] && strumLineDuration.get(id)[key] < songPos) cacheKey[2] = !(cacheKey[0] = cacheKey[1] = false);
		else cacheKey[2] = cacheKey[1] = false;
		//strumLineUpdated.get(id)[key] = false;
	}
}

function onNoteUpdate(cache, duration, /*updated,*/ e) {
	if (!auto) return;

	var note = e.note;
	if (!note.avoid && !note.wasGoodHit && note.strumTime < songPos) {
		var key = note.noteData, d = note.strumTime;
		if (note.isSustainNote) {
			d += note.sustainLength;
			while ((note = note.nextSustain) != null) d += note.sustainLength;
		}
		else {
			d += 130;
			cache[key][1] = true;
		}
		cache[key][0] = true;
		if (d > duration[key]) duration[key] = d;
	}
}