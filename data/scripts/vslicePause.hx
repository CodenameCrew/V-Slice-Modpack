import flixel.util.FlxStringUtil;

var artistChartInfo:FunkinText;

function postCreate() {
    for(label in [levelInfo, levelDifficulty, deathCounter, multiplayerText]) {
        if(label == null) continue;
        FlxTween.cancelTweensOf(label);
    }

    //TODO: add translations
    artistChartInfo = new FunkinText(20, 15, 0, "Artist: " + (PlayState.SONG.meta.customValues?.artist ?? "Unknown (change in the metadata)"), 32, false);
    levelDifficulty.text = "Difficulty: " + FlxStringUtil.toTitleCase(PlayState.difficulty);
    deathCounter.text = PlayState.deathCounter + " Blue Balls";

	for(k=>label in [levelInfo, artistChartInfo, levelDifficulty, deathCounter, multiplayerText]) {
		if(label == null) continue;
		label.scrollFactor.set();
		label.alpha = 0;
		label.x = FlxG.width - (label.width + 20);
		label.y = 15 + (32 * k);
		FlxTween.tween(label, {alpha: 1, y: label.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 * (k+1)});
		add(label);
	}

    startFadeTimer();
}

var CHARTER_FADE_DELAY:Float = 15.0;
var CHARTER_FADE_DURATION:Float = 0.75;

var charterFadeTween:Null<FlxTween> = null;

var switchToCharter:Bool = true;

function startFadeTimer(){
    charterFadeTween = FlxTween.tween(artistChartInfo, {alpha: 0.0}, CHARTER_FADE_DURATION,
      {
        startDelay: CHARTER_FADE_DELAY,
        ease: FlxEase.quartOut,
        onComplete: (_) -> {
            artistChartInfo.text = switchToCharter ? "Charter: " + (PlayState.SONG.meta.customValues?.charter ?? "Unknown (change in the metadata)") : "Artist: " + (PlayState.SONG.meta.customValues?.artist ?? "Unknown (change in the metadata)");
            artistChartInfo.x = FlxG.width - (artistChartInfo.width + 20);
            switchToCharter = !switchToCharter;

            FlxTween.tween(artistChartInfo, {alpha: 1.0}, CHARTER_FADE_DURATION,
            {
              ease: FlxEase.quartOut,
              onComplete: startFadeTimer
            });
        }
      }
    );
}