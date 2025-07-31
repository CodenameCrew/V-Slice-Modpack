//
import game.NoteCoverHandler;

/*
 * Whether to init the note hold covers if set to true (to set before onStrumCreation).
*/
public var initHoldCovers:Bool = true;
public var noteCoversHandler:NoteCoverHandler;

public var ratingScaleDiff:Float = 0.1;

function onPostStrumCreation(e)
{
    if (!hideHoldCovers) return;

    if (noteCoversHandler == null)
        add(noteCoversHandler = new NoteCoverHandler());

    noteCoversHandler.cacheStuff(e.strumID);
}

function create() {
    comboGroup.x = 560;
    comboGroup.y = 290;
}

function onPostCountdown(event) {
    var spr = event.sprite;
    if (spr != null) {
        spr.camera = camHUD;
        spr.scale.set(1, 1);
    }

    // prevents tweening the y  - Nex
    var props = event.spriteTween?._propertyInfos;
    if (props != null) for (info in props)
        if (info.field == "y") event.spriteTween._propertyInfos.remove(info);
}

function onNoteHit(event) {
    event.numScale -= ratingScaleDiff;
    event.ratingScale -= ratingScaleDiff;

    if (!e.cancelled && e.note.isSustainNote && e.note.__strum != null && noteCoversHandler != null) {
        noteCoversHandler.showCover();

        if (e.note.animation.name == "holdend")
            noteCoversHandler.coverSpark(e.note.__strum, e.note.height / 3.5, e.player);
    }
}

function onPlayerMiss(e)
    if (noteCoversHandler.cacheStuff(e.note.__strum.ID).cover.visible)
        noteCoversHandler.coverSpark(e.note.__strum, null);

function update()
    comboGroup.forEachAlive(function(spr) if (spr.camera != camHUD) spr.camera = camHUD);