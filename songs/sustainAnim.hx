function onNoteHit(e){
    if(e.note.isSustainNote){
        e.preventAnim();
        e.character.lastAnimContext = 'LOCK';
        e.character.danceOnBeat = false;
        if(!e.note.nextNote.isSustainNote)
            e.character.lastAnimContext = 'SING';
    }
}

function onPlayerMiss(e){
    if(e.note.isSustainNote){
        e.character.lastAnimContext = 'LOCK';
        e.character.danceOnBeat = false;
        if(!e.note.nextNote.isSustainNote)
            e.character.lastAnimContext = 'MISS';
        e.preventAnim();
        e.preventVocalsUnmute();
        e.healthGain = e.misses = e.score = e.accuracy = 0;
        e.preventMissSound();
        }
}