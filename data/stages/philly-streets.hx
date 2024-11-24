// Took the one inside the BaseGame source as a base  - Nex
import flixel.addons.display.FlxTiledSprite;

// var carSndAmbience:FunkinSound;

var lightsStop:Bool = false; // state of the traffic lights
var lastChange:Int = 0;
var changeInterval:Int = 8; // make sure it doesnt change until AT LEAST this many beats

var carWaiting:Bool = false; // if the car is waiting at the lights and is ready to go on green
var carInterruptable:Bool = true; // if the car can be reset
var car2Interruptable:Bool = true;

var scrollingSky:FlxTiledSprite;

/**
* Changes the current state of the traffic lights.
* Updates the next change accordingly and will force cars to move when ready
*/
function changeLights(beat:Int) {
	lastChange = beat;
	lightsStop = !lightsStop;

	if(lightsStop) {
		trafficLights.animation.play('tored');
		changeInterval = 20;
	} else {
		trafficLights.animation.play('togreen');
		changeInterval = 30;
		if(carWaiting) finishCarLights(cars1);
	}
}

/**
* Resets every value of a car and hides it from view.
*/
function resetCar(left:Bool, right:Bool) {
	if(left) {
		carWaiting = false;
		carInterruptable = true;
		if (stage.getSprite("cars1") != null) {
			FlxTween.cancelTweensOf(cars1);
			cars1.x = 1200;
			cars1.y = 818;
			cars1.angle = 0;
		}
	}

	if(right) {
		car2Interruptable = true;
		if (stage.getSprite("cars2") != null) {
			FlxTween.cancelTweensOf(cars2);
			cars2.x = 1200;
			cars2.y = 818;
			cars2.angle = 0;
		}
	}
}

function onStartCountdown(_) {
	resetCar(true, true);
	resetStageValues();
}

/*function onPostStartCountdown() {
	// carSndAmbience.volume = 0.1;
}*/

function create()
{
	// carSndAmbience = FunkinSound.load(Paths.sound("carAmbience", "weekend1"), true, false, true);
	// carSndAmbience.volume = 0;
	// carSndAmbience.play(false, FlxG.random.float(0, carSndAmbience.length));
	switch (PlayState.instance.curSongID)
	{
		case "darnell":
			rainShaderStartIntensity = 0;
			rainShaderEndIntensity = 0.1;
		case "2hot":
			rainShaderStartIntensity = 0.2;
			rainShaderEndIntensity = 0.4;
	}

	rainColor = 0xFFa8adb5;

	resetCar(true, true);
	resetStageValues();
}

function onStageXMLParsed(event)
{
	scrollingSky = new FlxTiledSprite(Paths.image(event.stage.spritesParentFolder + 'phillySkybox'), 2922, 718, true, false);
	scrollingSky.setPosition(-650, -375);
	scrollingSky.scrollFactor.set(0.1, 0.1);
	scrollingSky.scale.set(0.65, 0.65);
	event.stage.stageSprites.set('scrollingSky', scrollingSky);
	add(scrollingSky);
}

/*function destroy() {
	// trace('Cancelling car tweens weee');

	// Cne automatic handles tweens when destorying  - Nex
	//if (cars1 != null) FlxTween.cancelTweensOf(cars1);
	//if (cars2 != null) FlxTween.cancelTweensOf(cars2);

	// Fully stop ambiance.
	// if (carSndAmbience != null) carSndAmbience.stop();

	// trace('Done');
}*/

/**
* Drive the car away from the lights to the end of the road.
* Used when the lights turn green and the car is waiting in position.
*/
function finishCarLights(sprite:FlxSprite) {
	carWaiting = false;
	var duration:Float = FlxG.random.float(1.8, 3);
	var rotations:Array<Int> = [-5, 18];
	var offset:Array<Float> = [306.6, 168.3];
	var startdelay:Float = FlxG.random.float(0.2, 1.2);

	var path:Array<FlxPoint> = [
		FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
		FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
	];

	FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay});
	FlxTween.quadPath(sprite, path, duration, true, {ease: FlxEase.sineIn, startDelay: startdelay, onComplete: function(_) carInterruptable = true});
}

/**
* Drives a car towards the lights and stops.
* Used when a car tries to drive while the lights are red.
*/
function driveCarLights(sprite:FlxSprite) {
	carInterruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.animation.play('car' + variant);
	var extraOffset = [0, 0];
	var duration:Float = 2;

	switch(variant) {
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.9, 1.5);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	var rotations:Array<Int> = [-7, -5];
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);

	var path:Array<FlxPoint> = [
		FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
		FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
		FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
	];
	// debug shit!!! keeping it here just in case
	// for(point in path){
	// 	var debug:FlxSprite = new FlxSprite(point.x - 5, point.y - 5).makeGraphic(10, 10, 0xFFFF0000);
	// 	add(debug);
	// }
	FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut});
	FlxTween.quadPath(sprite, path, duration, true, {ease: FlxEase.cubeOut, onComplete: function(_) {
		carWaiting = true;
		if(!lightsStop) finishCarLights(cars1);
	}});
}

/**
* Drives a car across the screen without stopping.
* Used when the lights are green.
*/
function driveCar(sprite:FlxSprite) {
	carInterruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.animation.play('car' + variant);
	// setting an offset here because the current implementation of stage prop offsets was not working at all for me
	// if possible id love to not have to do this but im keeping this for now
	var extraOffset = [0, 0];
	var duration:Float = 2;
	// set different values of speed for the car types (and the offset)
	switch(variant) {
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.6, 1.2);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	// random arbitrary values for getting the cars in place
	// could just add them to the points but im LAZY!!!!!!
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	// start/end rotation
	var rotations:Array<Int> = [-8, 18];
	// the path to move the car on
	var path:Array<FlxPoint> = [
			FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
	];

	FlxTween.angle(sprite, rotations[0], rotations[1], duration, null);
	FlxTween.quadPath(sprite, path, duration, true, {ease: null, onComplete: function(_) carInterruptable = true});
}

function driveCarBack(sprite:FlxSprite) {
	car2Interruptable = false;
	FlxTween.cancelTweensOf(sprite);
	var variant:Int = FlxG.random.int(1, 4);
	sprite.animation.play('car' + variant);
	// setting an offset here because the current implementation of stage prop offsets was not working at all for me
	// if possible id love to not have to do this but im keeping this for now
	var extraOffset = [0, 0];
	var duration:Float = 2;
	// set different values of speed for the car types (and the offset)
	switch(variant) {
		case 1:
			duration = FlxG.random.float(1, 1.7);
		case 2:
			extraOffset = [20, -15];
			duration = FlxG.random.float(0.6, 1.2);
		case 3:
			extraOffset = [30, 50];
			duration = FlxG.random.float(1.5, 2.5);
		case 4:
			extraOffset = [10, 60];
			duration = FlxG.random.float(1.5, 2.5);
	}
	// random arbitrary values for getting the cars in place
	// could just add them to the points but im LAZY!!!!!!
	var offset:Array<Float> = [306.6, 168.3];
	sprite.offset.set(extraOffset[0], extraOffset[1]);
	// start/end rotation
	var rotations:Array<Int> = [18, -8];
	// the path to move the car on
	var path:Array<FlxPoint> = [
		FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
		FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
		FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)
	];

	FlxTween.angle(sprite, rotations[0], rotations[1], duration, null);
	FlxTween.quadPath(sprite, path, duration, true, {ease: null, onComplete: function(_) car2Interruptable = true});
}

/**
* Resets the values tied to the lights that need to be accounted for on a restart.
*/
function resetStageValues() {
	lastChange = 0;
	changeInterval = 8;
	lightsStop = false;
	if(stage.getSprite("trafficLights") != null)
		trafficLights.animation.play('togreen');
}

var rainDropTimer:Float = 0;
var rainDropWait:Float = 6;

function update(elapsed) scrollingSky?.scrollX -= FlxG.elapsed * 22;

function beatHit(beat:Int)
{
	if (stage.getSprite("cars1") != null)
	{
		// Try driving a car when its possible
		if(FlxG.random.bool(10) && beat != (lastChange + changeInterval) && carInterruptable)
		{
			if(!lightsStop) driveCar(cars1);
			else driveCarLights(cars1);
		}

		// change the light state.
		if (stage.getSprite("trafficLights") != null && beat == (lastChange + changeInterval)) changeLights(beat);
	}

	// try driving one on the right too. in this case theres no red light logic, it just can only spawn on green lights
	if(stage.getSprite("cars2") != null && FlxG.random.bool(10) && beat != (lastChange + changeInterval) && car2Interruptable && !lightsStop) driveCarBack(cars2);
}