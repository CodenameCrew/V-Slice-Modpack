
import flixel.text.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import funkin.backend.FlxAnimate;
import funkin.backend.assets.Paths;
import haxe.io.Path;
import flixel.util.FlxTimer;
import flixel.tween.FlxTween;
import flixel.tween.FlxEase;
import backend.utils.CoolUtil;
import flixel.FlxText;
import flixel.FlxG;
import openfl.filters.GlowFilter;
import funkin.backend.shaders.CustomShader;
import openfl.display.BlendMode;

var dj;
var capsules:Array<FlxSpriteGroup> = [];
var realScaled = 0.8;//stuff from og freeplay
var blackBar:FlxSprite;
var triangle;
var bgDad:FlxSprite;
var freeplayText:FlxText;
var ostName:FlxText;
var leftArrow;
var rightArrow;
var difficulties;
var triangleGlow;
var triangleText;
var triangleBeat;
var triangleBeatDark;
var beatTween;
var beatDarkTween;

function postCreate() {
	//remove EVERYTHING
	remove(bg);//the ugly one
	remove(scoreText);//the ugly one
	remove(scoreBG);//the ugly one
	remove(diffText);//the ugly one
	remove(coopText);//the ugly one
	remove(grpSongs);//the ugly onesss
	for(icon in iconArray)
		remove(icon);

	//left bg
	triangle = new FlxSprite().loadGraphic(Paths.image('freeplay/triangle'));
	add(triangle);
	

	triangleText = new FlxAnimate(00,0,Path.withoutExtension(Paths.image('freeplay/triangle')));//IMPROVE-NOTE use better path 
	triangleText.anim.play('BOYFRIEND ch backing');
	add(triangleText);
	
	triangleBeatDark = new FlxSprite(0,381).loadGraphic(Paths.image('freeplay/beatdark'));
	triangleBeatDark.blend = BlendMode.MULTIPLY;
	triangleBeatDark.x = (triangle.width-200)/2-triangleBeatDark.width/2;
	triangleBeatDark.alpha = 0;
	add(triangleBeatDark);

	triangleBeat = new FlxSprite(0,326).loadGraphic(Paths.image('freeplay/beatglow'));
	triangleBeat.blend = BlendMode.ADD;
	triangleBeat.x = (triangle.width-200)/2-triangleBeat.width/2;
	add(triangleBeat);

    triangleGlow = new FlxSprite(-30, -30).loadGraphic(Paths.image('freeplay/triangleGlow'));
    triangleGlow.blend = BlendMode.ADD;
    triangleGlow.alpha = 0;
    add(triangleGlow);
	
	//right bg
	bgDad = new FlxSprite(triangle.width * 0.74, 0).loadGraphic(Paths.image('freeplay/bg'));
	bgDad.setGraphicSize(0, FlxG.height);
	bgDad.updateHitbox();
	bgDad.antialiasing = true;
	add(bgDad);
	
	//DJ CODE, NOTE ITS NAMED "DJ" NOT BOYFRIEND BC IT CHANGES BETWEEN PICO AND BF 
	dj = new FlxAnimate(640, 366,Path.withoutExtension(Paths.image('freeplay/freeplay-boyfriend')));//IMPROVE-NOTE use better path 
	djPlayAnim('Boyfriend DJ',0,0);
	dj.antialiasing = true;
	add(dj);

	//random button
	songs.unshift({
		name:'random',
		displayName:'Random',
		bpm:100,
		beatsPerMeasure:4,
		stepsPerBeat:4,
		needVoices:false,
		icon:'bf',
		color: 0xFFFFFFFF,
		parsedColor: 0xFFFFFFFF,
		difficulties:['easy','hard','normal'],
		coopAllowed:false,
		opponentModeAllowed:false
	});

	//capsules
	for(song in songs){
		var capsuleGroup:FlxSpriteGroup = new FlxSpriteGroup();
		add(capsuleGroup);

		var capsule:FlxSprite = new FlxSprite(0,0);
		capsule.frames = Paths.getSparrowAtlas('freeplay/freeplayCapsule');
		capsule.animation.addByPrefix('selected', 'mp3 capsule w backing0', 24);
		capsule.animation.addByPrefix('unselected', 'mp3 capsule w backing NOT SELECTED', 24);	
		capsule.animation.play('selected');
		capsule.antialiasing = true;
		capsule.scale.set(realScaled,realScaled);
		capsuleGroup.add(capsule);

        var titleTextBlur = new FlxText(capsule.width * 0.26, 45,0, song.displayName, Std.int(40 * realScaled));
        titleTextBlur.font = "5by7";
        titleTextBlur.color = 0xFF00ccff;
        titleTextBlur.shader = new CustomShader('GaussianBlurShader');
		//IMPROVE-NOTE something something low quailty option
        capsuleGroup.add(titleTextBlur);

        var text = new FlxText(capsule.width * 0.26, 45,0,song.displayName, Std.int(40 * realScaled));
        text.font = Paths.font("5by7.ttf");
        text.textField.filters = [
            new GlowFilter(0x00ccff, 1, 5, 5, 210, 2/*BitmapFilterQuality.MEDIUM*/),
          ];
        capsuleGroup.add(text);

		var pixelIcon = new FlxSprite(160, 35).loadGraphic(Paths.image('freeplay/icons/'+song.icon));
		pixelIcon.scale.x = pixelIcon.scale.y = 2;
		pixelIcon.antialiasing = false;
		pixelIcon.active = false;
        pixelIcon.origin.x = song.icon == 'parents-christmas' ? 140 : 100;
		pixelIcon.visible = song.name != 'random';//hide it DONT remove it
		capsuleGroup.add(pixelIcon);

		capsules.push(capsuleGroup);
	}


	//bar
    blackBar = new FlxSprite().makeGraphic(FlxG.width, 64, 0xFF000000);
    add(blackBar);
        
	freeplayText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
	add(freeplayText);
	
	ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48);//should make this change
	ostName.alignment = "right";
	add(ostName);

	freeplayText.font = ostName.font = 'VCR OSD Mono';

	//difficultySelector

	difficulties = new FlxSpriteGroup(90,80);
	add(difficulties);

	for(diff in ['easy','normal','hard']){//IMPROVE-NOTE make default difficulty and custom difficulties
		var difficulty = new FlxSprite(0,0).loadGraphic(Paths.image('freeplay/difficulties/'+diff));
		difficulty.visible = false;
		difficulties.add(difficulty);
	}
	

	leftArrow = new FlxSprite(20,70);
	add(leftArrow);

	rightArrow = new FlxSprite(325,70);
	rightArrow.flipX = true;
	add(rightArrow);

	for(arrow in [leftArrow,rightArrow]){//adds the spritesheet and the animations at the same time
		arrow.frames = Paths.getSparrowAtlas('freeplay/arrow');
		arrow.animation.addByPrefix('shine', 'arrow pointer loop', 24);
		arrow.animation.play('shine');
	}


	//intro
	intro();
	//to update the stuff
	changeSelection(0,true);
	changeDiff(0,true);
}

//gets an item from a capsule
function getItemFromCapsule(capsule,itemName){
	if(capsule != null){
		switch(itemName){
			case 'capsule':
				return capsule.members[0];
			case 'textBlur':
				return capsule.members[1];
			case 'text':
				return capsule.members[2];
		}
	}
	return null;
}

//made it a function for the offsets
function djPlayAnim(name,offsetX,offsetY){
	dj.anim.play(name,true);
	dj.offset.set(offsetX,offsetY);
}

//intro
function intro(){
	//bf
	djPlayAnim("boyfriend dj intro",6.7,2.6);
	
	//black bar
    blackBar.y -= blackBar.height;
    FlxTween.tween(blackBar, {y: 0}, 0.3, {ease: FlxEase.quartOut});
	
	freeplayText.visible= ostName.visible = false;

	//bg dad
	bgDad.color = 0xFF000000;
	bgDad.x = FlxG.width;
	FlxTween.tween(bgDad,{x:triangle.width * 0.74},0.7,{ease: FlxEase.quintOut});

	//yellow/pink triangle
	triangle.setColorTransform(0,0,0,1,255,212,233);//makes a pink color effect
	triangle.x -= triangle.width;
	FlxTween.tween(triangle,{x:0},0.6,{ease: FlxEase.quartOut});
	triangleText.visible = triangleBeat.visible = triangleBeatDark.visible = false;

	//difficultySelector
	difficulties.x = -300;
	leftArrow.visible = rightArrow.visible = false;

	//capsules
	for(capsule in capsules)
		capsule.setPosition(2000,-4000);
}

//when the dj character finishs its intro
function onIdleStart(){
	//black bar stuff
	freeplayText.visible = ostName.visible = true;

	//to make that effect ninja muffin wanted ig
	freeplayText.scale.y = ostName.scale.y = 1.1;
	new FlxTimer().start(1.5 / 24, function(__) freeplayText.scale.y = ostName.scale.y = 1);


	//triangle stuff
	triangle.setColorTransform();//removes the color effect
	
	triangleGlow.alpha = 1;
	FlxTween.tween(triangleGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});

	triangleText.visible = triangleBeat.visible  = triangleBeatDark.visible  = true;

	//bg dad stuff
	bgDad.color = 0xFFFFFFFF;
	
	//difficultySelector
	FlxTween.tween(difficulties, {x: 90}, 0.6, {ease: FlxEase.quartOut});
	leftArrow.visible = rightArrow.visible = true;
}

function update(){

	//on animation end code for texture atlases, its broken for some reason in flxAnimate so i remade it
	if(dj.anim.curFrame >= dj.anim.length - 1){//flxanimate sucks,i cant set the loop type https://github.com/FNF-CNE-Devs/flxanimate/blob/5be6822b5262230e19c975d50c8a1e2e44be10ba/flxanimate/animate/FlxAnim.hx#L189C11-L189C19
		if(dj.anim.curSymbol.name == "boyfriend dj intro"){
			djPlayAnim('Boyfriend DJ',0,0);

			onIdleStart();
		}
		if(dj.anim.curSymbol.name == 'Boyfriend DJ'){//so it syncs the beats with the idle
			beatDarkTween = FlxTween.tween(triangleBeatDark,{alpha:0.6},0.375,{startDelay:7/24,onComplete:function(_)triangleBeatDark.alpha = 0});
			beatTween = FlxTween.tween(triangleBeat,{alpha:0},0.33333333333,{startDelay:7/24,onComplete:function(_)triangleBeat.alpha = 1});
		}
	}

	//debug key
	if(FlxG.keys.justPressed.I)
		intro();

	//updates the lerp for the capsules
	for(capsule in capsules){
		var targetIndex = (capsules.indexOf(capsule)-curSelected)+1/**???**/;
		var targetY = (targetIndex * ((capsule.height * realScaled) + 10)) + 120;
		if (capsules.indexOf(capsule)+1 < curSelected) targetY -= 100;
		var targetX = 270 + (60 * (Math.sin(targetIndex)));

		capsule.y = CoolUtil.fpsLerp(capsule.y,targetY,0.4);
		capsule.x =  CoolUtil.fpsLerp(capsule.x,targetX,0.3);
	}
}

//adds a timer before loading the song
var alreadCanceledSelect = false;
function onSelect(event){
	if(songs[curSelected].name != 'random'){
		if(!alreadCanceledSelect){
			event.cancel();
			alreadCanceledSelect = true;

			dj.anim.play('Boyfriend DJ confirm');
			CoolUtil.playMenuSFX(1/**ACCEPT**/, 0.7);

			new FlxTimer().start(1.0,function(_){
				select();
			});
		}
	}else{
		curSelected = FlxG.random.int(0,songs.length-1,0);//exclude 0 cuz thats random
		changeSelection(0,true);
		select();
	}
}


//on change selection, event called by the freeplay by auto
function onChangeSelection(event){
	for(capsule in capsules){
		if(event.value == capsules.indexOf(capsule)){
			getItemFromCapsule(capsule,'capsule').animation.play('selected');
			getItemFromCapsule(capsule,'textBlur').visible = true;
			getItemFromCapsule(capsule,'text').alpha = 1;
			getItemFromCapsule(capsule,'capsule').offset.x = 0;
		}
		else{
			getItemFromCapsule(capsule,'capsule').animation.play('unselected');
			getItemFromCapsule(capsule,'textBlur').visible = false;
			getItemFromCapsule(capsule,'text').alpha = 0.6;
			getItemFromCapsule(capsule,'capsule').offset.x = -5;
		}
	}
}

function hitArrow(arrow){
	arrow.offset.y = -5;

	arrow.colorTransform.color = 0xFFFFFFFF;

	arrow.scale.set(0.5,0.5);

	new FlxTimer().start(2 / 24, function(tmr) {
		arrow.offset.y = 0;
	  arrow.scale.set(1,1);
	  arrow.setColorTransform();
	});
}

//on change difficulty, event called by the freeplay by auto
function onChangeDiff(event){
	if(event.change != 0)
		CoolUtil.playMenuSFX(0/**SELECT**/, 0.7);

	switch(event.change){
		case -1:
			hitArrow(leftArrow);
		case 1:
			hitArrow(rightArrow);
	}

	for(difficulty in difficulties.members){
		difficulty.visible = false;
		if(difficulties.members.indexOf(difficulty) == event.value){
			if(event.change != 0){
				difficulty.visible = true;
				difficulty.offset.y += 5;
				difficulty.alpha = 0.5;
				new FlxTimer().start(1 / 24, function(swag) {
					difficulty.alpha = 1;
					difficulty.updateHitbox();
				});
			}else
				difficulty.visible = true;
		}
	}
}

//only solution babe
function onUpdateOptionsAlpha(event){
	event.cancel();
	for (i=>item in grpSongs.members)
			item.targetY = i - curSelected;
}