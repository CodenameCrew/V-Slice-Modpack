public var __explodedChar = 0;
function onNoteHit(e) {
    if (e.note.strumLine.ID == __explodedChar) {
        e.cancel();
        e.note.wasGoodHit = e.autoHitLastSustain = e.deleteNote = false;
        e.cancelVocalsUnmute();
        e.note.strumLine.vocals.volume = 0;
        vocals?.volume = 0;
    }
}