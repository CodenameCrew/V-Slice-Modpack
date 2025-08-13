function onPlayerHit(e){
    e.healthGain = e.score = e.accuracy = 0; //cancelling normal stuff

    var noteDiff = Math.abs(Conductor.songPosition - e.note.strumTime);  

    if(!e.note.isSustainNote){
        e.score = scoreNote(noteDiff);
        e.rating = judgeNote(noteDiff);

        switch(e.rating){
            case 'sick':
                e.healthGain = 1.5 / 100.0 * maxHealth;
            case 'good':
                e.healthGain = 0.75 / 100.0 * maxHealth; 
            case 'bad':
                e.healthGain = 0.0 / 100.0 * maxHealth; 
            case 'shit':
                e.healthGain = -1.0 / 100.0 * maxHealth; 
            case 'miss':
                e.misses = true;
                e.showRating = false;
        }
    } else {
    var curNote = e.note;
    if(curNote != null){
    FlxG.signals.postUpdate?.removeAll();
    FlxG.signals.postUpdate.add(function() {
        if(curNote != null && curNote.isSustainNote && curNote.nextNote != null && curNote.nextNote.isSustainNote){
            songScore += 250.0 * FlxG.elapsed;
            health += (6.0 / 100.0 * maxHealth) * FlxG.elapsed;
        }

        if(curNote != null && (curNote.nextNote == null || !curNote.nextNote.isSustainNote)){
            curNote = null;
            FlxG.signals.postUpdate?.removeAll();
        }
    });
    }
    }
}

function onPlayerMiss(e){
    curNoteMissed = e.note;

    if(e.note.isSustainNote){
    var nextNote = e.note;
    var length:Float = e.note.sustainLength;

    while(nextNote.nextNote.isSustainNote){
        length += nextNote.nextNote.sustainLength;
        nextNote = nextNote.nextNote;
    }
    missedSustainLength = length;
}
}

function scoreNote(timing:Float):Int
  {
    return switch (true)
    {
      case(timing > 160.0):
        -100;
      case(timing < 5.0):
        500;
      default:
        // Fancy equation.
        var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-0.080 * (timing - 54.99))));

        var score:Int = Std.int(500 * factor + 9.0);

        score;
    }
  }

function judgeNote(timing:Float):String
  {
    return switch (true)
    {
      case(timing < 45.0):
        'sick';
      case(timing < 90.0):
        'good';
      case(timing < 135.0):
        'bad';
      case(timing < 160.0):
        'shit';
      default:
        'miss';
    }
  }