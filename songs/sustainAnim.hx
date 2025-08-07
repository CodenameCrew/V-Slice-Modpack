function onNoteHit(e){
    if(e.note.isSustainNote){
        e.preventAnim();
        e.character.lastAnimContext = 'LOCK';
        if(e.note.nextNote == null || !e.note.nextNote.isSustainNote){
            var event = e;
            new FlxTimer().start(0.05, function(timer) {
                event.character.lastAnimContext = 'SING';
            });
        }
    }
}

function onPlayerMiss(e){
    if(e.note.isSustainNote){
        e.character.lastAnimContext = 'LOCK';
        if(e.note.nextNote == null || !e.note.nextNote.isSustainNote){
            var event = e;
            new FlxTimer().start(0.05, function(timer) {
                event.character.lastAnimContext = 'MISS';
            });
        }
        e.preventAnim();
        e.preventVocalsUnmute();
        e.healthGain = e.misses = e.score = e.accuracy = 0;
        e.preventMissSound();
    }
}