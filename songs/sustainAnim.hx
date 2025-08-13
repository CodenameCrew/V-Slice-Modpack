function onNoteHit(e){
    if(e.note.isSustainNote){
        e.preventAnim();
        
        for(i in 0...e.characters.length){
            e.characters[i].lastAnimContext = 'LOCK';
            if(e.note.nextNote == null || !e.note.nextNote.isSustainNote){
                var event = e;
                event.characters[i].lastHit = Conductor.songPosition + 30;           
                event.characters[i].lastAnimContext = 'SING';
            }
        }
    }
}

function onPlayerMiss(e){
    if(e.note.isSustainNote){

        for(i in 0...e.characters.length){
            e.characters[i].lastAnimContext = 'LOCK';
            if(e.note.nextNote == null || !e.note.nextNote.isSustainNote){
                var event = e;
                event.characters[i].lastHit = Conductor.songPosition + 30;
                event.characters[i].lastAnimContext = 'MISS';
            }
        }
            e.preventAnim();
            e.preventVocalsUnmute();
            e.preventMissSound();
    }
}