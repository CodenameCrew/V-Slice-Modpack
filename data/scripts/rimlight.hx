/*
	rimlight shader - @betpowo
	different approach for funkin's drop shdow,
	i made this in godot for nother project and
	then backported it to flixel

	it uses matrices instead of the usual hsbc
	for more controllable colors
*/

import funkin.backend.utils.MathUtil;

// returns an aray of rgb channels (normalized if second arg is true)
// should automatically support alpha (i hope)
public function getRGBArray(col:FlxColor, ?norm:Bool) {
	// in case i forget
	if (col == -1)
		col = 0xffffff;
	norm ??= true;
	var res = [(col >> 16) & 0xff, (col >> 8) & 0xff, (col >> 0) & 0xff];
	// is 24 bit (alpha channel)
	if ((col != col & 0xffffff))
		res.push((col >> 24) & 0xff);
	if (norm) {
		for (x => i in res)
			res[x] = i / 255;
	}
	return res;
}

public function identity4x4() {
	/*
		the 4th column can act as the add blend mode
		if the other columns arent 0 btw
	*/
	return [
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	];
}

public function hueMatrix(v:Float, ?matrix:Array) {
    var cosHue = Math.cos(v * Math.PI / 180);
    var sinHue = Math.sin(v * Math.PI / 180);
	matrix ??= identity4x4();

    matrix[ 0] = 0.213 + cosHue *  0.787 + sinHue * -0.213;
    matrix[ 4] = 0.213 + cosHue * -0.213 + sinHue *  0.143;
    matrix[ 8] = 0.213 + cosHue * -0.213 + sinHue * -0.787;
    matrix[ 1] = 0.715 + cosHue * -0.715 + sinHue * -0.715;
    matrix[ 5] = 0.715 + cosHue *  0.285 + sinHue *  0.140;
    matrix[ 9] = 0.715 + cosHue * -0.715 + sinHue *  0.715;
    matrix[ 2] = 0.072 + cosHue * -0.072 + sinHue *  0.928;
    matrix[ 6] = 0.072 + cosHue * -0.072 + sinHue * -0.283;
    matrix[10] = 0.072 + cosHue *  0.928 + sinHue *  0.072;
    return matrix;
}

public function tintMatrix(v:FlxColor, ?reset:Bool, ?matrix:Array) {
	reset ??= true;
    var col = getRGBArray(v);
	var alpha = 1;
	if (col.length > 3) alpha = col.pop();
	matrix ??= identity4x4();
	for (a in 0...col.length) {
		for (b in 0...3) {
			matrix[b + (a * 4)] = FlxMath.lerp(matrix[b + (a * 4)], col[a], alpha);
			if (reset && (b / 4) != a) matrix[b + (a * 4)] = 0;
		}
	}
    return matrix;
}

public function setAddColorMatrix(v:FlxColor, ?matrix:Array, ?add:Bool = false) {
    var col = getRGBArray(v);
	var alpha = 1;
	if (col.length > 3) alpha = col.pop();
	matrix ??= identity4x4();
	add ??= false;
	if (add) for (a in 0...col.length) matrix[((a + 1) * 4) - 1] += col[a] * alpha;
	else for (a in 0...col.length) matrix[((a + 1) * 4) - 1] = col[a] * alpha;
    return matrix;
}

public final grayscaleValues = [0.213, 0.715, 0.072];
public function hsbc(hue:Float, sat:Float, bri:Float, con:Float, ?matrix:Array) {
	matrix ??= identity4x4();
	hue ??= 0; sat ??= 0; bri ??= 0; con ??= 0;

	// birghtness
	for (i in 0...3) {
		matrix[(i * 4) + 3] = (bri / 255);
	}

	//hue
	hueMatrix(hue, matrix);

	// contrast
	var value = con;
	value = (1.0 + (value / 100.0));
	for (r in 0...4) {
		for (c in 0...4) {
			var i = r + (c * 4);
			if (i >= 3 * 4 || (i + 1) % 4 == 0) continue;
			
			matrix[i] *= value;
		}
		if (r < 3) matrix[(r * 4) + 3] += 0.5 * (1 - value);
	}

	// saturation

	var satFactor = sat;
	if (satFactor > 0) satFactor *= 3; // bullshit from dropshadow
	satFactor = 1 + (satFactor / 100);
	for (r in 0...4) {
		for (c in 0...4) {
			var i = r + (c * 4);
			if (i >= 3 * 4 || (i + 1) % 4 == 0) continue;
			
			matrix[i] = FlxMath.lerp(grayscaleValues[r], matrix[i], satFactor);
		}
	}
}

public function copyRimlightTo(rim, target:FlxSprite) {
	var tim = rimlight(target);
	tim.distance_offset = rim.distance_offset;
	tim.distance_angle = rim.distance_angle;
	tim.threshold = rim.threshold;
	tim.matrixA = rim.matrixA.copy();
	tim.matrixB = rim.matrixB.copy();
	return tim;
}

public function rimlight(?i:FlxSprite) {
	var shad = new CustomShader('rimlight');
	shad.matrixA = identity4x4();
	shad.matrixB = identity4x4();
	shad.threshold = 0.1;
	shad.distance_offset = 15;
	shad.distance_angle = 90;
	shad.inner = false;
	shad.knockout = false;
	shad.smoothing = true;
	shad._flipX = false;
	shad._flipX = false;
	shad._angOffset = 0;
	shad._uFrameBounds = [0, 0, 1, 1];

    var i = i;
    if (i == null) return shad;
	var anim = i.animation;
	if (i is FlxAnimate) {
		i.useRenderTexture = true;
		anim = i.anim;
	}
    i.shader = shad;
	function stupidFunc() {
        i.shader._uFrameBounds[0] = i.frame.uv.x;
		i.shader._uFrameBounds[1] = i.frame.uv.y;
		i.shader._uFrameBounds[2] = i.frame.uv.width;
		i.shader._uFrameBounds[3] = i.frame.uv.height;
        i.shader._angOffset = i.frame.angle * (Math.PI / 180);
		i.shader._flipX = anim?.curAnim?.flipX ?? false;
		i.shader._flipY = anim?.curAnim?.flipY ?? false;
    }
    i.animation.onFrameChange.add(stupidFunc);
	i.animation.onPlay.add(stupidFunc);
    stupidFunc();

	return shad;
}