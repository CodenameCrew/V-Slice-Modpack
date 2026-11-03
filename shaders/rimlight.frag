/*
	rimlight shader - @betpowo
	different approach for funkin's drop shdow,
	i made this in godot for nother project and
	then backported it to flixel

	it uses matrices instead of the usual hsbc
	for more controllable colors
*/

#pragma header
// backporting vars from godot cus im lazy
#define TEXTURE bitmap
#define UV openfl_TextureCoordv
#define TEXTURE_PIXEL_SIZE vec2(1.0) / openfl_TextureSize.xy
#define PI 3.14159

const vec3 luma = vec3(0.213, 0.715, 0.072);
const float TO_RAD = PI/180.0;

uniform vec4 _uFrameBounds;
uniform float _angOffset;
uniform bool _flipX;
uniform bool _flipY;

uniform mat4 matrixA;
uniform mat4 matrixB;
uniform float threshold;
uniform float distance_offset;
uniform float distance_angle;
uniform bool inner;
uniform bool smoothing;
uniform bool knockout;
uniform bool use_alt_mask;
uniform sampler2D alt_mask;
uniform float alt_threshold;

vec2 getFinalOffset() {
    float ag = distance_angle + _angOffset;
	vec2 offset = vec2(cos(ag * TO_RAD), sin(ag * TO_RAD)) * distance_offset * TEXTURE_PIXEL_SIZE;
	if (_flipX) offset.x *= -1;
	if (_flipY) offset.y *= -1;
    return offset;
}

bool outside(vec2 uv) {
    return clamp(uv, _uFrameBounds.xy, _uFrameBounds.zw) != (uv);
}

vec4 texAlpha(sampler2D t, vec2 u) {
    if (outside(u)) return vec4(0.0);
    return texture2D(t, u, 1.25);
}

float getFuckingValue(float shit, float b, float thr) {
    float min_cap = (1.0 - thr) * 0.1;
	float _value2 = 1.0 - b;
	if ((1.0 - b) < min_cap) _value2 = min_cap;
    return smoothstep(
        min_cap,
        _value2,
        clamp(shit / (thr * b * b), 0.0, 1.0)
    );
}

float fuck(sampler2D t, vec2 u, vec2 s, vec2 o) {
	vec4 tex = texture2D(t, u, 1.5);
	float brightness = dot(tex.rgb, luma);
    float b = brightness;
	float thr = threshold;
	if (use_alt_mask) {
		thr = mix(threshold, alt_threshold, texture2D(alt_mask, u).b);
	}
	float diff = brightness - thr;
	if (!smoothing) return clamp(sign(diff), 0.0, 1.0);
    float blur = sqrt(1.5);
    brightness = smoothstep(-0.5, 1.0, diff);
	brightness += getFuckingValue(dot(texture2D(t, u + (s * vec2(+blur, 0)), 1.5).rgb, luma) - thr, b, thr);
	brightness += getFuckingValue(dot(texture2D(t, u + (s * vec2(0, -blur)), 1.5).rgb, luma) - thr, b, thr);
	brightness += getFuckingValue(dot(texture2D(t, u + (s * vec2(-blur, 0)), 1.5).rgb, luma) - thr, b, thr);
	brightness += getFuckingValue(dot(texture2D(t, u + (s * vec2(0, +blur)), 1.5).rgb, luma) - thr, b, thr);
	brightness *= 0.2;
	return smoothstep(0.0, 1.0, clamp(brightness / tex.a, 0.0, 1.0));
}

void main() {
    gl_FragColor = texture2D(TEXTURE, UV);
	if (gl_FragColor.a <= 0.0) {
		gl_FragColor = vec4(0.0);
        return;
	}
	vec2 offset = getFinalOffset();
	float brightness = dot(gl_FragColor.rgb, luma);
	gl_FragColor = applyFlixelEffects(gl_FragColor);
    if (abs(distance_offset) == 0.0) {
		if (knockout) gl_FragColor *= matrixB;
		else gl_FragColor *= matrixA;
        return;
    }
	float result = gl_FragColor.a
		* abs((float(!inner) - texAlpha(TEXTURE, UV - offset).a));
	if (inner) result = 1.0 - result;

	result *= fuck(TEXTURE, UV, TEXTURE_PIXEL_SIZE, offset);
    gl_FragColor = mix(gl_FragColor * vec4(float(!knockout)) * matrixA, gl_FragColor * matrixB, result);
	gl_FragColor = clamp(gl_FragColor, 0.0, 1.0);
}