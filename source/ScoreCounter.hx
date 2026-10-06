class ScoreCounter extends FunkinSprite {
    var numbers = [];
    var numberString = ['ZERO', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE'];
    public function new() {
        super();
        for (i in 0...7) {
            var num = new FunkinSprite(i * 60, 0, Paths.image('menus/freeplay/digital_numbers'));
            for (x => j in numberString) {
                num.addAnim(Std.string(x), j + ' DIGITAL', 24, false, null, null, 
                    x == 1 ? -62 : 0 // ?????????????
                );
            }
            num.playAnim('0', true);
            num.scale.set(0.398, 0.398);
            num.antialiasing = true;
            num.updateHitbox();
            numbers.push(num);
        }
    }
    override public function update(elapsed) {
        if (!active || !exists) return;
        for (i in numbers) {
            if (i.active && i.exists) {
                i.update(elapsed);
            }
        }
    }
    override public function draw() {
        if (!visible || !exists) return;
        for (x => i in numbers) {
            if (i.visible && i.exists) {
                i.setPosition(this.x + 45 * x, this.y);
                i.draw();
            }
        }
    }

    public var value(default, set):Int = 0;
    public function set_value(v:Int) {
        value = v;
        for (x => i in numbers) {
            final targetAnim = Std.string(Std.int(value / Math.pow(10, numbers.length - x - 1)) % 10);
            if (i.getAnimName() != targetAnim) i.playAnim(targetAnim, true);
        }
        return value;
    }
}