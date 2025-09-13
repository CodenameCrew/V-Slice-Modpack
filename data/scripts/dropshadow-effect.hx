/** le credits
 * Syrup: made the stage extension, added some new variables
 * Moro-Maniac: grabbed the shader frag file
 * Nex_isDumb: made the DropShadowShader class, made fixes and optimizations
 */
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxAngle;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.game.Stage.StageCharPos;
import haxe.xml.Access;
import openfl.display.BitmapData;
import DropShadow;

if (!Options.gameplayShaders)
{
    disableScript();
    return;
}

public var dsShaderCharsAtts:Array<Array<Dynamic>> = [];

function onStageNodeParsed(event)
{
    var sprite = event.sprite;
    var node = event.node;

    if (sprite is FlxSprite)
    {
        var atts = getDSShaderAttFromNode(node);

        if (atts[0] == false) return;  // not using !atts[0] since the game would have convert a dynamic into a null which is slower; i wonder if its the same in hscript..?  - Nex
        initDSShader(atts[1], atts[2], atts[3], atts[4], atts[5], atts[6], atts[7], atts[8], atts[9], atts[10],
            atts[11], atts[12], atts[13], atts[14], atts[15], atts[16], atts[17], sprite);
    }
    else if (sprite is StageCharPos)
    {
        var name = event.name;
        if (event.stage.characterPoses.exists(name)) dsShaderCharsAtts[getCharPosIndex(name)] = getDSShaderAttFromNode(node);
    }
}

function create() if (strumLines != null) for (i => atts in dsShaderCharsAtts) if(atts != null) for (char in strumLines.members[i]?.characters)
{
    if (atts[0] == false) continue;
    initDSShader(atts[1], atts[2], atts[3], atts[4], atts[5], atts[6], atts[7], atts[8], atts[9], atts[10],
        atts[11], atts[12], atts[13], atts[14], atts[15], atts[16], atts[17], char);
}

public function getCharPosIndex(charPos:String):Int
    return switch(charPos) { case "dad": 0; case "boyfriend": 1; default: 2; };

public function getDSShaderAttFromNode(node:Access):Array<Dynamic>
    return
    [
        CoolUtil.getAtt(node, "ds_applyShader") == "true",
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_brightness")),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_hue")),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_contrast")),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_saturation")),
        CoolUtil.getAtt(node, "ds_color"),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_angle")),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_antialiasAmt"), 2),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_strength"), 1),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_distance"), 15),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_curZoom"), 1),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_threshold"), 0.1),
        CoolUtil.getAtt(node, 'ds_pixelPerfect') == "true",
        CoolUtil.getAtt(node, 'ds_flipX') == "true",
        CoolUtil.getAtt(node, 'ds_flipY') == "true",
        CoolUtil.getAtt(node, "ds_altMask"),
        getDSShaderAtt(CoolUtil.getAtt(node, "ds_maskThreshold")),
        CoolUtil.getAtt(node, "ds_applyAltMask") == "true"
    ];

public function getDSShaderAtt(att:String, ?def:Float):Float
    return att?.length > 0 ? Std.parseFloat(att) : (def == null ? 0 : def);

public function initDSShader(
    brightness:Float, hue:Float, contrast:Float, saturation:Float, color:String, angle:Float, antialiasAmt:Float, strength:Float,
    distance:Float, curZoom:Float, threshold:Float, pixelPerfect:Bool, flipX:Bool, flipY:Bool,
    altMask:String, maskThreshold:Float, applyAltMask:Bool, sprite:FlxSprite
    ):CustomShader
{
    var dropShadow = getDropShadow(sprite);

    dropShadow.setAdjustColor(brightness, hue, contrast, saturation);
    dropShadow.color = FlxColor.fromString(color);

    dropShadow.angle = angle;
    dropShadow.strength = strength;
    dropShadow.distance = distance;
    dropShadow.curZoom = curZoom;
    dropShadow.threshold = threshold;
    dropShadow.pixelPerfect = pixelPerfect;
    dropShadow.antialiasAmt = antialiasAmt;
    dropShadow.flipX = flipX;
    dropShadow.flipY = flipY;

    if (altMask != null) dropShadow.loadAltMask(Paths.image(altMask));
    dropShadow.maskThreshold = maskThreshold;
    dropShadow.useAltMask = applyAltMask;
}

/**
 * USE THIS FUNCTION, DONT USE `new DropShadowShader()`!!!  - Nex
 */
public function getDropShadow(?attachedSprite:FlxSprite):DropShadowShader {
    var fucker = new DropShadowShader();

    fucker.shader = new CustomShader("DropShadow");

    fucker.angle = 0;
    fucker.strength = 1;
    fucker.distance = 15;
    fucker.threshold = 0.1;

    fucker.baseHue = 0;
    fucker.baseSaturation = 0;
    fucker.baseBrightness = 0;
    fucker.baseContrast = 0;
    fucker.curZoom = 1;

    fucker.flipX = false;
    fucker.flipY = false;

    fucker.pixelPerfect = false;
    fucker.antialiasAmt = 2;

    fucker.useAltMask = false;

    fucker.shader.angOffset = 0;

    fucker.color = null;
    fucker.altMaskImage = null;
    fucker.maskThreshold = 0;

    if ((fucker.attachedSprite = attachedSprite) != null) {
        attachedSprite.shader = fucker.shader;
        attachedSprite.animation.callback = fucker.onAttachedFrame;
    }

    return fucker;
}

public function getDropShadowScreenspace():DropShadowShader {
    var fucker = new DropShadowShader();

    fucker.shader = new CustomShader("DropShadowScreenspace");

    fucker.angle = 0;
    fucker.strength = 1;
    fucker.distance = 15;
    fucker.threshold = 0.1;

    fucker.baseHue = 0;
    fucker.baseSaturation = 0;
    fucker.baseBrightness = 0;
    fucker.baseContrast = 0;
    fucker.curZoom = 1;

    fucker.flipX = false;
    fucker.flipY = false;

    fucker.pixelPerfect = false;
    fucker.antialiasAmt = 2;

    fucker.useAltMask = false;

    fucker.shader.angOffset = 0;

    fucker.color = null;
    fucker.altMaskImage = null;
    fucker.maskThreshold = 0;

    return fucker;
}