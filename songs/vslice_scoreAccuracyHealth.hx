import flixel.util.FlxStringUtil;
import funkin.game.PlayState.ComboRating;

var tallies = [ //here for now
    'total' => 0,

    'sick' => 0,
    'good' => 0,
    'bad' => 0,
    'shit' => 0,
    'miss' => 0,
];

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

        tallies['total'] += 1;
        tallies[e.rating] += 1;
    } else {
    var curNote = e.note;
    if(curNote != null){
    FlxG.signals.postUpdate?.removeAll();
    FlxG.signals.postUpdate.add(function() {
      if(!paused){
        if(curNote != null && curNote.isSustainNote && curNote.nextNote != null && curNote.nextNote.isSustainNote){
            songScore += 250.0 * FlxG.elapsed;
            health += (6.0 / 100.0 * maxHealth) * FlxG.elapsed;
        }

        if(curNote != null && (curNote.nextNote == null || !curNote.nextNote.isSustainNote)){
            curNote = null;
            FlxG.signals.postUpdate?.removeAll();
        }
      }
    });
    }
    }
}

function onPlayerMiss(e){
    e.healthGain = e.score = e.accuracy = 0; //cancelling normal stuff

    if(e.note.isSustainNote){

    e.preventAnim();

    e.misses = 0;

    var nextNote = e.note.nextNote;
    var length:Float = e.note.nextNote.sustainLength;

    FlxG.signals.postUpdate?.removeAll();

    while(nextNote.nextNote.isSustainNote){
        length += nextNote.nextNote.sustainLength;
        var tempNextNote = nextNote.nextNote;
        nextNote.destroy();
        nextNote = tempNextNote;
    }

    if(nextNote.isSustainNote){
      nextNote.destroy();
      length += nextNote.sustainLength;
    }

    if(!e.note.nextNote.isSustainNote)
      length = 0;

    for(char in e.characters)
		  char.playSingAnim(e.direction, e.animSuffix, 'LOCK', true);

    trace(length);

    var remainingLengthSec = length / 1000;
    var healthChangeUncapped = remainingLengthSec * (0 / 100.0 * maxHealth);
    var healthChangeMax = (0 / 100.0 * maxHealth) + (-4.0 / 100.0 * maxHealth);
    var healthChange = clamp(healthChangeUncapped, 0, healthChangeMax);
    trace(healthChange);
    var scoreChange = Std.int(-125.0 * remainingLengthSec);

    e.healthGain = healthChange;
    songScore += scoreChange;
    } else {
      if (!e.note.avoid)
        tallies['miss'] += 1;
      e.score = -100;
      e.healthGain = -4.0 / 100.0 * maxHealth;
    }
}

updateRatingStuff = function(){
    scoreTxt.text = 'Score:' + FlxStringUtil.formatMoney(songScore, false, true);
    missesTxt.text = (comboBreaks ? TEXT_GAME_COMBOBREAKS : TEXT_GAME_MISSES).format([misses]);

    accuracy = tallies['total'] == 0 ? -1.0 : Math.max(0, (tallies['sick'] + tallies['good'] - tallies['miss']) / tallies['total']);

    accFormat.format.color = (tallies['total'] == tallies['sick'] && tallies['total'] != 0) ? FlxColor.fromRGBFloat(1.00000000000, 1.00000000000, 0.39607843137) : getRatingColor(accuracy);
    accuracyTxt.text = TEXT_GAME_ACCURACY.format([accuracy < 0 ? "-%" : CoolUtil.quantize(accuracy * 100, 100) + '%', getRating(accuracy)]);
    for (i => frmtRange in accuracyTxt._formatRanges) if (frmtRange.format == accFormat) {
				accuracyTxt._formatRanges[i].range.start = accuracyTxt.text.length - getRating(accuracy).length;
				accuracyTxt._formatRanges[i].range.end = accuracyTxt.text.length;
				break;
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

  public function getRating(accuracy:Float):String {
    return switch (true)
    {
      case(accuracy == 1):
        'P';
      case(accuracy >= 0.9):
        'E';
      case(accuracy >= 0.8 || accuracy >= 0.6):
        'G';
      default:
        'L';
    }
  }

    public function getRatingColor(accuracy:Float):FlxColor {
    return switch (true)
    {
      case(accuracy == 1):
        FlxColor.fromRGBFloat(1.00000000000, 0.71372549020, 1.00000000000);
      case(accuracy >= 0.9):
        FlxColor.fromRGBFloat(1.00000000000, 1.00000000000, 0.79607843137);
      case(accuracy >= 0.8):
        FlxColor.fromRGBFloat(0.94117647059, 0.99215686275, 1.00000000000);
      case(accuracy >= 0.6):
        FlxColor.fromRGBFloat(0.98039215686, 0.65882352941, 0.52156862745);
      default:
        FlxColor.fromRGBFloat(0.45098039216, 0.57647058824, 1.00000000000);
    }
  }

  //from flxmath
  function clamp(Value:Float, Min:Float, Max:Float):Float {
    return (Value < Min) ? Min : ((Value > Max) ? Max : Value);
  }