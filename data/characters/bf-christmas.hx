function onNoteHit(e)
    if (e.character == this && e.noteType == 'censor')
        e.animSuffix = '-censor';