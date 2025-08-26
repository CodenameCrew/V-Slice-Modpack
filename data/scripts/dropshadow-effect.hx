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

/**
 * Note from Nex:
 * TAKEN FROM VSLICE AND ADAPTED FOR CNE'S HSCRIPT PUBLIC VERSION!!!
 * You can use any variables and functions from this class BESIDES the ones that start with `set_` and `get_` (since these functions get called automatically when changing their linked variable)!!
 */
class DropShadowShader
{
    /*
        The DropShadow shader.
    */
    public var shader:CustomShader;

    /*
        The color of the drop shadow.
    */
    public var color(default, set):FlxColor;

    /*
        The angle of the drop shadow.

        for reference, depending on the angle, the affected side will be:
        0 = RIGHT
        90 = UP
        180 = LEFT
        270 = DOWN
    */
    public var angle(default, set):Float;

    /*
        The distance or size of the drop shadow, in pixels,
        relative to the texture itself... NOT the camera.
    */
    public var distance(default, set):Float;

    /*
        The current zoom of the camera. Needed to figure out how much to multiply the drop shadow size.
    */
    public var curZoom(default, set):Float;

    /*
        The strength of the drop shadow.
        Effectively just an alpha multiplier.
    */
    public var strength(default, set):Float;

    /*
        The brightness threshold for the drop shadow.
        Anything below this number will NOT be affected by the drop shadow shader.
        A value of 0 effectively means theres no threshold, and vice versa.
    */
    public var threshold(default, set):Float;

    /*
        Whether the shader aligns the drop shadow pixels perfectly.
        False by default.
    */
    public var pixelPerfect(default, set):Bool;

    /*
        The amount of antialias samples per-pixel,
        used to smooth out any hard edges the brightness thresholding creates.
        Defaults to 2, and 0 will remove any smoothing.
    */
    public var antialiasAmt(default, set):Float;

    /*
        Whether the drop shadow is flipped horizontally.
    */
    public var flipX(default, set):Bool;

    /*
        Whether the drop shadow is flipped vertically.
    */
    public var flipY(default, set):Bool;

    /*
        Whether the shader should try and use the alternate mask.
        False by default.
    */
    public var useAltMask(default, set):Bool;

    /*
        The image for the alternate mask.
        At the moment, it uses the blue channel to specify what is or isnt going to use the alternate threshold.
        (its kinda sloppy rn i need to make it work a little nicer)
        TODO: maybe have a sort of "threshold intensity texture" as well? where higher/lower values indicate threshold strength..
    */
    public var altMaskImage(default, set):BitmapData;

    /*
        An alternate brightness threshold for the drop shadow.
        Anything below this number will NOT be affected by the drop shadow shader,
        but ONLY when the pixel is within the mask.
    */
    public var maskThreshold(default, set):Float;

    /*
        The FlxSprite that the shader should get the frame data from.
        Needed to keep the drop shadow shader in the correct bounds and rotation.
    */
    public var attachedSprite(default, set):FlxSprite;

    /*
        The hue component of the Adjust Color part of the shader.
    */
    public var baseHue(default, set):Float;

    /*
        The saturation component of the Adjust Color part of the shader.
    */
    public var baseSaturation(default, set):Float;

    /*
        The brightness component of the Adjust Color part of the shader.
    */
    public var baseBrightness(default, set):Float;

    /*
        The contrast component of the Adjust Color part of the shader.
    */
    public var baseContrast(default, set):Float;

    /*
        Sets all 4 adjust color values.
    */
    public function setAdjustColor(b:Float, h:Float, c:Float, s:Float)
    {
        set_baseBrightness(b);
        set_baseHue(h);
        set_baseContrast(c);
        set_baseSaturation(s);
    }

    public function set_baseHue(val:Float):Float
    {
        shader.hue = baseHue = val;
        return val;
    }

    public function set_baseSaturation(val:Float):Float
    {
        shader.saturation = baseSaturation = val;
        return val;
    }

    public function set_baseBrightness(val:Float):Float
    {
        shader.brightness = baseBrightness = val;
        return val;
    }

    public function set_baseContrast(val:Float):Float
    {
        shader.contrast = baseContrast = val;
        return val;
    }

    public function set_threshold(val:Float):Float
    {
        shader.thr = threshold = val;
        return val;
    }

    public function set_pixelPerfect(val:Bool):Bool
    {
        shader.pixelPerfect = pixelPerfect = val;
        return val;
    }

    public function set_antialiasAmt(val:Float):Float
    {
        shader.AA_STAGES = antialiasAmt = val;
        return val;
    }

    public function set_color(col:FlxColor):FlxColor
    {
        var lerpColor = new FlxInterpolateColor(color = col);  // some FlxColor stuff are abstracts, so lets use cne's FlxInterpolateColor  - Nex
        shader.dropColor = [lerpColor.red, lerpColor.green, lerpColor.blue];
        return color;
    }

    public function set_angle(val:Float):Float
    {
        shader.ang = FlxAngle.asRadians(angle = val);
        return angle;
    }

    public function set_distance(val:Float):Float
    {
        shader.dist = distance = val;
        return val;
    }

    public function set_curZoom(val:Float):Float
    {
        shader.zoom = curZoom = val;
        return val;
    }

    public function set_strength(val:Float):Float
    {
        shader.str = strength = val;
        return val;
    }

    public function set_flipX(val:Bool):Bool
    {
        shader.flipX = flipX = val;
        return val;
    }

    public function set_flipY(val:Bool):Bool
    {
        shader.flipY = flipY = val;
        return val;
    }

    public function set_attachedSprite(spr:FlxSprite):FlxSprite
    {
        updateFrameInfo((attachedSprite = spr)?.frame);
        return spr;
    }

    /*
        Loads an image for the mask.
        While you *could* directly set the value of the mask, this function works for both HTML5 and desktop targets.
        Nex's Edit: CNE auto handles this for every target so nah  - Nex
    */
    public function loadAltMask(path:String)
    {
        /*#if html5
        BitmapData.loadFromFile(path).onComplete(function(bmp:BitmapData) {
            altMaskImage = bmp;
        });
        #else
        altMaskImage = BitmapData.fromFile(path);
        #end*/

        altMaskImage = Assets.getBitmapData(path);
    }

    /*
        Should be called on the animation.callback of the attached sprite.
        TODO: figure out why the reference to the attachedSprite breaks on web??
    */
    public function onAttachedFrame(name, frameNum, frameIndex)
    {
        if (attachedSprite != null) updateFrameInfo(attachedSprite.frame);
    }

    /*
        Updates the frame bounds and angle offset of the sprite for the shader.
    */
    public function updateFrameInfo(frame:FlxFrame)
    {
        var isNull = frame == null;

        // NOTE: uv.width is actually the right pos and uv.height is the bottom pos
        shader.uFrameBounds = isNull ? null : [frame.uv.x, frame.uv.y, frame.uv.width, frame.uv.height];

        // if a frame is rotated the shader will look completely wrong lol
        shader.angOffset = isNull ? 0 : frame.angle * FlxAngle.TO_RAD;
    }

    public function set_altMaskImage(_bitmapData:BitmapData):BitmapData
    {
        shader.altMask = _bitmapData;
        return _bitmapData;
    }

    public function set_maskThreshold(val:Float):Float
    {
        shader.thr2 = maskThreshold = val;
        return val;
    }

    public function set_useAltMask(val:Bool):Bool
    {
        var isNull = val == null;

        if (!isNull)
        {
            shader.useMask = useAltMask = val;
            return val;
        }
    }

    public function new(){}
}