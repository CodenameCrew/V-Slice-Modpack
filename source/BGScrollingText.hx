import flixel.util.FlxSort;
import flixel.FlxObject;

//flxgroup fucky way
class BGScrollingText extends FlxObject
{
	var grpTexts:Array<FlxSprite> = [];
	var widthShit:Float = FlxG.width;
	var placementOffset:Float = 20;
	var speed:Float = 1;
	var size:Int = 48;
	var alpha:Float = 1;
	var funnyColor:Int = 0xFFFFFFFF;

	function new(x:Float, y:Float, text:String, widthShit:Float = 100, ?bold:Bool = false, ?size:Int = 48)
	{
		super(x, y);

		if (size != null) this.size = size;

		var testText:FlxText = new FlxText(0, 0, 0, text, this.size);
		testText.font = Paths.font("5by7.ttf");
		testText.bold = bold;
		testText.updateHitbox();
		grpTexts.push(testText);

		var needed:Int = Math.ceil(widthShit / testText.frameWidth) + 1;

		for (i in 0...needed)
		{
		  var lmfao:Int = i + 1;

		  var coolText:FlxText = new FlxText((lmfao * testText.frameWidth) + (lmfao * 20), 0, 0, text, this.size);

		  coolText.font = Paths.font("5by7.ttf");
		  coolText.bold = bold;
		  coolText.updateHitbox();
		  grpTexts.push(coolText);
		}
	}

	function destroy() {
		for (a in grpTexts)
			a.destroy();
	}

	override function draw() {
		for (txt in grpTexts) {
		    if (txt != null && txt.exists && txt.visible && txt.alpha > 0)
		        txt.draw();

		    if (txt.color != funnyColor)
		        txt.color = funnyColor;
		    if (txt.size != size)
		        txt.size = size;
		    if (txt.y != y)
		        txt.y = y;
		    if (txt.alpha != alpha)
		        txt.alpha = alpha;
		}
	}

	override public function update(elapsed:Float)
	{
		for (txt in grpTexts) {
		    if (txt == null)
		        continue;

			txt.x -= 1 * (speed * (elapsed / (1 / 60)));

			if (speed > 0)
			{
			  if (txt.x < -txt.frameWidth)
			  {
			    txt.x = grpTexts[grpTexts.length - 1].x + grpTexts[grpTexts.length - 1].frameWidth + placementOffset;
			    sortTextShit();
			  }
			}
			else
			{
			  if (txt.x > txt.frameWidth * 2)
			  {
			    txt.x = grpTexts[0].x - grpTexts[0].frameWidth - placementOffset;
			    sortTextShit();
			  }
			}
		}

		super.update(elapsed);
	}

	function sortTextShit():Void
	{
		grpTexts.sort(function(Obj1, Obj2) {
			return FlxSort.byValues(-1, Obj1.x, Obj2.x);
		});
	}
}