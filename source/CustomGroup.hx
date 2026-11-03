import flixel.util.FlxSignal1;
class CustomGroup extends flixel.FlxSprite {
    var length(get, null):Int;
    function get_length():Int return members.length;

    public var memberAdded:FlxSignal1 = new FlxSignal1();
    public var memberRemoved:FlxSignal1 = new FlxSignal1();

	public var members = [];
	public function add(a)       { members.push(a); memberAdded.dispatch(a);   }
	public function insert(x, a) { members.insert(x, a); }
	public function remove(a, s) { memberRemoved.dispatch(a); members.remove(a, s); }
	public function new() {
		super();
	}
	// set_x and set_y no workie
	public var __lastX:Float = 0;
	public var __lastY:Float = 0;
	public override function update(elapsed) {
		var __deltaX = x - __lastX, __deltaY = y - __lastY;
		for (bleh in members) {
			if (bleh != null) {
				bleh.x += __deltaX;
				bleh.y += __deltaY;
			}

			if (bleh == null || !bleh.active || !bleh.alive || !bleh.exists) continue;
			bleh.update(elapsed); 
		}
		__lastX = x;
		__lastY = y;
	}
	public override function draw() {
		for (bleh in members) {
			if (bleh == null || !bleh.visible || !bleh.alive || !bleh.exists) continue;
			bleh.draw(); 
		}
	}

	public function forEach(f) {
		for (i in members) {
			if (i != null) f(i);
		}
	}
	public function forEachAlive(f) {
		for (i in members) {
			if (i == null || !i.alive || !i.exists) continue;
			f(i);
		}
	}
    override function destroy() {
		while (members.length > 0) members.shift().destroy();
		super.destroy();
	}
}
