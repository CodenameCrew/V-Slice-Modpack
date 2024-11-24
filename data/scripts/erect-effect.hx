// You gotta place values inside the character positions or sprites nodes in the stage xml before importing this script on your stage script!!  - Nex
import haxe.xml.Access;
import funkin.game.Stage.StageCharPos;

if (!Options.gameplayShaders)
{
    disableScript();
    return;
}

var __erectShaderAttNames:Array<String> = ["brightness", "hue", "contrast", "saturation"];
public var erectShaderCharsAtts:Array<Array<Float>> = [];

function onStageNodeParsed(event)
{
    var sprite = event.sprite;
    var node = event.node;

    if (sprite is FlxSprite)
    {
        var atts = getErectShaderAttFromNode(node);
        sprite.shader = initErectShader(atts[0], atts[1], atts[2], atts[3]);
    }
    else
    {
        var map = event.stage.characterPoses;

        for (char in map.keys()) if (map[char] == event.sprite)
        {
            erectShaderCharsAtts[getCharPosIndex(char)] = getErectShaderAttFromNode(node);
            break;
        }
    }
}

function create() if (strumLines != null) for (i => atts in erectShaderCharsAtts) if(atts != null) for (char in strumLines.members[i]?.characters)
    char?.shader = initErectShader(atts[0], atts[1], atts[2], atts[3]);

public function getCharPosIndex(charPos:String):Int
    return switch(charPos) { case "dad": 0; case "boyfriend": 1; default: 2; };

public function getErectShaderAttFromNode(node:Access):Array<Float>
    return [for (att in __erectShaderAttNames) getErectShaderAtt(CoolUtil.getAtt(node, att))];

public function getErectShaderAtt(att:String):Float
    return att?.length > 0 ? Std.parseFloat(att) : 0;

public function initErectShader(brightness:Float, hue:Float, contrast:Float, saturation:Float):CustomShader
{
    var shader = new CustomShader('adjustColor');
    shader.brightness = brightness;
    shader.hue = hue;
    shader.contrast = contrast;
    shader.saturation = saturation;
    return shader;
}