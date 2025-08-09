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
    game.camHUD.visible = false;
	game.persistentUpdate = true;

	for (o in [0, 1]) {
		for (i in game.strumLines.members[o].characters) {
			i.alpha = 0;
		}
	}

    // 50/50 chance for who shoots
    playerShoots = FlxG.random.bool(50);
    explode = FlxG.random.bool(8);

	playerShoots = true;
	explode = true;

    game.insert(game.members.indexOf(playerShoots ? game.boyfriend : game.dad) + 1, picoOpponent = new FunkinSprite(game.dad.x + game.dad.globalOffset.x + 87, game.dad.y + game.dad.globalOffset.y + 395));
    game.insert(game.members.indexOf(playerShoots ? game.dad : game.boyfriend) + 1, picoPlayer = new FunkinSprite(game.boyfriend.x + game.boyfriend.globalOffset.x + 244, game.boyfriend.y + game.boyfriend.globalOffset.y + 395));

    picoOpponent.scrollFactor.set(game.dad.scrollFactor.x, game.dad.scrollFactor.y); picoPlayer.scrollFactor.set(game.boyfriend.scrollFactor.x, game.boyfriend.scrollFactor.y);
    picoOpponent.scale.set(game.dad.scale.x, game.dad.scale.y); picoPlayer.scale.set(game.boyfriend.scale.x, game.boyfriend.scale.y);
    picoOpponent.shader = game.dad.shader; picoPlayer.shader = game.boyfriend.shader;

	var awesomeOffset = (a) -> {
		return (a ? -210 : 378);
	}
    for (char in [picoOpponent, picoPlayer])
    {
        char.loadSprite(Paths.image("game/cutscenes/pico/pico_doppleganger"));
        char.antialiasing = true;

		// all offsets for each animation are fucked
		
		char.addAnim('shoot', 'compressed/picoShoot', 24, false, true, null, awesomeOffset(!playerShoots), 205);

		// i think these 2 are flipped?
		char.addAnim('explode', 'compressed/picoExplode', 24, false, true, null, awesomeOffset(playerShoots), 205);
		char.addAnim('explode-loop', 'compressed/picoExplode', 12, true, true, [268, 270, 272, 274], awesomeOffset(playerShoots), 205);
		char.addAnim('cigarette', 'compressed/picoCigarette', 24, false, true, null, awesomeOffset(playerShoots), 205);
		char.flipX = playerShoots; // ???

		char.x += 170 * (!playerShoots ? 1 : 0);
    }

	var pico1 = playerShoots ? picoPlayer : picoOpponent;
	var pico2 = !playerShoots ? picoPlayer : picoOpponent;

	pico2.playAnim(explode ? 'explode' : 'cigarette');
	pico1.playAnim('shoot');
	var off = 222 * (playerShoots ? 1 : -1);
	pico1.x -= off;
	pico2.x += off;

	//trace(playerShoots);

    cutsceneMusic = FlxG.sound.load(Paths.music("pico/" + (!explode ? "cutscene" : "cutscene2")), 1, false);
    cutsceneMusic.play(false);

	var oppPos = game.getStrumlineCamPos(playerShoots ? 0 : 1, null, false);
	var plrPos = game.getStrumlineCamPos(playerShoots ? 1 : 0, null, false);

	game.camFollow.setPosition(FlxMath.lerp(oppPos.pos.x, plrPos.pos.x, 0.5), FlxMath.lerp(oppPos.pos.y, plrPos.pos.y, 0.5));

	if (explode) {
		bloodPool = new FunkinSprite();
		bloodPool.loadSprite(Paths.image("game/cutscenes/pico/bloodPool"));
        bloodPool.antialiasing = true;
		bloodPool.addAnim('loop', 'bloodPool', 24, false, true, null, 1290, 600);
		bloodPool.playAnim('loop');
		bloodPool.scrollFactor.set(pico2.scrollFactor.x, pico2.scrollFactor.y);
		bloodPool.y = pico2.y + 35;
		bloodPool.x = pico2.x - 60;
		bloodPool.x += playerShoots ? -445 : 250;
		bloodPool.active = bloodPool.visible = false;
		bloodPool.shader = pico2.shader;

		bloodPoolHelperCusAtlasSucks = new FunkinSprite();
		bloodPoolHelperCusAtlasSucks.makeSolid(1, 1, 0x00000000);
		bloodPoolHelperCusAtlasSucks.screenCenter();
		bloodPoolHelperCusAtlasSucks.scrollFactor.set();
		bloodPoolHelperCusAtlasSucks.onDraw = (b) -> {
			if (game.persistentUpdate) {
				if (bloodPool.isAnimAtEnd()) {
					var val = 0.02 * FlxG.elapsed;
					bloodPool.scale.x += val;
					bloodPool.scale.y += val;
				}
			}
			if (bloodPool.visible) bloodPool.draw();
		}

		game.insert(game.members.indexOf(pico2), bloodPool);
		game.insert(game.members.indexOf(pico2), bloodPoolHelperCusAtlasSucks);
	}

	//game.camGame.zoom = 0.6;
	//FlxG.sound.play(Paths.sound('cutscenes/pico/picoGasp'));

	var cigSfx = null;
	var timeline = [
		[0.3, () -> {
			FlxG.sound.play(Paths.sound('cutscenes/pico/picoGasp'));
		}],
		[3.7, () -> {
			cigSfx = FlxG.sound.play(Paths.sound('cutscenes/pico/picoCigarette'));
		}],
		[4, () -> {
			game.camFollow.setPosition(oppPos.pos.x, oppPos.pos.y);
		}],
		[6.3, () -> {
			game.camFollow.setPosition(plrPos.pos.x, plrPos.pos.y);
			FlxG.sound.play(Paths.sound('cutscenes/pico/picoShoot'));
		}],
		[8.75, () -> {
			game.camFollow.setPosition(oppPos.pos.x, oppPos.pos.y);
			if(explode) {
				cigSfx.stop();
				game.gf.playAnim('drop70');
			}
		}],
		[10.33, () -> {
			FlxG.sound.play(Paths.sound('cutscenes/pico/picoSpin'));
		}],
		[11.2, () -> {
			if (!explode) return;

			bloodPool.active = bloodPool.visible = true;
		}],
		[13, () -> {
			for (o => i in [picoOpponent, picoPlayer]) {
				if (explode) {
					if (!shouldBeVisible(o))
						excludeStuff.push(i);
				}
			}
			close();
		}]
	];
	for (i in timeline) {
		timelineTimers.push(new FlxTimer().start(i[0], (_) -> {
			i[1]();
		}));
	}
}

var timelineTimers = [];
var excludeStuff = [];

function destroy()
{
    game.camHUD.visible = true;
    for (thing in [picoPlayer, picoOpponent, cigarette, cutsceneMusic]) if (thing != null && excludeStuff.indexOf(thing) == -1)
    {
        if (thing != cutsceneMusic) game.remove(thing);
        thing.destroy();
    }
	for (t in timelineTimers) {
		t.cancel();
	}
	game.camHUD.alpha = 0;
	FlxTween.tween(game.camHUD, {alpha: 1}, 0.25);

	for (o in [0, 1]) {
		for (i in game.strumLines.members[o].characters) {
			if (shouldBeVisible(o))
				i.alpha = 1;
		}
	}

	if (explode) {
		if (((game.canDie && !playerShoots) || (game.canDadDie && playerShoots))) {
			game.endSong();
			return;
		}
		game.scripts.importScript('data/scripts/opponent-no-notes');
		__explodedChar = playerShoots ? 0 : 1;
	}
}

function shouldBeVisible(o) {
	if (explode) {
		if (!playerShoots) return o != 1;
		return o != 0;
	}
	return true;
}