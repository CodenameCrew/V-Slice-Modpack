function onNoteHit(e){
    if(e.note.isSustainNote){
        e.preventAnim();
        e.character.lastAnimContext = 'LOCK';
        if(e.note.nextNote == null || !e.note.nextNote.isSustainNote)
            e.character.lastAnimContext = 'SING';
    }
}

function onPlayerMiss(e){
    if(e.note.isSustainNote){
        e.character.lastAnimContext = 'LOCK';
        trace(e.note.nextNote);
        if(e.note.nextNote == null || !e.note.nextNote.isSustainNote)
            e.character.lastAnimContext = 'MISS';
        e.preventAnim();
        e.preventVocalsUnmute();
        e.healthGain = e.misses = e.score = e.accuracy = 0;
        e.preventMissSound();
        }
}