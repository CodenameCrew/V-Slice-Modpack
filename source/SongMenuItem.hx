import flixel.FlxObject;

class SongMenuItem extends FlxObject
{
    var members:Array<FlxObject> = [];

    var capsule:FlxSprite;
    var blurSongText:FlxText;
    var songText:FlxText;
    var icon:FlxSprite;

    var selected:Bool = false;

    function updateSelected()
    {
        songText.alpha = selected ? 1 : 0.6;
        blurSongText.visible = selected;
        capsule.offset.x = selected ? 0 : -5;
        capsule.animation.play(selected ? "selected" : "unselected");
    }

    function initText(songTitle, size:Float):FlxText
    {
        var text:FlxText = new FlxText(0, 0, 0, songTitle, Std.int(size));
        text.font = Paths.font("5by7.ttf");
        return text;
    }

    var capsuleScale:Float = 0.8;

    var song:String;

    var targetPos:FlxPoint = FlxPoint.get();

    function intendedY(index:Int):Float
    {
        return (index * ((capsule.height * capsuleScale) + 10)) + 120;
    }

    function makeCoolNumber(x, y, num, small)
    {
        var numToString:Array<String> = ["ZERO", "ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE"];
        var smallNumber:FlxSprite = new FlxSprite();
        smallNumber.frames = Paths.getSparrowAtlas('freeplay/freeplayCapsule/' + (small ? 'smallnumbers' : 'bignumbers'));
        smallNumber.animation.addByPrefix("idle", numToString[num], 0, false);
        smallNumber.animation.play("idle");
        smallNumber.setGraphicSize(Std.int(smallNumber.width * 0.9));
        smallNumber.updateHitbox();
        switch (num)
        {
          case 1:
            smallNumber.offset.x -= 4;
          case 3:
            smallNumber.offset.x -= 1;
          case 4 | 6 | 9:
            //do nothing
          default:
            smallNumber.centerOffsets(false);
        }
        smallNumber.offset.x -= x;
        smallNumber.offset.y -= y;
        return smallNumber;
    }

    function new(x:Float, y:Float, data:Dynamic)
    {
        super(x, y, null);

        song = data.name;

        capsule = new FlxSprite();
        capsule.frames = Paths.getSparrowAtlas('freeplay/freeplayCapsule/capsule/freeplayCapsule');
        capsule.animation.addByPrefix('selected', 'mp3 capsule w backing0', 24, true);
        capsule.animation.addByPrefix('unselected', 'mp3 capsule w backing NOT SELECTED', 24, true);
        capsule.scale.set(capsuleScale, capsuleScale);
        add(capsule);

        if (Reflect.hasField(data, "bpm"))
        {
            var bpmText = new FlxSprite().loadGraphic(Paths.image('freeplay/freeplayCapsule/bpmtext'));
            bpmText.setGraphicSize(Std.int(bpmText.width * 0.9));
            bpmText.offset.set(-144, -87);
            add(bpmText);

            var bpmString = Std.string(data.bpm);
            var strLen = bpmString.length;
            switch (strLen)
            {
                case 1:
                    bpmString = "00" + bpmString;
                case 2:
                    bpmString = "0" + bpmString;
            }
            for (i in 0...3)
                add(makeCoolNumber((185 + (i * 11)), 88.5, Std.parseInt(bpmString.charAt(i)), true));
        }

        if (Reflect.hasField(data, "weekNum"))
        {
            var isWeekend = Reflect.hasField(data, "isWeekEnd") && data.isWeekEnd;
            var weekType = new FlxSprite();
            weekType.frames = Paths.getSparrowAtlas('freeplay/freeplayCapsule/weektypes');
    
            weekType.animation.addByPrefix('WEEK', 'WEEK text instance 1', 0, false);
            weekType.animation.addByPrefix('WEEKEND', 'WEEKEND text instance 1', 0, false);

            weekType.animation.play(isWeekend ? 'WEEKEND' : 'WEEK');

            weekType.setGraphicSize(Std.int(weekType.width * 0.9));
            weekType.updateHitbox();
            add(weekType);

            weekType.offset.set(-291, -87);

            add(makeCoolNumber(291 + (isWeekend ? weekType.frameWidth : weekType.frameWidth / 1.65), 88.5, data.weekNum, true));
        }
        
        if (Reflect.hasField(data, "difficulty"))
        {
            var difficultyText = new FlxSprite().loadGraphic(Paths.image('freeplay/freeplayCapsule/difficultytext'));
            difficultyText.setGraphicSize(Std.int(difficultyText.width * 0.9));
            add(difficultyText);
            difficultyText.offset.set(-414, -87);

            var diffString = Std.string(data.difficulty);
            var strLen = diffString.length;
            switch (strLen)
            {
                case 1:
                    diffString = "0" + diffString;
            }
            for (i in 0...2)
                add(makeCoolNumber(466 + (i * 30), 32, Std.parseInt(diffString.charAt(i)), false));
        }

        icon = new FlxSprite();

        var charIcon = data.icon;
        if (charIcon != "" && charIcon != null)
        {
            if (charIcon == "mom")
                charIcon = "mommy";

            if (charIcon == "face")
                charIcon = "darnell"; //temp
            icon.frames = Paths.getSparrowAtlas('freeplay/icons/' + charIcon + "pixel");
            icon.animation.addByPrefix('idle', 'idle0', 1, false);
            icon.animation.addByPrefix('confirm', 'confirm0', 10, false);
            icon.scale.x = icon.scale.y = 2;
            add(icon);
            icon.animation.play("idle");
            icon.offset.x = -160;
            icon.offset.y = -30;
            switch (charIcon)
            {
              case 'parents-christmas':
                icon.origin.x = 140;
              default:
                icon.origin.x = 100;
            }
        }

        blurSongText = initText(data.displayName, Std.int(40 * capsuleScale));
        blurSongText.offset.set(-(capsule.width * 0.26), -45);
        add(blurSongText);
        blurSongText.shader = new CustomShader("gaussianBlur");
        blurSongText.shader._amount = 1;
        blurSongText.color = 0xFF00ccff;

        songText = initText(data.displayName, Std.int(40 * capsuleScale));
        songText.offset.set(-(capsule.width * 0.26), -45);
        add(songText);

        updateSelected();
    }

    function update(elapsed) {
        x = state.lerp(x, targetPos.x, 0.3);
        y = state.lerp(y, targetPos.y, 0.4);

        for (a in members) {
            if (a != null && a.active) {
                a.update(elapsed);
            }
        }
    }

    override function destroy() {
        for (a in members)
            a.destroy();
    }

    override function draw() {
        for (a in members) {
            if (a != null && a.exists && a.visible && a.alpha > 0) {
                if (a._cameras != _cameras)
                    a._cameras = _cameras;
                if (a.x != x)
                    a.x = x;
                if (a.y != y)
                    a.y = y;
                a.draw();
            }
        }
      }

    function add(a) { members.push(a); }
    function remove(a) { members.remove(a); }
}