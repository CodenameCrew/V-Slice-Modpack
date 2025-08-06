// import funkin.savedata.FunkinSave;
// import funkin.savedata.HighscoreChange;
// import Date;

// var data = [
//     'total' => 0,
//     'max' => 0,

//     'sick' => 0,
//     'good' => 0,
//     'bad' => 0,
//     'shit' => 0,
//     'miss' => 0,

//     'score' => 0,
//     'accuracy' => 0.0
// ];

// function onStartSong() {
//     inst.onComplete = _endSong;

//     // carry over judgements for each song in story mode
//     if (PlayState.isStoryMode) {
//         if (PlayState.storyPlaylist.length != PlayState.storyWeek.songs.length) {
//             for (n => v in FlxG.save.data.resultsShit) {
//                 data[n] = v;
//             }
//         } else {
//             for (n => v in data) {
//                 data[n] = 0;
//             }
//         }
//     }

//     // trace(data);
// }

// function _endSong()
// {
// 	scripts.call('onSongEnd');
// 	canPause = false;
// 	inst.volume = 0;
// 	vocals.volume = 0;
// 	for (strumLine in strumLines.members) {
// 		strumLine.vocals.volume = 0;
// 		strumLine.vocals.pause();
// 	}
// 	inst.pause();
// 	vocals.pause();

// 	if (validScore)
// 	{
// 		FunkinSave.setSongHighscore(PlayState.SONG.meta.name, PlayState.difficulty, {
// 			score: songScore,
// 			misses: misses,
// 			accuracy: accuracy,
// 			hits: [],
// 			date: Date.now().toString()
// 		}, getSongChanges());
// 	}

//     // it has to be like this because it returns already set score + other score
//     // so its just less lines ok?

//     if (!PlayState.isStoryMode) {
//         data['score'] = songScore;
//         data['accuracy'] = accuracy;
//     } else {
//         data['score'] = PlayState.campaignScore = PlayState.campaignScore + songScore;
//         data['miss'] = PlayState.campaignMisses = PlayState.campaignMisses + misses;
//         data['accuracy'] = (PlayState.campaignAccuracyTotal = PlayState.campaignAccuracyTotal + accuracy) / (PlayState.campaignAccuracyCount = PlayState.campaignAccuracyCount + 1);
//     }

//     FlxG.save.data.resultsShit = data;

// 	startCutscene('end-', endCutscene, () -> {
//         if (!PlayState.chartingMode && (PlayState.isStoryMode ? PlayState.storyPlaylist.length == 1 : true)) {
//             if (validScore)
// 			{
//                 if (PlayState.storyWeek != null) {
// 				    // TODO: more week info saving
// 				    FunkinSave.setWeekHighscore(PlayState.storyWeek.id, PlayState.difficulty, {
// 				    	score: data['score'],
// 				    	misses: data['miss'],
// 				    	accuracy: data['accuracy'],
// 				    	hits: [],
// 				    	date: Date.now().toString()
// 				    });
//                 }
//                 FlxG.switchState(new ModState('ResultsState'));
// 			}
//         } else {
//             nextSong();
//         }
//     });

//     PlayState.storyPlaylist.shift();
    
// 	PlayState.resetSongInfos();
// }

// function getSongChanges() {
//     var a = [];
//     if (PlayState.opponentMode)
//         a.push(HighscoreChange.COpponentMode);
//     if (PlayState.coopMode)
//         a.push(HighscoreChange.CCoopMode);
//     return a;
// }

// function onNoteHit(e) {
//     if (!e.note.isSustainNote && e.player) {
//         data[e.rating] += 1;
//         data['total'] += 1;
//         data['max'] = Math.max(data['max'], combo + 1);
//         //trace(data);
//     }
// }

// function onPlayerMiss(e) {
//     if (!e.note.avoid) {
//         data['miss'] += 1;
//         //trace(data);
//     }
// }