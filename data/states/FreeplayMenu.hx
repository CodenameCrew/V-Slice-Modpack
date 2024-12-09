import haxe.io.Path;
import SongMenuItem;
import BGScrollingText;
import flxanimate.frames.FlxAnimateFrames;
import flixel.tweens.FlxTween.FlxTweenType;
import funkin.menus.FreeplayState.FreeplaySonglist;
import funkin.backend.system.framerate.Framerate;

var freeplayCam = new FlxCamera();

var introMovers:Map<Array<FlxSprite>, Dynamic> = [];
var exitMovers:Map<Array<FlxSprite>, Dynamic> = [];

var backingCard = {};

var characters = {
	bf: {
		texts: [
			"BOYFRIEND",
			"HOT BLOODED IN MORE WAYS THAN ONE",
			"PROTECT YO NUTS",
		]
	},
}

function createBackingcard(style:String)
{
	switch (style)
	{
		default:
			backingCard.pinkBack = new FlxSprite(0).loadGraphic(Paths.image('freeplay/pinkBack'));
			backingCard.pinkBack.x = -backingCard.pinkBack.width;
			add(backingCard.pinkBack);
			backingCard.pinkBack.color = 0xFFFFD863;

			backingCard.orangeBackShit = new FlxSprite(0, 440).makeGraphic(Std.int(backingCard.pinkBack.width), 75, 0xFFFEDA00);
			backingCard.orangeBackShit.x = -backingCard.orangeBackShit.width;
			add(backingCard.orangeBackShit);

			var currentCharacter = characters.bf;
			add(backingCard.funnyScroll = new BGScrollingText(0, 220, currentCharacter.texts[0], FlxG.width / 2, false, 60));
			add(backingCard.funnyScroll2 = new BGScrollingText(0, 335, currentCharacter.texts[0], FlxG.width / 2, false, 60));
			add(backingCard.moreWays = new BGScrollingText(0, 160, currentCharacter.texts[1], FlxG.width, true, 43));
			add(backingCard.moreWays2 = new BGScrollingText(0, 397, currentCharacter.texts[1], FlxG.width, true, 43));
			add(backingCard.txtNuts = new BGScrollingText(0, 285, currentCharacter.texts[2], FlxG.width / 2, true, 43));
			add(backingCard.funnyScroll3 = new BGScrollingText(0, backingCard.orangeBackShit.y + 10, currentCharacter.texts[0], FlxG.width / 2, false, 60));

			backingCard.moreWays.funnyColor = 0xFFFFF383;
			backingCard.moreWays.speed = 6.8;

			backingCard.funnyScroll.funnyColor = 0xFFFF9963;
			backingCard.funnyScroll.speed = -3.8;

			backingCard.txtNuts.speed = 3.5;

			backingCard.funnyScroll2.funnyColor = 0xFFFF9963;
			backingCard.funnyScroll2.speed = -3.8;

			backingCard.moreWays2.funnyColor = 0xFFFFF383;
			backingCard.moreWays2.speed = 6.8;

			backingCard.funnyScroll3.funnyColor = 0xFFFEA400;
			backingCard.funnyScroll3.speed = -3.8;

			backingCard.flashBar = new FlxSprite(0).loadGraphic(Paths.image('freeplay/pinkBack'));
			backingCard.flashBar.x = -backingCard.flashBar.width;
			add(backingCard.flashBar);
			backingCard.flashBar.alpha = 0;

			introMovers.set([backingCard.pinkBack, backingCard.flashBar, backingCard.orangeBackShit],
			{
				x: 0,
				speed: 1 + FlxG.random.float(-0.04, 0.04),
				wait: 0.15
			});

			exitMovers.set([backingCard.pinkBack, backingCard.flashBar, backingCard.orangeBackShit],
			{
				x: -backingCard.pinkBack.width,
				speed: 0.4 + FlxG.random.float(-0.04, 0.04),
				wait: 0.15
			});

			bfDJ = new FlxAnimate(660, 366);
			bfDJ.antialiasing = true;
			bfDJ.anim._loadAtlas(bfDJ.atlasSetting(Path.withoutExtension(Paths.image('freeplay/fpboyfriend'))));
			bfDJ.frames = state.stateScripts.get("bfDjAltasThingy") ?? FlxAnimateFrames.fromTextureAtlas(Path.withoutExtension(Paths.image('freeplay/fpboyfriend')));
			add(bfDJ);
			new FlxTimer().start(0.5, function(_)
			{
			    bfDJ.anim.play("boyfriend dj intro", true);
			    bfDJ.offset.set(6.7, 2.6);
			});

			exitMovers.set([bfDJ],
			{
			  x: -bfDJ.width * 1.6,
			  speed: 0.5
			});

			for (txt in [backingCard.funnyScroll, backingCard.funnyScroll2, backingCard.moreWays,
								backingCard.moreWays2, backingCard.txtNuts, backingCard.funnyScroll3, backingCard.orangeBackShit])
				txt.visible = false;
    }
}

function generateDifficultySprite(diff) {
	var spr = new FlxSprite();

	// Check for an XML to use an animation instead of an image.
	if (Assets.exists(Paths.file('images/freeplay/freeplay' + diff + '.xml')))
	{
		spr.frames = Paths.getSparrowAtlas('freeplay/freeplay' + diff);
		spr.animation.addByPrefix('idle', 'idle0', 24, true);
		spr.animation.play('idle');
	}
	else
		spr.loadGraphic(Paths.image('freeplay/freeplay' + diff));

	return spr;
}

var curSelected = 1;
var curDifficulty = 1;
var difficulties = ["easy", "normal", "hard", "erect", "nightmare"];
var difficultiesNoErect = ["easy", "normal", "hard"];

var diffSpr = null;

var freeplaySelectorLeft:FlxSprite;
var freeplaySelectorRight:FlxSprite;
function changeDifficulty(change, force = false) {
	if (change == null) change = 0;

	var hasErect = Assets.exists(Paths.inst(songs[curSelected][1], "", "-erect"));
	var oldDiff = curDifficulty;
	curDifficulty = FlxMath.wrap(curDifficulty + change, 0, (hasErect ? difficulties : difficultiesNoErect).length - 1);

	if (change > 0)
	{
		freeplaySelectorRight.visible = false;
		new FlxTimer().start(1 / 24, (_) -> {
			freeplaySelectorRight.visible = true;
		});
	} else if (change < 0)
	{
	    freeplaySelectorLeft.visible = false;
	    new FlxTimer().start(1 / 24, (_) -> {
	        freeplaySelectorLeft.visible = true;
	    });
	}

	var hasChangedDiff = oldDiff != curDifficulty;
	if (!hasChangedDiff && !force) return;

	if (diffSpr != null)
	{
		remove(diffSpr);
		diffSpr.destroy();
	}

	diffSpr = generateDifficultySprite(difficulties[curDifficulty]);
	add(diffSpr);

	diffSpr.x = 90;
	diffSpr.y = 80;

	diffSpr.offset.x = switch(difficulties[curDifficulty]) {
		case "normal":
			5;
		case "hard":
			4;
		case "erect":
			13;

		default:
			0;
	};

	diffSpr.offset.y += 5;
	diffSpr.alpha = 0.5;
	new FlxTimer().start(1 / 24, (_) -> {
		diffSpr.alpha = 1;
		diffSpr.offset.y -= 5;
	});
}

var capsules:Array<SongMenuItem> = [];
function update(elapsed) {
	if(bfDJ.anim.curFrame >= bfDJ.anim.length - 1){
		if(bfDJ.anim.curSymbol.name == "boyfriend dj intro") {
			bfDJ.anim.play("Boyfriend DJ", true);
			bfDJ.offset.set();
		}
	}

	if (blockInput) return;

	changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);
	changeDifficulty((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));

	if (controls.BACK)
	{
		blockInput = true;
		for (i in 0...capsules.length)
		{
			if (i > curSelected + 3) continue;
			if (i < curSelected - 3) continue;
			var capsule = capsules[i];
			if (capsule == null) continue;
			capsule.x = capsule.targetPos.x = (270 + (60 * (Math.sin((capsule.ID + 1) - curSelected))));
			exitMovers.set([capsule, capsule.targetPos],
			{
				x: FlxG.width + (270 + (60 * (Math.sin((capsule.ID + 1) - curSelected)))),
				speed: 0.15,
			});
		}
		for (txt in [backingCard.funnyScroll, backingCard.funnyScroll2, backingCard.moreWays,
		    backingCard.moreWays2, backingCard.txtNuts, backingCard.funnyScroll3, backingCard.orangeBackShit])
		    FlxTween.tween(txt, {alpha: 0}, 0.7, {ease: FlxEase.expoOut});

		exitMovers.set([diffSpr],
		{
			x: -300,
			speed: 0.15,
		});

		exitMovers.set([freeplaySelectorLeft],
		{
			x: -300- (freeplaySelectorLeft.width + 16),
			speed: 0.15,
		});

		exitMovers.set([freeplaySelectorRight],
		{
			x: -300 + (diffSpr.width - 8),
			speed: 0.15,
		});

		exitMovers.set([Framerate.offset],
		{
			y: 0,
			speed: 0.3,
		});

		var longTime = doFunnyTransition(false);
    
		new FlxTimer().start(longTime, (_) -> {
			for (m in members) {
				remove(m);
				m.kill();
				m.destroy();
			}

		    MemoryUtil.clearMajor(); //pretty sure not needed to do that but just incase
		    close();
		    state.selectedSomethin = false;
		});
		CoolUtil.playMenuSFX(2);
		FlxG.sound.music.stop();
		CoolUtil.playMenuSong();
	}

	if (controls.ACCEPT)
	{
		var sel = capsules[curSelected];
		if (sel.icon != null)
			sel.icon.animation.play("confirm", true);

	    CoolUtil.playMenuSFX(1);

	    bfDJ.anim.play("Boyfriend DJ confirm", true);
		bfDJ.offset.set();

	    var loadSong = sel.song;
	    if (curSelected == 0)
			loadSong = capsules[FlxG.random.int(1, capsules.length - 1)].song;

	    new FlxTimer().start(0.75, (_) -> {
			PlayState.loadSong(loadSong, difficulties[curDifficulty], false, false);
			FlxG.switchState(new PlayState());
	    });
	}
}

function playThatShittyMusic(path, isRandom)
{
	FlxG.sound.playMusic(path, 0);
	FlxG.sound.music.fadeIn(2, 0, isRandom ? 0.8 : 0.4);
	if (!isRandom)
		FlxG.sound.music.endTime = FlxG.sound.music.length * 0.2;
}

function changeSelection(change, force = false) {
	if (change == null) change = 0;

	if (change == 0 && !force) return;

	curSelected = FlxMath.wrap(curSelected + change, 0, capsules.length - 1);

	if (change != 0)
		CoolUtil.playMenuSFX();

	var selCapsule = capsules[curSelected];
	playThatShittyMusic(curSelected == 0 ? Paths.music("freeplayRandom") : Paths.inst(selCapsule.song, "normal"), curSelected == 0);

	for (capsule in capsules)
	{
		capsule.selected = capsule.ID == curSelected;
		capsule.updateSelected();

		capsule.targetPos.y = capsule.intendedY((capsule.ID + 1) - curSelected);
		capsule.targetPos.x = 270 + (60 * (Math.sin((capsule.ID + 1) - curSelected)));
		if ((capsule.ID + 1) < curSelected) capsule.targetPos.y -= 100; // another 100 for good measure

		if (force) {
			capsule.x = capsule.targetPos.x;
			capsule.y = capsule.targetPos.y;
		}
	}
}

var bfDJ:FlxAnimate;

var songs:Array<String> = [];

var angleMaskShader = new CustomShader("angleMask");
function create() {
	FlxG.cameras.add(freeplayCam, false);
	cameras = [freeplayCam];
	freeplayCam.bgColor = 0x00000000;
    
	var i = 0;
	var songList = new FreeplaySonglist();
	songList.getSongsFromSource(false, true);
	songs = songList.songs;
	songs.insert(0, {displayName: "Random", name: "Random"});

	for (song in songs)
	{
		var capsul = new SongMenuItem(0, 0, song);
		capsul.ID = i;
		capsules.push(capsul);
		i++;
	}
	createBackingcard("bf");

	var  bgDad = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('freeplay/freeplayBGdad'));
	bgDad.shader = angleMaskShader;
	angleMaskShader.endPosition = [90, 100]; // 100 AS DEFAULT WORKS NICELY FOR FREEPLAY?
	angleMaskShader.extraTint = [1, 1, 1];
	bgDad.setGraphicSize(0, FlxG.height);
	bgDad.updateHitbox();
	add(bgDad);

	introMovers.set([bgDad], {
	    x: backingCard.pinkBack.width * 0.74,
	    speed: 1 + FlxG.random.float(-0.04, 0.04),
	    wait: 0
	});

	exitMovers.set([bgDad],
	{
	  x: FlxG.width * 1.5,
	  speed: 0.4,
	  wait: 0
	});

	for (capsule in capsules)
		add(capsule);

	var overhangStuff:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 64, FlxColor.BLACK);
	overhangStuff.y -= overhangStuff.height;
	add(overhangStuff);

	var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
	fnfFreeplay.font = Paths.font("vcr.ttf");
	add(fnfFreeplay);

	var ostName:FlxText = new FlxText(8, 8, FlxG.width - 16, 'OFFICIAL OST', 48);
	ostName.font = Paths.font("vcr.ttf");
	ostName.alignment = "right";
	add(ostName);

	changeSelection(0, true);
	changeDifficulty(0, true);

	freeplaySelectorLeft = new FlxSprite();
	freeplaySelectorLeft.frames = Paths.getSparrowAtlas("freeplay/freeplaySelector/freeplaySelector");
	freeplaySelectorLeft.x = diffSpr.x - (freeplaySelectorLeft.width + 16);
	freeplaySelectorLeft.y = diffSpr.y - 10;
	freeplaySelectorLeft.animation.addByPrefix("idle", "arrow pointer loop0", 24, true);
	freeplaySelectorLeft.animation.play("idle");
	add(freeplaySelectorLeft);
	freeplaySelectorRight = new FlxSprite();
	freeplaySelectorRight.frames = Paths.getSparrowAtlas("freeplay/freeplaySelector/freeplaySelector");
	freeplaySelectorRight.x = diffSpr.x + diffSpr.width + 8;
	freeplaySelectorRight.y = diffSpr.y - 10;
	freeplaySelectorRight.animation.addByPrefix("idle", "arrow pointer loop0", 24, true);
	freeplaySelectorRight.animation.play("idle");
	add(freeplaySelectorRight);
	freeplaySelectorRight.flipX = true;

	for (i in 0...capsules.length)
	{
		if (i > curSelected + 3) continue;
		if (i < curSelected - 3) continue;
		var capsule = capsules[i];
		if (capsule == null) continue;
		capsule.x = capsule.targetPos.x = FlxG.width + (270 + (60 * (Math.sin((capsule.ID + 1) - curSelected))));
		introMovers.set([capsule, capsule.targetPos],
		{
			x: 270 + (60 * (Math.sin((capsule.ID + 1) - curSelected))),
			speed: 0.2 + (0.1 * i),
		});
	}

	ostName.y -= overhangStuff.height;
	fnfFreeplay.y -= overhangStuff.height;

	introMovers.set([overhangStuff], {
		y: 0,
		speed: 0.2,
		wait: 0
	});

	introMovers.set([fnfFreeplay, ostName], {
		y: 8,
		speed: 0.2,
		wait: 0
	});

	exitMovers.set([overhangStuff], {
		y: -overhangStuff.height,
		speed: 0.2,
		wait: 0
	});

	exitMovers.set([fnfFreeplay, ostName], {
		y: 8-overhangStuff.height,
		speed: 0.2,
		wait: 0
	});

	introMovers.set([Framerate.offset],
	{
		y: 165,
		speed: 0.5,
	});

	var fnfHighscoreSpr:FlxSprite = new FlxSprite(FlxG.width, 70);
	fnfHighscoreSpr.frames = Paths.getSparrowAtlas('freeplay/highscore');
	fnfHighscoreSpr.animation.addByPrefix('highscore', 'highscore small instance 1', 24, false);
	add(fnfHighscoreSpr);

	new FlxTimer().start(FlxG.random.float(12, 50), function(tmr) {
		fnfHighscoreSpr.animation.play('highscore');
		tmr.time = FlxG.random.float(20, 60);
	}, 0);

	introMovers.set([fnfHighscoreSpr],
	{
		x: 860,
		speed: 0.5,
	});

	exitMovers.set([fnfHighscoreSpr],
	{
		x: FlxG.width,
		speed: 0.5,
	});

	var longTime = doFunnyTransition(true);

	new FlxTimer().start(longTime, (_) -> {
	    FlxTween.tween(backingCard.flashBar, {alpha: 1}, .7, {type: FlxTweenType.BACKWARD});

		for (txt in [backingCard.funnyScroll, backingCard.funnyScroll2, backingCard.moreWays,
							backingCard.moreWays2, backingCard.txtNuts, backingCard.funnyScroll3, backingCard.orangeBackShit])
			txt.visible = true;

		blockInput = false;
	});
}

var blockInput = true;

function doFunnyTransition(intro:Bool)
{
	var longestTimer:Float = 0;
	if (intro)
	{
		for (grpSpr in introMovers.keys())
		{
			var moveData:Dynamic = introMovers.get(grpSpr);
			if (moveData == null) continue;
			
			for (spr in grpSpr)
			{
				if (spr == null) continue;

				var funnyMoveShit:Dynamic = moveData;

				var moveDataX = funnyMoveShit.x ?? spr.x;
				var moveDataY = funnyMoveShit.y ?? spr.y;
				var moveDataSpeed = funnyMoveShit.speed ?? 0.2;
				var moveDataWait = funnyMoveShit.wait ?? 0.0;
				
				FlxTween.tween(spr, {x: moveDataX, y: moveDataY}, moveDataSpeed, {ease: FlxEase.quintOut});

				longestTimer = Math.max(longestTimer, moveDataSpeed + moveDataWait);
			}
		}
    } else {
		for (grpSpr in exitMovers.keys())
		{
			var moveData:Dynamic = exitMovers.get(grpSpr);
			if (moveData == null) continue;

			for (spr in grpSpr)
			{
				if (spr == null) continue;

				var funnyMoveShit:Dynamic = moveData;

				var moveDataX = funnyMoveShit.x ?? spr.x;
				var moveDataY = funnyMoveShit.y ?? spr.y;
				var moveDataSpeed = funnyMoveShit.speed ?? 0.2;
				var moveDataWait = funnyMoveShit.wait ?? 0.0;

				FlxTween.tween(spr, {x: moveDataX, y: moveDataY}, moveDataSpeed, {ease: FlxEase.expoIn});

				longestTimer = Math.max(longestTimer, moveDataSpeed + moveDataWait);
			}
		}
	}
	return longestTimer;
}

function destroy() {
	if(FlxG.cameras.list.contains(freeplayCam))
		FlxG.cameras.remove(freeplayCam);
}