//
var picoPlayer:FunkinSprite;
var picoOpponent:FunkinSprite;
var bloodPool:FunkinSprite;
var cigarette:FlxSprite;

var cutsceneMusic:FlxSound;

var playerShoots:Bool;
var explode:Bool;

function create()
{
    game.dad.visible = game.boyfriend.visible = game.camHUD.visible = false;
	game.persistentUpdate = true;

    // 50/50 chance for who shoots
    playerShoots = FlxG.random.bool(50);
    explode = FlxG.random.bool(8);

    game.insert(game.members.indexOf(playerShoots ? game.boyfriend : game.dad) + 1, picoOpponent = new FunkinSprite(game.dad.x + game.dad.globalOffset.x + 87, game.dad.y + game.dad.globalOffset.y + 395));
    game.insert(game.members.indexOf(playerShoots ? game.dad : game.boyfriend) + 1, picoPlayer = new FunkinSprite(game.boyfriend.x + game.boyfriend.globalOffset.x + 227, game.boyfriend.y + game.boyfriend.globalOffset.y + 395));

    picoOpponent.scrollFactor.set(game.dad.scrollFactor.x, game.dad.scrollFactor.y); picoPlayer.scrollFactor.set(game.boyfriend.scrollFactor.x, game.boyfriend.scrollFactor.y);
    picoOpponent.scale.set(game.dad.scale.x, game.dad.scale.y); picoPlayer.scale.set(game.boyfriend.scale.x, game.boyfriend.scale.y);
    picoOpponent.shader = game.dad.shader; picoPlayer.shader = game.boyfriend.shader;
    picoPlayer.flipX = true;

    for (char in [picoOpponent, picoPlayer])
    {
        char.loadSprite(Paths.image("game/cutscenes/pico/pico_doppleganger"));
        char.antialiasing = true;

		// all offsets for each animation are fucked
		
		char.animateAtlas.anim.addBySymbol('shoot', 'compressed/picoShoot', 24, false);

		// i think these 2 are flipped?
		char.animateAtlas.anim.addBySymbol('explode', 'compressed/picoExplode', 24, false);
		char.animateAtlas.anim.addBySymbol('cigarette', 'compressed/picoCigarette', 24, false);
    }

    cutsceneMusic = FlxG.sound.load(Paths.music("pico/" + (!explode ? "cutscene" : "cutscene2")), 1, true);
    cutsceneMusic.play(false);

    /*if (playerShoots)
    {
        picoOpponent.zIndex = picoPlayer.zIndex - 1;
        bloodPool.zIndex = picoOpponent.zIndex - 1;
        cigarette.zIndex = PlayState.instance.currentStage.getBoyfriend().zIndex - 2;
        cigarette.flipX = true;

        cigarette.setPosition(PlayState.instance.currentStage.getBoyfriend().x - 143.5, PlayState.instance.currentStage.getBoyfriend().y + 210);
        bloodPool.setPosition(PlayState.instance.currentStage.getDad().x - 1487, PlayState.instance.currentStage.getDad().y - 173);

        shooterPos = [PlayState.instance.currentStage.getBoyfriend().cameraFocusPoint.x, PlayState.instance.currentStage.getBoyfriend().cameraFocusPoint.y];
        cigarettePos = [PlayState.instance.currentStage.getDad().cameraFocusPoint.x, PlayState.instance.currentStage.getDad().cameraFocusPoint.y];
    }
    else
    {
        picoOpponent.zIndex = picoPlayer.zIndex + 1;
        bloodPool.zIndex = picoPlayer.zIndex - 1;
        cigarette.zIndex = PlayState.instance.currentStage.getDad().zIndex - 2;

        bloodPool.setPosition(PlayState.instance.currentStage.getBoyfriend().x - 788.5, PlayState.instance.currentStage.getBoyfriend().y - 173);
        cigarette.setPosition(PlayState.instance.currentStage.getBoyfriend().x - 478.5, PlayState.instance.currentStage.getBoyfriend().y + 205);

        cigarettePos = [PlayState.instance.currentStage.getBoyfriend().cameraFocusPoint.x, PlayState.instance.currentStage.getBoyfriend().cameraFocusPoint.y];
        shooterPos = [PlayState.instance.currentStage.getDad().cameraFocusPoint.x, PlayState.instance.currentStage.getDad().cameraFocusPoint.y];
    }

    var midPoint:Array<Float> = [(shooterPos[0] + cigarettePos[0])/2, (shooterPos[1] + cigarettePos[1])/2];

		cigarette.frames = Paths.getSparrowAtlas('philly/erect/cigarette');
    cigarette.animation.addByPrefix('cigarette spit', 'cigarette spit', 24, false);
		cigarette.visible = false;

		PlayState.instance.currentStage.add(cigarette);
		PlayState.instance.currentStage.add(picoPlayer);
    PlayState.instance.currentStage.add(picoOpponent);
		PlayState.instance.currentStage.add(bloodPool);
		PlayState.instance.currentStage.refresh();

		picoPlayer.shader = colorShader;
		picoOpponent.shader = colorShader;
		bloodPool.shader = colorShader;

		PlayState.instance.currentStage.getBoyfriend().visible = false;
		PlayState.instance.currentStage.getDad().visible = false;

		picoPlayer.scriptCall('doAnim', ['Player', playerShoots, explode, cutsceneTimerManager]);
		picoOpponent.scriptCall('doAnim', ['Opponent', !playerShoots, explode, cutsceneTimerManager]);

		FunkinSound.playOnce(Paths.sound('cutscene/picoGasp'), 1);

		PlayState.instance.resetCamera(false, true);
    PlayState.instance.cameraFollowPoint.setPosition(midPoint[0], midPoint[1]);

		new FlxTimer(cutsceneTimerManager).start(4, _ -> {

			PlayState.instance.cameraFollowPoint.setPosition(cigarettePos[0], cigarettePos[1]);
		});

		new FlxTimer(cutsceneTimerManager).start(6.3, _ -> {
			PlayState.instance.cameraFollowPoint.setPosition(shooterPos[0], shooterPos[1]);
		});

		new FlxTimer(cutsceneTimerManager).start(8.75, _ -> {
			cutsceneSkipped = true;
			canSkipCutscene = false;
			FlxTween.tween(skipText, {alpha: 0}, 0.5, {ease: FlxEase.quadIn, onComplete: _ -> {skipText.visible = false;}});
			// cutting off skipping here. really dont think its needed after this point and it saves problems from happening
			PlayState.instance.cameraFollowPoint.setPosition(cigarettePos[0], cigarettePos[1]);
			if(explode == true)
				PlayState.instance.currentStage.getGirlfriend().playAnimation('drop70', true);
		});

		new FlxTimer(cutsceneTimerManager).start(11.2, _ -> {
			if(explode == true)
				bloodPool.scriptCall('doAnim');
		});

		new FlxTimer(cutsceneTimerManager).start(11.5, _ -> {
			if(explode == false){
				cigarette.visible = true;
				cigarette.animation.play('cigarette spit');
			}
		});

		new FlxTimer(cutsceneTimerManager).start(13, _ -> {

			if(explode == false || playerShoots == true){
				PlayState.instance.startCountdown();
			}

			if(explode == true){
				if(playerShoots == true){
					picoPlayer.visible = false;
					PlayState.instance.currentStage.getBoyfriend().visible = true;
				}else{
					picoOpponent.visible = false;
					PlayState.instance.disableKeys = true;
					PlayState.instance.currentStage.getDad().visible = true;

					new FlxTimer().start(1, function(tmr)
					{
						PlayState.instance.camCutscene.fade(0xFF000000, 1, false, null, true);
					});

					new FlxTimer().start(2, function(tmr)
					{
						PlayState.instance.camCutscene.fade(0xFF000000, 0.5, true, null, true);
						PlayState.instance.endSong(true);
					});
				}
			}else{
				picoPlayer.visible = false;
				PlayState.instance.currentStage.getBoyfriend().visible = true;
				picoOpponent.visible = false;
				PlayState.instance.currentStage.getDad().visible = true;
			}

			hasPlayedCutscene = true;
			cutsceneMusic.stop();
        });*/
}

function destroy()
{
    game.camHUD.visible = game.boyfriend.visible = game.dad.visible = true;
    for (thing in [picoPlayer, picoOpponent, bloodPool, cigarette, cutsceneMusic]) if (thing != null)
    {
        if (thing != cutsceneMusic) game.remove(thing);
        thing.destroy();
    }
}