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