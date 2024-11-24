// for porting better v-slice shaders made by @NeeEoo!!  - Nex

// normalized screen coord
//   (0, 0) is the top left of the window
//   (1, 1) is the bottom right of the window

varying vec2 screenCoord;

// equals (camera.viewLeft, camera.viewTop, camera.viewRight, camera.viewBottom)
uniform vec4 uCameraBounds;

// equals (frame.left, frame.top, frame.right, frame.bottom)
uniform vec4 uFrameBounds;

// screen coord -> world coord conversion
// returns world coord in px
vec2 screenToWorld(vec2 screenCoord) {
	float left = uCameraBounds.x;
	float top = uCameraBounds.y;
	float right = uCameraBounds.z;
	float bottom = uCameraBounds.w;
	vec2 scale = vec2(right - left, bottom - top);
	vec2 offset = vec2(left, top);
	return screenCoord * scale + offset;
}

// world coord -> screen coord conversion
// returns normalized screen coord
vec2 worldToScreen(vec2 worldCoord) {
	float left = uCameraBounds.x;
	float top = uCameraBounds.y;
	float right = uCameraBounds.z;
	float bottom = uCameraBounds.w;
	vec2 scale = vec2(right - left, bottom - top);
	vec2 offset = vec2(left, top);
	return (worldCoord - offset) / scale;
}

// screen coord -> frame coord conversion
// returns normalized frame coord
vec2 screenToFrame(vec2 screenCoord) {
	float left = uFrameBounds.x;
	float top = uFrameBounds.y;
	float right = uFrameBounds.z;
	float bottom = uFrameBounds.w;
	float width = right - left;
	float height = bottom - top;

	float clampedX = clamp(screenCoord.x, left, right);
	float clampedY = clamp(screenCoord.y, top, bottom);

	return vec2(
		(clampedX - left) / (width),
		(clampedY - top) / (height)
	);
}

// internally used to get the maximum `openfl_TextureCoordv`
vec2 bitmapCoordScale() {
	return openfl_TextureCoordv / screenCoord;
}

// internally used to compute bitmap coord
vec2 screenToBitmap(vec2 screenCoord) {
	return screenCoord * bitmapCoordScale();
}

// samples the frame buffer using a screen coord
vec4 sampleBitmapScreen(vec2 screenCoord) {
	return texture2D(bitmap, screenToBitmap(screenCoord));
}

// samples the frame buffer using a world coord
vec4 sampleBitmapWorld(vec2 worldCoord) {
	return sampleBitmapScreen(worldToScreen(worldCoord));
}