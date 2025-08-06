var firstSusMissed:Bool = true;

function onNoteHit(e){
    if(e.note.isSustainNote){
        e.preventAnim();
        e.character.danceOnBeat = false;
    }
}

function onPlayerMiss(e){
    if(e.note.isSustainNote){
        if(firstSusMissed){
            firstSusMissed = false;
        } else{
            if(!e.character.animation.curAnim.paused){
                e.character.animation.curAnim.pause();
                e.preventAnim();
            }
            e.forceAnim = false;
            e.preventVocalsUnmute();
            e.healthGain = e.misses = e.score = e.accuracy = 0;
            e.preventMissSound();
        }
    } else {
        if(e.note.nextNote.isSustainNote)
            firstSusMissed = false;
    }
}