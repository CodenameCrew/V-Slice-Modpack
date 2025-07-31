import flixel.group.FlxTypedSpriteGroup;

import funkin.game.Strum;
import notes.NoteHoldCover;
import notes.NoteHoldSplash;

class NoteCoverHandler extends FlxTypedGroup<FunkinSprite>
{
	/*
     * Array of the color directions for the strumlines.
    */
    public static var directions:Array<String> = ['Purple', 'Blue', 'Green', 'Red'];

	public static function getDirectionName(direction:Int)
        return NoteCoverHandler.directions[direction % NoteCoverHandler.directions.length];

    /**
	 * Array containing all of the covers group (index = direction).
	 */
	public var datas:Array<CoverData> = [];

	public function new() {
		super();
	}

	/**
	 * Caches Hold Covers/Splashes.
	 */
	public function cacheStuff(direction:Int):CoverData {
		if (datas[i] == null) datas[i] = CoverData.initNcache(direction);
		return datas[i];
	}

	public override function destroy() {
		super.destroy();
		for(data in datas)
			data.destroy();
		datas = null;
	}

	var _firstDraw:Bool = true;
	public override function draw() {
		super.draw();
		if (_firstDraw != (_firstDraw = false))
			for(sprs in datas)
				sprs.draw();
	}

	public function showCover(strum:Strum) {
		var __spr = cacheStuff(strum.ID).cover;
		__spr.cameras = strum.lastDrawCameras;

		__spr.updatePosition(strum);
		__spr.start();
		add(__spr);

		// max 16 rendered covers
		while(members.length > 16)
			remove(members[0], true);
	}

	function coverSpark(strum:Strum, delay:Float = 0, showSplash:Bool) {
		var __data = cacheStuff(strum.ID);

		new FlxTimer().start(0.01 * delay, function() {
			if (!showSplash)
			{
				var splash = __data.splash.start();
				splash.setPosition(cover.x = strum.x + cover.posX, cover.y = strum.y + cover.posY);
				splash.angle = cover.angle = strum.angle;
				splash.antialiasing = cover.antialiasing;
				splash.visible = cover.visible;
				splash.cameras = cover.cameras;
				add(splash);
			}

			cover.visible = false;
		});
	}
}

class CoverData
{
	public var cover:NoteHoldCover;
	public var splash:NoteHoldSplash;

    function new(cover:NoteHoldCover, splash:NoteHoldSplash):Void
	{
		super();

		this.cover = cover;
		this.splash = splash;

		// immediatly draw once and put image in GPU to prevent freezes  - Nex
		cover.drawComplex(FlxG.camera);
		splash.drawComplex(FlxG.camera);
	}

	public function draw()
	{
		cover.draw();
		splash.draw();
	}

	public function destroy()
	{
		cover.destroy();
		splash.destroy();
	}

	public static function initNcache(direction:Int):CoverData
		return new CoverData(new NoteHoldCover(direction), new NoteHoldSplash(direction));
}