// Took the one inside the BaseGame source as a base  - Nex
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.FlxBackdrop;

var scrollingSky:FlxTiledSprite;

var paperInterruptable:Bool = true;

// Type of mist, X Position, Y Position, Scroll, Scale, Alpha, X Velocity
var mistData:Array<Dynamic> = [
	['Mid', -650, -100, 1.2, 1, 0.6, 172],
	['Mid', -650, -100, 1.1, 1, 0.6, 150],
	['Back', -650, -100, 1.2, 1, 0.8, -80],
	['Mid', -650, -100, 0.95, 0.8, 0.5, -50],
	['Back', -650, -100, 0.8, 0.7, 1, 40],
	['Mid', -650, -100, 0.5, 1.1, 1, 20]
];

function create()
	initMist();

function postCreate()
	if(boyfriend.curCharacter != 'pico')
		boyfriend.cameraOffset.x = -120;

var mists:Array<FlxBackdrop> = [];
function initMist()
{
	for (mist in mistData) {
		var mistBackdrop = new FlxBackdrop(Paths.image('stages/philly-streets/erect/mist' + mist[0]), 0x01);
		mistBackdrop.setPosition(mist[1], mist[2]);
		mistBackdrop.scrollFactor.set(mist[3], mist[3]);
		mistBackdrop.scale.set(mist[4], mist[4]);
		mistBackdrop.color = 0xFF5c5c5c;
		mistBackdrop.alpha = mist[5];
		mistBackdrop.velocity.x = mist[6];
		mistBackdrop.blend = 0;

		mists.push(mistBackdrop);
	}

	insert(members.indexOf(trafficLightsMap), mists[5]);
	insert(members.indexOf(cars2) + 1, mists[4]);
	insert(members.indexOf(bg) + 1, mists[3]);
	add(mists[0]);
	add(mists[1]);
	add(mists[2]);
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

var _timer:Float = 0;
function update(elapsed)
{
	_timer += elapsed;
	mists[0].y = 660 + (Math.sin(_timer * 0.35) * 70);
	mists[1].y = 500 + (Math.sin(_timer * 0.3) * 80);
	mists[2].y = 540 + (Math.sin(_timer * 0.4) * 60);
	mists[3].y = 230 + (Math.sin(_timer * 0.3) * 70);
	mists[4].y = 170 + (Math.sin(_timer * 0.35) * 50);
	mists[5].y = -80 + (Math.sin(_timer * 0.08) * 100);
	// mists[3].y = -20 + (Math.sin(_timer * 0.5) * 200);
	// mists[4].y = -180 + (Math.sin(_timer * 0.4) * 300);
	// mists[5].y = -450 + (Math.sin(_timer * 0.2) * 1xxx50);

	scrollingSky?.scrollX -= FlxG.elapsed * 22;
}

function beatHit(cur:Int)
{
	// this was disabled in og, but i like it, so why not?  - Nex
	if (paper != null && FlxG.random.bool(0.6) && paperInterruptable == true)
	{
		paper.alpha = 1;
		paper.animation.play('paperBlow');
		paper.y = 608 + FlxG.random.float(-150,150);
		paperInterruptable = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			paperInterruptable = true;
			paper.alpha = 0;
		});
	}
}