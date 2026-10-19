import flixel.FlxObject;
import funkin.game.StrumLine;

var test:StrumLine;
function postCreate() {
    for(bg in [bg,magenta]){
        bg.scrollFactor.x = 0; 
        bg.scrollFactor.y = 0.17;
        bg.setGraphicSize(Std.int(FlxG.width * 1.2));
        bg.updateHitbox();
        bg.screenCenter();
    }
    
    camFollow = new FlxObject(camFollow, 0, 1, 1);

    var spacing = 160;
    var top = (FlxG.height - (spacing * (menuItems.length - 1))) / 2;
    for (i in 0...menuItems.length)
    {
      var menuItem = menuItems.members[i];
      menuItem.x = FlxG.width / 2;
      menuItem.y = top + spacing * i;
      menuItem.scrollFactor.x = 0;
      menuItem.scrollFactor.y = 0.4;

      if (i == 1)
      {
        camFollow.setPosition(menuItem.getGraphicMidpoint().x, menuItem.getGraphicMidpoint().y);
      }
    }
    camFollow.y = bg.getGraphicMidpoint().y;
    FlxG.camera.follow(camFollow, null, 0.06);

    test = new StrumLine([], FlxPoint.get(50, 50), 1, false, false, controls);
    for (i in 0...4)
			test.add(test.createStrum(i));
    add(test);

    test.notes.preallocate(16);
    test.notes.addNotes([
      for (x=>i in [0,1,2,3,2,1,0,1,2,3,2,3,2,3,1,0])
        new Note(test, {time:2000 + x*100, id:i}, false, 0, 0, null)
    ]);

    test.onHit.add(goodNoteHit);

    FlxG.sound.music.time = Conductor.songPosition = 0;
}

function update(elapsed) {
  for (i in 0...test.members.length) {
    test.updateInput(i);
  }
  justPressed = false;
}
var justPressed = false;
function goodNoteHit(e) {
  if (justPressed) return;
  var note = e.note;
  if (!note.wasGoodHit) {
    note.wasGoodHit = true;
    test.members[note.strumID].press(Conductor.songPosition);
    test.deleteNote(note);
    justPressed = true;
  }
}